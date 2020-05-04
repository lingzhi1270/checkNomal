//
//  FriendRequestData.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FriendRequest,
    FriendResponse
} FriendMessageType;

@interface FriendRequestData : NSObject
@property (nullable, nonatomic, copy) NSString              *requestid;
@property (nullable, nonatomic, copy) NSString              *userid;
@property (nullable, nonatomic, copy) NSString              *name;
@property (nullable, nonatomic, copy) NSString              *message;
@property (nonatomic, assign)         BOOL                  accepted;
@property (nullable, nonatomic, copy) NSDate                *date;
@property (nonatomic, assign)         FriendMessageType     type;
@property (nullable, nonatomic, copy) NSString              *avatarUrl;
@property (nonatomic, assign)         BOOL                  readStatus;

+ (instancetype)requestMessageWithType:(FriendMessageType)type
                                userid:(nullable NSString *)userid
                                  name:(nullable NSString *)name
                             avatarUrl:(nullable NSString *)avatarUrl
                             requestid:(NSString *)requestid
                               message:(nullable NSString *)message
                                result:(BOOL)accepted
                                  date:(NSDate *)date
                            readStatus:(BOOL)readStatus;

@end

NS_ASSUME_NONNULL_END
