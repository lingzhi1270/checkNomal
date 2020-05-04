//
//  SchoolData.m
//  SmartSchool
//
//  Created by 唐琦 on 2020/1/8.
//  Copyright © 2020 唐琦. All rights reserved.
//

#import "SchoolData.h"
#import <YYKit/NSObject+YYModel.h>

@implementation SchoolData

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

@end
