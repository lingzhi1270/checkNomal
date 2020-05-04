//
//  AdsManager.m
//  Unilife
//
//  Created by 唐琦 on 2019/7/18.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "AdsManager.h"
#import "SplashView.h"
#import <LibCoredata/CacheDataSource.h>

NSString * splashKey      = @"1030";

@interface AdsManager () <SplashDelegate>
@property (nonatomic, strong) SplashView *splash;
@property (nonatomic, strong) NSMutableDictionary   *caching;

@end

@implementation AdsManager

+ (instancetype)shareManager {
    static dispatch_once_t token;
    static AdsManager *client = nil;
    dispatch_once(&token, ^{
        client = [[AdsManager alloc] init];
    });
    
    return client;
}

- (instancetype)init {
    if (self = [super init]) {
        self.caching = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)showSplash {
    if (!self.splash) {
        self.splash = [[SplashView alloc] init];
    }
    
    UIImage *placeHolder = nil;
    UIDeviceResolution resolution = [UIScreen resolution];
    switch (resolution) {
        case UIDeviceResolution_iPhoneRetina4:
            placeHolder = [UIImage imageNamed:@"icon_splash_retina4"];
            break;
            
        case UIDeviceResolution_iPhoneRetina5:
            placeHolder = [UIImage imageNamed:@"icon_splash_retina5"];
            break;
            
        case UIDeviceResolution_iPhoneRetina6:
            placeHolder = [UIImage imageNamed:@"icon_splash_retina6"];
            break;
            
        case UIDeviceResolution_iPhoneRetina6p:
            placeHolder = [UIImage imageNamed:@"icon_splash_retina6p"];
            break;
            
        case UIDeviceResolution_iPhoneRetinaX:
            placeHolder = [UIImage imageNamed:@"icon_splash_retinaX"];
            break;
            
        default:
            break;
    }
    self.splash.delegate = self;
    self.splash.placeHolder = placeHolder;
    
    [self fetchSplashAdsWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
        AdData *ads = info[@"data"];
        
        dispatch_async_on_main_queue(^{
            NSString *key = [NSUserDefaults splashKey];
            if (splashKey && ![splashKey isEqualToString:key]) {
                [NSUserDefaults saveSplashKey:splashKey];
                splashKey = nil;
                
                [[UIApplication sharedApplication].keyWindow addSubview:self.splash];
                [self.splash mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo([UIApplication sharedApplication].keyWindow);
                }];
                
                NSMutableArray *arr = [NSMutableArray array];
                for (int i = 1; i < 10; i++) {
                    NSString *name = [NSString stringWithFormat:@"ic_guide_0%d", i];
                    UIImage *image = [UIImage imageNamed:name];
                    if (image) {
                        [arr addObject:image];
                    }
                    else {
                        break;
                    }
                }
                
                self.splash.backgroundColors = @[[UIColor colorWithRGB:0x67b3ee], [UIColor colorWithRGB:0xf65c35], [UIColor colorWithRGB:0x8aae2d]];
                self.splash.images = arr.copy;
            }
            else if (ads) {
                ads.timeLast = [NSDate date];
                [self addAd:ads];
                
                self.splash.ads = ads;
                [[UIApplication sharedApplication].keyWindow addSubview:self.splash];
                [self.splash mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo([UIApplication sharedApplication].keyWindow);
                }];
                
                [self statAdsWithType:@"show"
                                  ads:ads.uid
                           completion:nil];
            }
            else {
                [[UIApplication sharedApplication].keyWindow addSubview:self.splash];
                [self.splash mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo([UIApplication sharedApplication].keyWindow);
                }];
                
                [self.splash hideAnimated:YES afterDelay:1.9];
            }
        });
    }];
}

#pragma mark - SplashDelegate
- (void)finishSplash:(SplashView *)splash
               delay:(NSTimeInterval)delay
          completion:(dispatch_block_t)completion {
    UIViewController *viewController = TopViewController;
    [viewController viewWillAppear:NO];

    [UIView animateWithDuration:1.0
                          delay:delay
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         splash.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [splash removeFromSuperview];
                         if (completion) {
                             completion();
                         }

                         [viewController viewDidAppear:NO];
                     }];
}

