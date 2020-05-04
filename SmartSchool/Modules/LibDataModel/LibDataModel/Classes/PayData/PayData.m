//
//  PayData.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "PayData.h"
#import <YYKit/NSObject+YYModel.h>

@implementation PayData

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return [self modelInitWithCoder:aDecoder];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self modelCopy];
}

+ (instancetype)payWithData:(NSDictionary *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        self.uid = data[@"uid"];
        self.app_id = data[@"app_id"];
        self.product_id = data[@"product_id"];
        self.subject = data[@"subject"];
        self.type = data[@"type"];
        
        NSNumber *number = data[@"amount"];
        self.amount = [number floatValue];
        
        number = data[@"order_at"];
        if (number) {
            self.order_at = [NSDate dateWithTimeIntervalSince1970:[number integerValue]];
        }
        
        number = data[@"pay_at"];
        if (number) {
            self.pay_at = [NSDate dateWithTimeIntervalSince1970:[number integerValue]];
        }
        
        number = data[@"status"];
        if (number) {
            self.status = [number integerValue];
        }
    }
    
    return self;
}

@end
