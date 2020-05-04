//
//  NewsData.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/19.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewsData : NSObject
@property (nonatomic, assign) NSInteger     uid;
@property (nonatomic, copy)   NSString      *title;
@property (nonatomic, copy)   NSString      *overview;
@property (nonatomic, copy)   NSString      *originalImageUrl;
@property (nonatomic, copy)   NSString      *targetUrl;
@property (nonatomic, copy)   NSString      *shareUrl;
@property (nonatomic, copy)   NSDate        *date;

@property (nonatomic, copy)   NSString      *loginid;

@property (nonatomic, copy)   UIImage       *cachedImage;

+ (instancetype)newsFromData:(NSDictionary *)data;

- (void)cacheImageWithSize:(CGSize)size completion:(nullable CommonBlock)completion;

- (NSString *)imageUrl;

@end

NS_ASSUME_NONNULL_END
