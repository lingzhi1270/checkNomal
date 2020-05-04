//
//  CommonCheckData.h
//  AFNetworking
//
//  Created by lingzhi on 2020/1/10.
//

#import <LibComponentBase/ConfigureHeader.h>
NS_ASSUME_NONNULL_BEGIN

@interface CommonCheckData : NSObject
@property (nullable, nonatomic, strong)NSNumber         *mainKeyId;
@property (nullable, nonatomic, copy)  NSString         *name;
@property (nullable, nonatomic, strong)NSNumber         *object;
@property (nullable, nonatomic, copy)  NSString         *image_url;
@property (nullable, nonatomic, strong)NSNumber         *role;
@end

@interface CalendarData : NSObject
@property (nullable, nonatomic, copy)  NSString         *title;
@property (nullable, nonatomic, copy)  NSString         *year;
@property (nullable, nonatomic, strong)NSNumber         *semester;//学期 （1-第一学期、2-第二学期）
@property (nullable, nonatomic, copy)  NSString         *start_time;
@property (nullable, nonatomic, copy)  NSString         *end_time;
@end

NS_ASSUME_NONNULL_END
