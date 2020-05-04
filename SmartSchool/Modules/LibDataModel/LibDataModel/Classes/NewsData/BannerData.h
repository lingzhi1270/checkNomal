//
//  BannerData.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/23.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface BannerData : NSObject

@property (nonatomic, assign) int64_t           uid;
@property (nullable, nonatomic, copy) NSString  *title;
@property (nullable, nonatomic, copy) NSString  *mediaUrl;
@property (nullable, nonatomic, copy) NSString  *targetType;
@property (nullable, nonatomic, copy) NSString  *targetUrl;

+ (instancetype)bannerWithData:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
