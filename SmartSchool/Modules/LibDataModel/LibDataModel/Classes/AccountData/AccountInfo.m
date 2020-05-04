//
//  AccountInfo.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "AccountInfo.h"
#import <LibComponentBase/CommonDefs.h>
#import <YYKit/NSObject+YYModel.h>

@implementation ThirdAccountItem

+ (instancetype)itemWithType:(LoginAccountType)type
                       image:(UIImage *)image {
    return [[ThirdAccountItem alloc] initWithType:type
                                            image:image];
}

+ (instancetype)itemWithType:(LoginAccountType)type openid:(NSString *)openid {
    return [[ThirdAccountItem alloc] initWithType:type openid:openid];
}

- (instancetype)initWithType:(LoginAccountType)type
                       image:(UIImage *)image {
    
    if (self = [super init]) {
        self.type = type;
        self.image = image;
    }
    
    return self;
}

- (instancetype)initWithType:(LoginAccountType)type openid:(NSString *)openid {
    if (self = [super init]) {
        self.type = type;
        self.openid = openid;
    }
    
    return self;
}

@end

@implementation AccountInfo

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

- (ThirdAccountItem *)loginItemWithType:(LoginAccountType)type {
    for (ThirdAccountItem *item in self.third_accounts) {
        if (item.type == type) {
            return item;
        }
    }
    
    return nil;
}

- (void)addItemWithType:(LoginAccountType)type
                   name:(NSString *)name
                 openid:(NSString *)openid {
    ThirdAccountItem *account = [ThirdAccountItem itemWithType:type openid:openid];
    account.nickname = name;
    NSMutableArray *arr = self.third_accounts.mutableCopy;
    [arr addObject:account];
    
    self.third_accounts = arr.copy;
}

- (void)removeItemWithType:(LoginAccountType)type {
    NSMutableArray *arr = [NSMutableArray array];
    for (ThirdAccountItem *item in self.third_accounts) {
        if (type != item.type) {
            [arr addObject:item];
        }
    }
    
    self.third_accounts = arr.copy;
}

@end
