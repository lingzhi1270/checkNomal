//
//  WeatherPageViewController.h
//  Unilife
//
//  Created by 唐琦 on 2019/7/2.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/CityData.h>

@interface WeatherPageViewController : UIViewController
@property (nonatomic, readonly) CityData        *city;

- (instancetype)initWithCity:(CityData *)city;

@end
