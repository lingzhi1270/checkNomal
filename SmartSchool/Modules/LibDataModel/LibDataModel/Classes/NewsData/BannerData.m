//
//  BannerData.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/23.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "BannerData.h"

@implementation BannerData

+ (instancetype)bannerWithData:(NSDictionary *)data {
    return [[self alloc] initBannerWithData:data];
}

- (instancetype)initBannerWithData:(NSDictionary *)data {
    if (self = [self init]) {
        self.targetType = VALIDATE_STRING(data[@"target_type"]);
        self.targetUrl = VALIDATE_STRING(data[@"target_url"]);
        self.title = VALIDATE_STRING(data[@"title"]);
        
        NSString *url = VALIDATE_STRING(data[@"image_url"]);
        self.mediaUrl = [self urlOfThumbWithSize:CGSizeMake(1080, 1080)
                                            mode:UIViewContentModeScaleAspectFit
                                            type:nil
                                          forUrl:url];
    }
    
    return self;
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
