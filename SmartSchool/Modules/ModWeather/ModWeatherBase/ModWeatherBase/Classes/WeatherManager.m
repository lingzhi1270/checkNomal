//
//  WeatherManager.m
//  Unilife
//
//  Created by 唐琦 on 2019/7/1.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "WeatherManager.h"
#import "MobcomInterface.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import <LibCoredata/CacheDataSource.h>
#import <ModLoginBase/AccountManager.h>
#import <CoreLocation/CoreLocation.h>

@interface WeatherManager ()

@property (nonatomic, copy)   NSDictionary              *weatherIcons;
@property (nonatomic, copy)   NSDictionary              *weatherImages;

@property (nonatomic, copy)   NSArray                   *backgroudImages;
@property (nonatomic, strong) AMapLocationManager       *locationManager;

@end

@implementation WeatherManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static WeatherManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [[WeatherManager alloc] init];
    });
    
    return client;
}

- (AMapLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc] init];
    }
    
    return _locationManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.weatherIcons = [NSUserDefaults weatherIcons];
        
        self.backgroudImages = @[@"http://om4cujqit.bkt.clouddn.com/weather01.jpg",
                                 @"http://om4cujqit.bkt.clouddn.com/weather02.jpg",
                                 @"http://os5hkmyhd.bkt.clouddn.com/weather03.jpg",
                                 @"http://os5hkmyhd.bkt.clouddn.com/weather04.jpg",
                                 @"http://os5hkmyhd.bkt.clouddn.com/weather05.jpg"];
    }
    
    return self;
}

#pragma mark - 本地数据
- (NSArray *)allCities {
    return [[CacheDataSource sharedClient] getDatasWithEntityName:[CityEntity entityName]
                                                        predicate:nil
                                                  sortDescriptors:@[]];
    
}

- (void)addCity:(CityData *)city completion:(nullable CommonBlock)completion {
    [[CacheDataSource sharedClient] addObject:city
                                   entityName:[CityEntity entityName]];
}

- (CityData *)nearestCityWithDistrict:(NSString *)district
                                 city:(NSString *)city
                             province:(NSString *)province {
    NSString *sub = [district substringToIndex:2];
    NSString *pro = [province substringToIndex:2];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"district CONTAINS %@ && province CONTAINS %@", sub, pro];
    NSArray *resultArr = [[CacheDataSource sharedClient] getDatasWithEntityName:[CityEntity entityName]
                                                                      predicate:predicate
                                                                sortDescriptors:@[]];
    
    CityData *cityData = nil;
    if (!resultArr.count) {
        sub = [city substringToIndex:2];
        
        predicate = [NSPredicate predicateWithFormat:@"district CONTAINS %@ && city CONTAINS %@ && province CONTAINS %@", sub, sub, pro];
        resultArr = [[CacheDataSource sharedClient] getDatasWithEntityName:[CityEntity entityName]
                                                                predicate:predicate
                                                          sortDescriptors:@[]];
        
        cityData = resultArr.firstObject;
    }
    else {
        cityData = resultArr.firstObject;
    }
    
    return cityData;
}

- (NSArray *)citiesWithName:(NSString *)name
                   selected:(NSInteger)selected {
    NSArray *allCitiesArray = [self allCities].mutableCopy;
    NSMutableArray *array = [NSMutableArray array];
    NSArray *objects;
    
    NSArray *predicates = @[[NSPredicate predicateWithFormat:@"district CONTAINS %@", name],
                            [NSPredicate predicateWithFormat:@"city CONTAINS %@", name],
                            [NSPredicate predicateWithFormat:@"province CONTAINS %@", name]];
    NSSortDescriptor *cityDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"city" ascending:NO];
    NSSortDescriptor *districtDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"district" ascending:NO];
    
    for (NSPredicate *item in predicates) {
        NSArray *tempArr = [NSArray arrayWithArray:allCitiesArray];
        tempArr = [tempArr filteredArrayUsingPredicate:item];
        tempArr = [tempArr sortedArrayUsingDescriptors:@[cityDescriptor, districtDescriptor]];
        
        for (CityData *city in objects) {
            if (![array containsObject:city]) {
                if (selected == -1 && city.selectedIndex > -1) {
                    // 需要那些未被选择的城市，比如天气设置时搜索结果
                    continue;
                }
                else if (selected == 1 && city.selectedIndex < 0) {
                    // 需要那些已经选择的城市
                    continue;
                }
                
                [array addObject:city];
            }
        }
    }
    
    if (array.count) {
        return array;
    }
    
    return @[];
}

