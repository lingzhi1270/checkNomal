//
//  UserData.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/CommonDefs.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserData : NSObject

@property (nullable, nonatomic, copy) NSString  *avatarUrl;
@property (nullable, nonatomic, copy) NSString  *im_id;
@property (nullable, nonatomic, copy) NSString  *name;
@property (nullable, nonatomic, copy) NSString  *nickname;
@property (nullable, nonatomic, copy) NSString  *school;
@property (nullable, nonatomic, copy) NSString  *userid;
@property (nullable, nonatomic, copy) NSString  *relation;
@property (nullable, nonatomic, strong) NSNumber  *followed_count;
@property (nullable, nonatomic, strong) NSNumber  *follower_count;
@property (nullable, nonatomic, strong) NSNumber  *topic_count;

@property (nullable, nonatomic, copy) NSString  *refreshKey;

+ (instancetype)userFromData:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