#pragma mark - 本地数据
- (NSArray *)allAds {
    return [[CacheDataSource sharedClient] getDatasWithEntityName:[AdEntity entityName]
                                                        predicate:nil
                                                  sortDescriptors:@[]];
}

- (void)fetchSplashAdsWithCompletion:(CommonBlock)completion {
    NSArray *resultArray = [self allAds];
    for (AdData *ads in resultArray) {
        NSDate *today = [NSDate date];
        if (ads.timeOn && [today compare:ads.timeOn] == NSOrderedAscending) {
            continue;
        }
        
        if (ads.timeOff && [today compare:ads.timeOff] == NSOrderedDescending) {
            continue;
        }
        
        if (ads.timeLast) {
            if (ads.cycle == AdsCycleOnce) {
                continue;
            }
            else if (ads.cycle == AdsCycleDaily && ads.timeLast.day == today.day) {
                continue;
            }
            else if (ads.cycle == AdsCycleWeekly && ads.timeLast.week == today.week) {
                continue;
            }
            else if (ads.cycle == AdsCycleHourly && ads.timeLast.hour == today.hour) {
                continue;
            }
        }
        
        if (ads.mediaVideo) {
            NSString *path = [[SDImageCache sharedImageCache] cachePathForKey:ads.mediaUrl];
            if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                continue;
            }
        }
        else if (![[SDImageCache sharedImageCache] imageFromCacheForKey:ads.mediaUrl]) {
            continue;
        }
        
        if (completion) {
            completion(YES, @{@"data":ads});
        }
        return;
    }
    
    if (completion) {
        completion(NO, nil);
    }
}

- (void)addAd:(AdData *)ad {
    // 更新广告数据
    [[CacheDataSource sharedClient] addObject:ad
                                   entityName:[AdEntity entityName]];
}

- (void)adsClicked:(AdData *)ads {
    [self statAdsWithType:@"click"
                      ads:ads.uid
               completion:nil];
    
    if ([ads.targetType isEqualToString:@"url"]) {
        Class webViewClass = NSClassFromString(@"ModWebViewStyle1ViewController");
        if (webViewClass && [[webViewClass alloc] respondsToSelector:@selector(initWithUrl:)]) {
            id webViewController = [[webViewClass alloc] performSelector:@selector(initWithUrl:)
                                                              withObject:[NSURL URLWithString:ads.targetUrl]];
            [NavigationController pushViewController:webViewController animated:YES];
        }
        
//        WebViewController *web = [[WebViewController alloc] initWithUrl:[NSURL URLWithString:ads.targetUrl]];
//        [nav pushViewController:web animated:YES];
    }
    else if ([ads.targetType isEqualToString:@"app"]) {
        
    }
    else if ([ads.targetType isEqualToString:@"blog"]) {
        
    }
    else {
        
    }
}

#pragma mark - 数据请求
- (void)prefetchVideoWithString:(NSString *)string {
    NSString *path = [[SDImageCache sharedImageCache] cachePathForKey:string];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        //file exists
        return;
    }
    
    __block BOOL caching = NO;
    [self.caching enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:string] && [obj boolValue]) {
            caching = YES;
        }
    }];
    
    if (!caching) {
        [self.caching setObject:@(YES) forKey:string];
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        manager.responseSerializer = [AFDataResponseSerializer serializer];
        [manager GET:string
          parameters:nil
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 NSData *data = responseObject;
                 if (data.length) {
                     [data writeToFile:path atomically:YES];
                 }
             }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 [self.caching setObject:@(NO) forKey:string];
             }];
    }
}

- (NSString *)cachedVideoPathWithString:(NSString *)string {
    return nil;
}

- (void)statAdsWithType:(NSString *)type
                    ads:(int64_t)uid
             completion:(CommonBlock)completion {
    
    NSDictionary *dic = @{@"type" : type,
                          @"uid" : @(uid)};
    
    [[MainInterface sharedClient] doWithMethod:@"POST"
                                     urlString:@"app/stat/ads"
                                    parameters:dic
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                           
                                       }
                                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                           
                                       }];
}

@end
