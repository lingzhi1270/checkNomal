//
//  UserData.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "UserData.h"

@implementation UserData

+ (instancetype)userFromData:(NSDictionary *)data {
    return [[UserData alloc] initWithData:data];
}

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        self.userid = VALIDATE_STRING(data[@"uid"]);
        self.avatarUrl = VALIDATE_STRING(data[@"avatar_url"]);
        self.name = VALIDATE_STRING(data[@"name"]);
        self.nickname = VALIDATE_STRING(data[@"nickname"]);
        self.im_id = VALIDATE_STRING(data[@"im_id"]);
        self.relation = VALIDATE_STRING(data[@"relation"]);
        self.followed_count = VALIDATE_NUMBER(data[@"followed_count"]);
        self.follower_count = VALIDATE_NUMBER(data[@"follower_count"]);
        self.topic_count = VALIDATE_NUMBER(data[@"topic_count"]);
    }
    
    return self;
}

@end