- (NSArray *)allCitiesWithSelected:(BOOL)selected {
    NSSortDescriptor *selectedDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"selectedIndex" ascending:YES];
    NSSortDescriptor *provinceDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"province" ascending:YES];
    NSSortDescriptor *cityDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"city" ascending:YES];
    
    NSArray *resultArr = nil;
    
    if (selected) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selectedIndex >= 0"];
        
        resultArr = [[CacheDataSource sharedClient] getDatasWithEntityName:[CityEntity entityName]
                                                                          predicate:predicate
                                                                    sortDescriptors:@[selectedDescriptor, provinceDescriptor, cityDescriptor]];
    }
    else {
        resultArr = [[CacheDataSource sharedClient] getDatasWithEntityName:[CityEntity entityName]
                                                                          predicate:nil
                                                                    sortDescriptors:@[selectedDescriptor, provinceDescriptor, cityDescriptor]];
    }
    
    if (resultArr.count) {
        return resultArr;
    }
    
    return @[];
}

#pragma mark - 数据请求
- (void)cityDataWithCompletion:(CommonBlock)completion {
    NSArray *resultArray = [self allCitiesWithSelected:NO];
    if (resultArray.count < 10) {
        [[MobcomInterface sharedClient] requestCityDataWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
            NSArray *result = info[@"result"];
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
            NSString *localDistrict = [NSUserDefaults localDistrict];
            
            for (NSDictionary *province in result) {
                NSString *province_name = province[@"province"];
                NSArray *cities = province[@"city"];
                for (NSDictionary *city in cities) {
                    NSString *city_name = city[@"city"];
                    NSArray *districts = city[@"district"];
                    for (NSDictionary *district in districts) {
                        NSString *district_name = district[@"district"];
                        
                        CityData *city = [CityData new];
                        city.province = province_name;
                        city.city = city_name;
                        city.district = district_name;
                        city.selectedIndex = -1;
                        
                        if (localDistrict) {
                            if ([localDistrict containsString:city.district]) {
                                city.selectedIndex = 0;
                            }
                        }
                        
                        [array addObject:city];
                    }
                }
            }
            
            // 保存城市信息
            [[CacheDataSource sharedClient] addObjects:array
                                            entityName:[CityEntity entityName]
                                               syncAll:YES
                                         syncPredicate:nil];
            
            if (completion) {
                completion(YES, nil);
            }
        }];
    }
    else {
        if (completion) {
            completion(YES, nil);
        }
    }
}

- (void)setWeatherIcons:(NSDictionary *)weatherIcons {
    _weatherIcons = weatherIcons.copy;
    
    [NSUserDefaults saveWeatherIcons:weatherIcons];
}

- (void)requestWeatherIconsWithCompletion:(nullable CommonBlock)completion {
    [[MainInterface sharedClient] doWithMethod:@"GET"
                                        urlString:@"app/weather/icons"
                                       parameters:nil
                        constructingBodyWithBlock:nil
                                         progress:nil
                                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                              NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                              NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                              ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                              
                                              if ([error_code errorCodeSuccess]) {
                                                  NSDictionary *extra = responseObject[@"extra"];
                                                  NSArray *data = extra[@"data"];
                                                  
                                                  NSMutableDictionary *icons = [NSMutableDictionary dictionary];
                                                  NSMutableDictionary *images = [NSMutableDictionary dictionary];
                                                  
                                                  for (NSDictionary *item in data) {
                                                      NSString *weather = item[@"weather"];
                                                      NSString *url = item[@"icon_url"];
                                                      NSString *backUrl = VALIDATE_STRING(item[@"back_url"]);
                                                      
                                                      if (weather.length) {
                                                          [icons setObject:url?:@"" forKey:weather];
                                                          [images setObject:backUrl?:@"" forKey:weather];
                                                      }
                                                  }
                                                  
                                                  self.weatherIcons = icons.copy;
                                                  self.weatherImages = images.copy;
                                                  if (completion) {
                                                      completion(YES, responseObject[@"extra"]);
                                                  }
                                              }
                                              else if (completion) {
                                                  completion(NO, @{@"error_code" : error_code,
                                                                   @"error_msg" : error_msg});
                                              }
                                          }
                                          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                              if (completion) {
                                                  completion(NO, @{@"error_code" : [NSNumber commonNetError],
                                                                   @"error_msg" : [error localizedDescription]});
                                              }
                                          }];
}

