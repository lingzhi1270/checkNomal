//
//  LocationManager.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/21.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationManager : BaseManager
@property (nonatomic, copy) NSString *province;             // 省
@property (nonatomic, copy) NSString *city;                 // 市
@property (nonatomic, copy) NSString *district;             // 区
@property (nonatomic, copy) NSString *street;               // 街道
@property (nonatomic, copy) NSString *number;               // 门牌号
@property (nonatomic, copy) NSString *formattedAddress;     // 格式化地址
@property (nonatomic, strong) CLLocation *location;         // 经纬度

- (void)getLocationInfoWithCompletion:(nullable CommonBlock)completion;

@end

NS_ASSUME_NONNULL_END
