//
//  FavData.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "FavData.h"
#import <YYKit/NSObject+YYModel.h>

@implementation FavData

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

+ (instancetype)favWithData:(NSDictionary *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [self init]) {
        NSNumber *number = VALIDATE_NUMBER(data[@"uid"]);
        if (number) {
            self.uid = [number integerValue];
        }
        
        self.type = VALIDATE_STRING(data[@"type"]);
        self.title = VALIDATE_STRING(data[@"title"]);
        self.content = VALIDATE_STRING(data[@"content"]);
        self.overview = VALIDATE_STRING(data[@"overview"]);
        self.imageUrl = VALIDATE_STRING(data[@"image_url"]);
    }
    
    return self;
}

@end