- (NSString *)iconForWeather:(NSString *)weather date:(NSDate *)date {
    __block NSString *icon;
    [self.weatherIcons enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *string, BOOL * _Nonnull stop) {
        NSArray *comps = [key componentsSeparatedByString:@" "];
        for (NSString *item in comps) {
            if ([item isEqualToString:weather]) {
                icon = string;
                *stop = YES;
            }
        }
    }];
    
    return icon;
}

- (NSString *)imageForWeather:(NSString *)weather date:(NSDate *)date {
    __block NSString *image;
    [self.weatherImages enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *string, BOOL * _Nonnull stop) {
        NSArray *comps = [key componentsSeparatedByString:@" "];
        for (NSString *item in comps) {
            if ([item isEqualToString:weather]) {
                image = string;
                *stop = YES;
            }
        }
    }];
    
    if (image.length == 0) {
        return self.backgroudImages[arc4random_uniform((uint32_t)self.backgroudImages.count)];
    }
    
    return image;
}

- (void)requestLocalCityWithCompletion:(CommonBlock)completion {
    static CityData *last = nil;
    static NSDate *lastDate = nil;
    if (last && lastDate && [[NSDate date] timeIntervalSinceDate:lastDate] < 60 * 30) {
        if (completion) {
            completion(YES, @{@"city" : last});
        }
        
        return;
    }
    
    if ([CLLocationManager authorizationStatus] < kCLAuthorizationStatusAuthorizedAlways) {
        if (completion) {
            completion(NO, nil);
        }
        
        return;
    }
    
    [self.locationManager requestLocationWithReGeocode:YES
                                       completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
                                           if (regeocode) {
                                               if (regeocode.city && regeocode.district) {
                                                   CityData *city = [self nearestCityWithDistrict:regeocode.district
                                                                                             city:regeocode.city
                                                                                         province:regeocode.province];
                                                   if (city) {
                                                       last = city;
                                                       lastDate = [NSDate date];
                                                   }
                                                  
                                                   [NSUserDefaults saveLocalDistrict:regeocode.district];
                                                  
                                                   if (completion) {
                                                       completion(city != nil, city?@{@"city" : city}:nil);
                                                   }
                                               }
                                               else if (completion) {
                                                   completion(NO, nil);
                                               }
                                           }
                                           else if (completion) {
                                               completion(NO, nil);
                                           }
                                       }];
}

- (void)requestLocalWeatherLiveWithCompletion:(CommonBlock)completion {
    [self requestLocalCityWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
        if (success) {
            CityData *city = info[@"city"];
            
            [self requestWeatherWithCity:city
                              completion:completion];
        }
        else if (completion) {
            completion(NO, nil);
        }
    }];
}

- (void)requestWeatherWithCity:(CityData *)city completion:(CommonBlock)completion {
    if (!city) {
        if (completion) {
            completion(NO, nil);
        }
        
        return;
    }
    
    if (city && city.weather && [[NSDate date] timeIntervalSinceDate:city.weather_date] < 60 * 15) {
        //天气刷新间隔小于 15分钟
        if (completion) {
            completion(YES, @{@"weather" : city.weather});
        }
        
        return;
    }
    
    [[MobcomInterface sharedClient] requestWeatherForecastWithCity:city
                                                        completion:completion];
}

@end
