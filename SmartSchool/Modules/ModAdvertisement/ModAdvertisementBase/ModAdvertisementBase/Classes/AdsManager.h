//
//  AdsManager.h
//  Unilife
//
//  Created by 唐琦 on 2019/7/18.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import "AdData.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AdsDelegate <NSObject>

- (void)adsClicked:(AdData *)ads;

@end

@interface AdsManager : BaseManager < AdsDelegate >

- (void)showSplash;

- (NSArray<AdData *> *)allAds;

- (void)adsClicked:(AdData *)ads;

- (void)prefetchVideoWithString:(NSString *)string;
- (nullable NSString *)cachedVideoPathWithString:(NSString *)string;

- (void)statAdsWithType:(NSString *)type
                    ads:(int64_t)uid
             completion:(nullable CommonBlock)completion;

@end

NS_ASSUME_NONNULL_END
