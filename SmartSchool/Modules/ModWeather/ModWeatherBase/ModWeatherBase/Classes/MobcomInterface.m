//
//  MobcomInterface.m
//  Unilife
//
//  Created by 唐琦 on 2019/7/2.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "MobcomInterface.h"
#import "AFPlainTextResponseSerializer.h"
#import "WeatherManager.h"

#define MOBCOM_APP_KEY  @"131ef6baafdc9"

@interface MobcomInterface ()

@end

@implementation MobcomInterface

+ (instancetype)sharedClient {
    static dispatch_once_t onceToken;
    static MobcomInterface *client;
    dispatch_once(&onceToken, ^{
        client = [[MobcomInterface alloc] initWithBaseURL:[NSURL URLWithString:@"http://apicloud.mob.com"]
                                     sessionConfiguration:nil];
        client.responseSerializer = [AFPlainTextResponseSerializer serializer];
    });
    
    return client;
}

- (nullable NSURLSessionTask *)doWithMethod:(NSString *)method
                                  urlString:(NSString *)urlString
                                 parameters:(id)parameters
                  constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> _Nonnull))constructingBlock
                                   progress:(void (^)(NSProgress * _Nonnull))progress
                                    success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                                    failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    if ([method isEqualToString:@"POST"]) {
        return [super POST:urlString
                parameters:parameters
 constructingBodyWithBlock:constructingBlock
                  progress:progress
                   success:success
                   failure:failure];
    }
    else if ([method isEqualToString:@"GET"]) {
        return [super GET:urlString
               parameters:parameters
                 progress:progress
                  success:success
                  failure:failure];
    }
    else {
        return nil;
    }
}

- (void)requestCityDataWithCompletion:(CommonBlock)completion {
    [self doWithMethod:@"GET"
             urlString:@"v1/weather/citys"
            parameters:@{@"key" : MOBCOM_APP_KEY} constructingBodyWithBlock:nil
              progress:nil
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                   NSArray *result = responseObject[@"result"];
                   if (result.count && completion) {
                       completion(YES, @{@"result" : result});
                   }
                   else if (completion) {
                       completion(NO, nil);
                   }
               }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                   if (completion) {
                       completion(NO, nil);
                   }
               }];
}

- (void)requestWeatherForecastWithCity:(CityData *)city
                            completion:(CommonBlock)completion {
    [self doWithMethod:@"GET"
             urlString:@"v1/weather/query"
            parameters:@{@"city" : city.district,
                         @"province" : city.province,
                         @"key" : MOBCOM_APP_KEY} constructingBodyWithBlock:nil
              progress:nil
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                   NSArray *result = responseObject[@"result"];
                   NSDictionary *weather = result.firstObject;
                   
                   if (weather) {
                       city.weather = weather;
                       [[WeatherManager shareManager] addCity:city completion:nil];
                   }
                   
                   if (weather && completion) {
                       completion(YES, @{@"weather" : weather});
                   }
                   else if (completion) {
                       completion(NO, responseObject);
                   }
               }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                   if (completion) {
                       completion(NO, nil);
                   }
               }];
}

@end
