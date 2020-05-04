//
//  LocationManager.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/21.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "LocationManager.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

@interface LocationManager () <AMapLocationManagerDelegate>
@property (nonatomic, strong) AMapLocationManager   *locationManager;
@property (nonatomic, strong) NSTimer               *locationTimer;
@property (nonatomic, assign) BOOL                  hasLocation;

@end

@implementation LocationManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static LocationManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[LocationManager alloc] init];
    });
    
    return manager;
}

- (AMapLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.locationTimeout = 2;
        _locationManager.reGeocodeTimeout = 2;
    }
    
    return _locationManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.hasLocation = NO;
        
        NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
        NSDictionary *platformInfo = infoDic[@"PlatformInfo"];
        
        if (platformInfo.count) {
            NSString *amapApiKey = platformInfo[@"AmapApiKey"];
            
            if (!amapApiKey.length) {
                NSAssert(NO, @"info.plist未配置高德地图AppKey!");
            }
            
            // 高德
            [AMapServices sharedServices].apiKey = amapApiKey;
        }
        else {
            NSAssert(NO, @"info.plist未配置第三方信息!");
        }
    }
    
    return self;
}

- (void)getLocationInfoWithCompletion:(CommonBlock)completion {
    if (!self.locationTimer) {
        // 30秒重新定位一次
        if (@available(iOS 10.0, *)) {
            self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                                 repeats:YES
                                                                   block:^(NSTimer * _Nonnull timer) {
                                                                       [self requestLocationWithCompletion:nil];
                                                                   }];
        }
        else {
            self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                                  target:self
                                                                selector:@selector(requestLocationWithCompletion:)
                                                                userInfo:nil
                                                                 repeats:YES];
        }
    }
    
    if (self.hasLocation) {
        if (completion) {
            completion(YES, nil);
        }
    }
    else {
        [self requestLocationWithCompletion:completion];
    }
}

- (void)requestLocationWithCompletion:(nullable CommonBlock)completion {
    [self.locationManager requestLocationWithReGeocode:YES
                                       completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
                                           if (regeocode) {
                                               self.hasLocation = YES;
                                               
                                               // 逆地址数据
                                               self.province            = regeocode.province;
                                               self.city                = regeocode.city;
                                               self.district            = regeocode.district;
                                               self.street              = regeocode.street;
                                               self.number              = regeocode.number;
                                               self.formattedAddress    = regeocode.formattedAddress;
                                               // 经纬度
                                               self.location            = location;
                                               
                                               if (completion) {
                                                   completion(YES, nil);
                                               }
                                           }
                                           else if (completion) {
                                               completion(NO, @{@"error":error.userInfo[NSLocalizedDescriptionKey]});
                                           }
                                       }];
}

#pragma mark - AMapLocationManagerDelegate
- (void)amapLocationManager:(AMapLocationManager *)manager doRequireLocationAuth:(CLLocationManager *)locationManager {
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
}

@end
