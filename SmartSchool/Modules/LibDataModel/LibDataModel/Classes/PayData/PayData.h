//
//  PayData.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PayData : NSObject

@property (nonatomic) float amount;
@property (nonatomic) int16_t status;

@property (nullable, nonatomic, copy) NSString      *app_id;
@property (nullable, nonatomic, copy) NSDate        *order_at;
@property (nullable, nonatomic, copy) NSDate        *pay_at;
@property (nullable, nonatomic, copy) NSString      *product_id;
@property (nullable, nonatomic, copy) NSString      *subject;
@property (nullable, nonatomic, copy) NSString      *type;
@property (nullable, nonatomic, copy) NSString      *uid;

@property (nullable, nonatomic, copy) NSDate        *date;

+ (instancetype)payWithData:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
