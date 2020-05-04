//
//  CameraData.m
//  Unilife
//
//  Created by 唐琦 on 2019/9/7.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "CameraData.h"

@implementation CameraTaskData

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

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSNumber *number = VALIDATE_NUMBER(dic[@"date_pub"]);
    if ([number integerValue] > 0) {
        self.datePub = [NSDate dateWithTimeIntervalSince1970:[number integerValue]];
    }
    
    number = VALIDATE_NUMBER(dic[@"date_end"]);
    if ([number integerValue] > 0) {
        self.dateEnd = [NSDate dateWithTimeIntervalSince1970:[number integerValue]];
    }
    
    return YES;
}

+ (instancetype)taskWithData:(NSDictionary *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [self init]) {
        NSNumber *number = VALIDATE_NUMBER(data[@"uid"]);
        self.uid = [number integerValue];
        self.name = VALIDATE_STRING(data[@"name"]);
        
        number = VALIDATE_NUMBER(data[@"total"]);
        self.total = [number integerValue];
        if (self.total == 0) {
            //非法采集任务，直接不展示
            return nil;
        }
        
        number = VALIDATE_NUMBER(data[@"finished"]);
        self.finished = [number integerValue];
        
        number = VALIDATE_NUMBER(data[@"date_pub"]);
        if ([number integerValue] > 0) {
            self.datePub = [NSDate dateWithTimeIntervalSince1970:[number integerValue]];
        }
        
        number = VALIDATE_NUMBER(data[@"date_end"]);
        if ([number integerValue] > 0) {
            self.dateEnd = [NSDate dateWithTimeIntervalSince1970:[number integerValue]];
        }
    }
    
    return self;
}

@end

@implementation CameraPhotoData

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

+ (instancetype)dataWithData:(NSDictionary *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        NSNumber *number = VALIDATE_NUMBER(data[@"uid"]);
        self.uid = [number integerValue];
        self.name = VALIDATE_STRING(data[@"name"]);
        NSString *imageUrl = VALIDATE_STRING(data[@"image_url"]);
        if (imageUrl && ![imageUrl containsString:@"%"]) {
            imageUrl = [imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        self.image_url = imageUrl;
        
        self.number = VALIDATE_STRING(data[@"number"]);
    }
    
    return self;
}

@end
