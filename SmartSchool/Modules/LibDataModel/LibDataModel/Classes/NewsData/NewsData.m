//
//  NewsData.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/19.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "NewsData.h"
#import <NYXImagesKit/NYXImagesKit.h>

@interface NewsData ()

@property (nonatomic, copy) NSString    *cachedKey;

@end

@implementation NewsData

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return [self modelInitWithCoder:aDecoder];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self modelCopy];
}

+ (instancetype)newsFromData:(NSDictionary *)data {
    NewsData *news = [[NewsData alloc] init];
    
    news.uid = [VALIDATE_NUMBER(data[@"uid"]) integerValue];
    news.title = data[@"title"];
    news.overview = data[@"overview"];
    news.targetUrl = data[@"target_url"];
    news.shareUrl = VALIDATE_STRING(data[@"share_url"]);
    news.originalImageUrl = data[@"image_url"];
    news.date = [NSDate date];
    id num = data[@"date"];
    if (![num isKindOfClass:[NSNull class]] && [num isKindOfClass:[NSNumber class]]) {
        NSNumber *number = data[@"date"];
        news.date = [NSDate dateWithTimeIntervalSince1970:[number integerValue]];
    }
    
    return news;
}

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [self init]) {
        
    }
    
    return self;
}

- (NSString *)cachedKey {
    if (self.originalImageUrl.length) {
        return [NSString stringWithFormat:@"%@-cached", self.originalImageUrl];
    }
    
    return nil;
}

- (UIImage *)cachedImage {
    if (_cachedImage) {
        return _cachedImage;
    }
    
    if (self.cachedKey) {
        UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:self.cachedKey];
        if (image) {
            image = [[UIImage alloc] initWithCGImage:image.CGImage
                                               scale:[UIScreen mainScreen].scale
                                         orientation:image.imageOrientation];
            _cachedImage = image.copy;
            return _cachedImage;
        }
    }
    
    return nil;
}

- (void)cacheImageWithSize:(CGSize)size completion:(CommonBlock)completion {
    void (^store)(UIImage *image, CGSize size) = ^(UIImage *image, CGSize size) {
        if (image.size.width > size.width || image.size.height > size.height) {
            image = [image scaleToSize:size usingMode:NYXResizeModeAspectFit];
        }
        
        if (image) {
            [[SDImageCache sharedImageCache] storeImage:image
                                                 forKey:self.cachedKey
                                             completion:nil];
        }
        
        if (completion) {
            completion(YES, image?@{@"image" : image}:nil);
        }
    };
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:self.imageUrl];
    if (!image) {
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:self.imageUrl]
                                                    options:0
                                                   progress:nil
                                                  completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                      if (data) {
                                                          image = [[UIImage alloc] initWithData:data scale:[UIScreen mainScreen].scale];
                                                          store(image, size);
                                                      }
                                                      else if (completion) {
                                                          completion(NO, nil);
                                                      }
                                                  }];
    }
    else {
        image = [[UIImage alloc] initWithCGImage:image.CGImage
                                           scale:[UIScreen mainScreen].scale
                                     orientation:image.imageOrientation];
        store(image, size);
    }
}

- (NSString *)imageUrl {
    return [self urlOfThumbWithSize:CGSizeMake(1280, 1280)
                               mode:UIViewContentModeScaleAspectFit
                               type:nil
                             forUrl:self.originalImageUrl];
}

- (NSString *)urlOfThumbWithSize:(CGSize)size
                            mode:(UIViewContentMode)mode
                            type:(NSString *)type
                          forUrl:(NSString *)urlString {
    if (![urlString containsString:@".aliyuncs.com"]) {
        return urlString;
    }

    switch (mode) {
        case UIViewContentModeScaleAspectFit: {
            // 按长边缩略
            return [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_lfit,w_%ld,h_%ld/format,%@", urlString, (long)size.width, (long)size.height, type?:@"jpg"];
        }
            
        case UIViewContentModeScaleAspectFill: {
            // 按短边压缩
            return [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_mfit,w_%ld,h_%ld/format,%@", urlString, (long)size.width, (long)size.height, type?:@"jpg"];
        }
            break;
            
        default: {
            // 按短边压缩，居中裁剪
            return [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,w_%ld,h_%ld/format,%@", urlString, (long)size.width, (long)size.height, type?:@"jpg"];
        }
    }
}

@end

