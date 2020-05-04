//
//  AccountManager.h
//  Unilife
//
//  Created by 唐琦 on 2019/6/14.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/AccountInfo.h>

/*
 *  Account 相关
 */

#define ACCOUNT_USERID                          [AccountManager shareManager].accountInfo.union_id
#define ACCOUNT_TOKEN                           [AccountManager shareManager].token
#define ACCOUNT_PHONE                           [AccountManager shareManager].accountInfo.phone
#define ACCOUNT_NAME                            [AccountManager shareManager].accountInfo.name

//返回token 是否失效，在网络请求返回时判断
#define ACCOUNT_ENSURE_TOKEN(error_code, error_msg)                                         \
            if([error_code integerValue] == MainInterfaceErrorCodeTokenExpired) {                \
                [[AccountManager shareManager] clearAccount];                                \
                if(completion) {                                                                    \
                    completion(NO, @{@"error_code" : error_code, @"error_msg" : error_msg?:@""});   \
                }                                                                                   \
                return;                                                                             \
            }

//登录状态是否有效，在网络接口调用前使用
#define ACCOUNT_SIGNIN_VALID(block)                                                     \
        if([[AccountManager shareManager].token length] == 0) {                              \
            if(block) {                                                                 \
                NSDictionary *result = @{@"error_code" : [NSNumber numberWithInteger:MainInterfaceErrorCodeSigninInfoError]};    \
                block(NO, result);                                                      \
            }                                                                           \
            return;                                                                     \
        }

#define ACCOUNT_SHOW_TOKEN_EXPIRED_ALERT(error_code, popOnViewController)                       \
        if([error_code integerValue] == MainInterfaceErrorCodeTokenExpired) {                \
            if (popOnViewController.presentedViewController) {                                  \
                [popOnViewController dismissViewControllerAnimated:NO completion:nil];          \
            }                                                                                   \
            [YuAlertViewController showAlertWithTitle:@""                                       \
                                              message:NSLocalizedString(@"Login expired", nil)  \
                                       viewController:popOnViewController                       \
                                              okTitle:NSLocalizedString(@"Login", nil)        \
                                             okAction:^(UIAlertAction *action){                 \
                                                [[NSNotificationCenter defaultCenter] postNotificationName:YuCloudAccountKickedOffLoginNotification object:nil userInfo:nil];}  \
                                          cancelTitle:YUCLOUD_STRING_CANCEL                     \
                                         cancelAction:^(UIAlertAction *action){                 \
                                                [[NSNotificationCenter defaultCenter] postNotificationName:YuCloudAccountKickedOffCancelNotification object:nil userInfo:nil];} \
                                           completion:nil];                                     \
        }



typedef enum : NSUInteger {
    QRUser,
    
} QRType;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const YuCloudAccountSignInNotification;
extern NSString * const YuCloudAccountSignupNotification;
extern NSString * const YuCloudAccountKickedOffLoginNotification;
extern NSString * const YuCloudAccountKickedOffCancelNotification;
extern NSString * const YuCloudAccountAotuSignInFailedNotification;

@interface AccountManager : BaseManager
@property (nonatomic, strong, readonly) AccountInfo *accountInfo;
@property (nullable, nonatomic, copy)  NSString     *token;

- (AccountInfo *)fetchAccountInfo;
- (BOOL)isSignin;
- (BOOL)isLocalSignin;
- (BOOL)isServerSignin;

- (void)startAutoLogin;

- (BOOL)wechatAppInstalled;

- (void)validateLoginWithCompletion:(CommonBlock)completion;


/* 获取验证码
 @param phone 手机号
 @param completion 回调
*/
- (void)getSmsWithPhone:(NSString *)phone
             completion:(CommonBlock)completion;


/* Emis登录
 @param unionid Emis账号
 @param password 密码
 @param completion 回调
*/
- (void)loginEmisWithUnionid:(nullable NSString *)unionid
                    password:(nullable NSString *)password
                  completion:(nullable CommonBlock)completion;

/* 手机登录
 @param unionid 手机号
 @param smsCode 验证码
 @param smsKey 验证码key
 @param completion 回调
 */
- (void)loginPhoneWithUnionid:(NSString *)unionid
                      smsCode:(NSString *)smsCode
                       smsKey:(NSString *)smsKey
                   completion:(CommonBlock)completion;

- (void)logoutWithCompletion:(CommonBlock)completion;

- (void)clearAccount;

@end

NS_ASSUME_NONNULL_END
