//
//  AccountInfo.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    AccountDefault,
    AccountToken,
    AccountPhone,
    AccountWechat,
    AccountQQ,
    AccountEMIS
} LoginAccountType;

#pragma mark - 第三方block
typedef void (^ThirdAccountLoginCompletion)(BOOL success, LoginAccountType type, NSDictionary * _Nullable info);


#pragma mark - 第三方数据模型
@interface ThirdAccountItem : NSObject
@property (nonatomic, assign) LoginAccountType  type;
@property (nonatomic, strong) UIImage           *image;

@property (nonatomic, copy)   NSString          *openid;
@property (nonatomic, copy)   NSString          *nickname;
@property (nonatomic, copy)   NSString          *avatarUrl;
@property (nonatomic, copy)   NSString          *smsKey;
@property (nonatomic, copy)   NSString          *smsCode;

+ (instancetype)itemWithType:(LoginAccountType)type
                       image:(nullable UIImage *)image;

+ (instancetype)itemWithType:(LoginAccountType)type
                      openid:(NSString *)openid;

@end

#pragma mark - 用户信息数据模型
@interface AccountInfo : NSObject
//info
@property (nullable, nonatomic, copy)  NSString         *union_id;
@property (nullable, nonatomic, copy)  NSString         *group_id;
@property (nullable, nonatomic, copy)  NSString         *name;
@property (nullable, nonatomic, copy)  NSString         *avatar_url;
@property (nullable, nonatomic, copy)  NSString         *phone;
@property (nullable, nonatomic, copy)  NSString         *gender;
@property (nullable, nonatomic, copy)  NSString         *type;

@property(nullable, nonatomic, strong) NSArray          *third_accounts;

+ (instancetype)infoFromData:(NSDictionary *)data;

- (instancetype)initWithUserid:(NSString *)userid
                       token:(NSString *)token;

- (nullable ThirdAccountItem *)loginItemWithType:(LoginAccountType)type;

- (void)addItemWithType:(LoginAccountType)type
                   name:(NSString *)name
                 openid:(NSString *)openid;

- (void)removeItemWithType:(LoginAccountType)type;

@end

NS_ASSUME_NONNULL_END
