//
//  FriendRequestData.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "FriendRequestData.h"

@implementation FriendRequestData

+ (instancetype)requestMessageWithType:(FriendMessageType)type
                                userid:(NSString *)userid
                                  name:(NSString *)name
                             avatarUrl:(NSString *)avatarUrl
                             requestid:(NSString *)requestid
                               message:(NSString *)message
                                result:(BOOL)accepted
                                  date:(NSDate *)date
                            readStatus:(BOOL)readStatus {
    FriendRequestData *data = [[FriendRequestData alloc] init];
    data.type = type;
    data.userid = userid;
    data.name = name;
    data.avatarUrl = avatarUrl;
    data.requestid = requestid;
    if (type == FriendRequest) {
        data.message = message;
    }
    else {
        data.message = @"加好友通知";
    }
    
    data.accepted = accepted;
    data.date = date;
    data.readStatus = readStatus;
    
    return data;
}


@end
