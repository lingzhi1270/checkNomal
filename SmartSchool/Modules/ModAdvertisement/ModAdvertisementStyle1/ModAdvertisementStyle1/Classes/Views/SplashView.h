//
//  SplashView.h
//  Unilife
//
//  Created by 唐琦 on 2016/10/26.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import "ArchiveManager.h"
#import <SDWebImage/SDWebImagePrefetcher.h>
#import <SDWebImage/SDImageCache.h>
#import "AdData.h"

@class SplashView;

@protocol SplashDelegate <NSObject>

- (void)finishSplash:(SplashView *)splash
               delay:(NSTimeInterval)delay
          completion:(dispatch_block_t)completion;

@end

@interface SplashView : UIView
@property (nonatomic, copy) NSString                *zip;
@property (nonatomic, copy) NSURL                   *url;
@property (nonatomic, copy) UIImage                 *image;
@property (nonatomic, copy) NSArray<UIImage *>      *images;
@property (nonatomic, copy) NSArray                 *backgroundColors;
@property (nonatomic, copy) NSURL                   *videoUrl;
@property (nonatomic, strong) AdData                *ads;

@property (nonatomic, copy) UIImage                 *placeHolder;
@property (nonatomic, weak) id <SplashDelegate>     delegate;

+ (BOOL)splashVisible;

- (void)setImage:(UIImage *)image bottomImage:(UIImage *)bottomImage;

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;

@end
