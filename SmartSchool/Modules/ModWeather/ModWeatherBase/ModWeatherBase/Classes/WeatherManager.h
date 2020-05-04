//
//  WeatherManager.h
//  Unilife
//
//  Created by 唐琦 on 2019/7/1.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/CityData.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeatherManager : NSObject

+ (instancetype)shareManager;

#pragma mark - 本地数据
- (void)addCity:(CityData *)city completion:(nullable CommonBlock)completion;

- (NSArray *)citiesWithName:(NSString *)name
                   selected:(NSInteger)selected;

- (NSArray *)allCitiesWithSelected:(BOOL)selected ;

- (NSString *)iconForWeather:(NSString *)weather date:(NSDate *)date;

- (NSString *)imageForWeather:(NSString *)weather date:(NSDate *)date;

#pragma mark - 数据请求
- (void)requestLocalCityWithCompletion:(nullable CommonBlock)completion;

- (void)cityDataWithCompletion:(nullable CommonBlock)completion;

- (void)requestLocalWeatherLiveWithCompletion:(nullable CommonBlock)completion;

- (void)requestWeatherWithCity:(nullable CityData *)city
                    completion:(nullable CommonBlock)completion;

- (void)requestWeatherIconsWithCompletion:(nullable CommonBlock)completion;



@end

NS_ASSUME_NONNULL_END
