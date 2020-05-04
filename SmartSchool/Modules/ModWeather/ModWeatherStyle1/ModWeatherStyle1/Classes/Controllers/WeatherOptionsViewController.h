//
//  WeatherOptionsViewController.h
//  Unilife
//
//  Created by 唐琦 on 2019/7/2.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/CityData.h>

@protocol WeatherOptionsDelegate <NSObject>

- (void)weatherSelectCity:(CityData *)city;

@end

@interface WeatherOptionsViewController : UIViewController

@property (nonatomic, weak) id<WeatherOptionsDelegate>      delegate;

@end
