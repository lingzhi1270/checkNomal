//
//  AdData.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/26.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    AdsBanner,
    AdsSplash,
    AdsSpecificScreen
} AdsType;

typedef enum : NSUInteger {
    AdsCycleOnce,
    AdsCycleDaily,
    AdsCycleWeekly,
    AdsCycleHourly,
    
} AdsCycleMode;

@interface AdData : NSObject

@property (nonatomic) int64_t           uid;
@property (nonatomic) AdsType           type;
@property (nonatomic) AdsCycleMode      cycle;

@property (nullable, nonatomic, copy) NSString  *title;
@property (nullable, nonatomic, copy) NSString  *mediaUrl;
@property (nonatomic)                 BOOL      mediaVideo;
@property (nullable, nonatomic, copy) NSString  *targetType;
@property (nullable, nonatomic, copy) NSString  *targetUrl;
@property (nonatomic) int16_t duration;

@property (nonatomic, copy)           NSDate        *timeOn;
@property (nonatomic, copy)           NSDate        *timeOff;
@property (nonatomic, copy)           NSDate        *timeLast;

+ (instancetype)splashWithData:(NSDictionary *)data;


@end

NS_ASSUME_NONNULL_END
