//
//  CityData.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CityData : NSObject
@property (nonatomic, copy)   NSString      *uuid;
@property (nonatomic, copy)   NSString      *province;
@property (nonatomic, copy)   NSString      *city;
@property (nonatomic, copy)   NSString      *district;
@property (nonatomic, assign) int16_t       selectedIndex;

@property (nonatomic, copy)   NSDictionary  *weather;
@property (nonatomic, copy)   NSDate        *weather_date;

@end

NS_ASSUME_NONNULL_END
