//
//  AccountManager.m
//  Unilife
//
//  Created by 唐琦 on 2019/6/14.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "AccountManager.h"
#import "WechatInterface.h"
#import <LibDataModel/PayData.h>
#import <LibDataModel/UserData.h>
#import <LibCoredata/CacheDataSource.h>
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

NSString * const YuCloudAccountSignInNotification           = @"com.viroyal.com.signin";
NSString * const YuCloudAccountSignupNotification           = @"com.viroyal.com.signup";
NSString * const YuCloudAccountKickedOffLoginNotification   = @"com.viroyal.com.account.kicked.off.login";
NSString * const YuCloudAccountKickedOffCancelNotification  = @"com.viroyal.com.account.kicked.off.cancel";
NSString * const YuCloudAccountAotuSignInFailedNotification = @"com.viroyal.com.auto.signin.failed";

#pragma mark - AccountManager
typedef NS_ENUM(NSUInteger, YuAccountStatus) {
    YuAccountStatusLogout               = 0,
    YuAccountStatusLocalSignin          = 1 << 0,
    YuAccountStatusSigninSuccess        = 1 << 2,
    
    //add new items before this line
};

@interface AccountManager () <QQApiInterfaceDelegate, WXApiDelegate, TencentSessionDelegate>
@property (nonatomic, copy)     NSString        *wechatAppID;
@property (nonatomic, copy)     NSString        *wechatAppSecret;
@property (nonatomic, copy)     NSString        *universalLink;
@property (nonatomic, copy)     NSString        *qqAppID;
@property (nonatomic, copy)     NSString        *qqAppSecret;

@property (nonatomic, strong)   TencentOAuth    *tencentOAuth;

@property (nonatomic, assign)   NSUInteger      accountStatus;
@property (nonatomic, strong)   AccountInfo     *accountInfo;

@property (nonatomic, copy)     ThirdAccountLoginCompletion     thirdLoginCompletion;
@property (nonatomic, copy)     CommonBlock                     shareCompletion;
@property (nonatomic, copy)     CommonBlock                     loginCompletion;


@end

@implementation AccountManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static AccountManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[AccountManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
        NSDictionary *platformInfo = infoDic[@"PlatformInfo"];
        
        if (platformInfo.count) {
            self.wechatAppID = platformInfo[@"WechatAppID"];
            self.wechatAppSecret = platformInfo[@"WechatAppSecret"];
            self.universalLink = platformInfo[@"UniversalLink"];
            self.qqAppID = platformInfo[@"QQAppID"];
            self.qqAppSecret = platformInfo[@"QQAppSecret"];
            
            if (!self.wechatAppID.length) {
                NSAssert(NO, @"微信AppID不存在, 请在info.plist中添加");
            }
            if (!self.wechatAppSecret.length) {
                NSAssert(NO, @"微信AppSecret不存在, 请在info.plist中添加");
            }
            if (!self.universalLink.length) {
                NSAssert(NO, @"UniversalLink不存在, 请在info.plist中添加");
            }
            
            if (!self.qqAppID.length) {
                NSAssert(NO, @"QQ的AppID不存在, 请在info.plist中添加");
            }
            if (!self.qqAppSecret.length) {
                NSAssert(NO, @"QQ的AppSecret不存在, 请在info.plist中添加");
            }
            
            [WXApi registerApp:self.wechatAppID universalLink:self.universalLink];
        }
        else {
            NSAssert(NO, @"第三方平台信息不存在, 请在info.plist中添加");
        }
    }
    
    return self;
}

- (AccountInfo *)fetchAccountInfo {
    return self.accountInfo;
}

- (BOOL)isSignin {
    return (self.accountStatus & (YuAccountStatusLocalSignin | YuAccountStatusSigninSuccess)) != 0;
}

- (BOOL)isLocalSignin {
    return (self.accountStatus & YuAccountStatusLocalSignin) != 0;
}

- (BOOL)isServerSignin {
    return (self.accountStatus & YuAccountStatusSigninSuccess) != 0;
}

- (void)setAccountStatus:(NSUInteger)status {
    if (_accountStatus == status) {
        return;
    }
    
    _accountStatus = status;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *result = [NSNumber numberWithInteger:status];
        [[NSNotificationCenter defaultCenter] postNotificationName:YuCloudAccountSignInNotification object:nil userInfo:@{@"result" : result}];
    });
}

- (BOOL)wechatAppInstalled {
    return [WXApi isWXAppInstalled];
}

- (void)startLocalSignin {
    self.accountStatus = YuAccountStatusLocalSignin;
}

- (void)startAutoLogin {
    NSString *token = [NSUserDefaults token];
    
    if (token && ![self isSignin]) {
        [self startLocalSignin];
    }
    
    if (![self isServerSignin] && [MainInterface sharedClient] && token.length) {
        [self loginWithToken:token completion:^(BOOL success, NSDictionary * _Nullable info) {
            if (success) {
                
            }
            else {
                Class loginClass = NSClassFromString(@"ModLoginStyle1ViewController");
                BaseViewController *loginVC = [[loginClass alloc] initWithTitle:@"登录" rightItem:nil];
                [loginVC setValue:self forKey:@"delegate"];
                
                MainNavigationController *nav = [[MainNavigationController alloc] initWithRootViewController:loginVC];
                [TopViewController presentViewController:nav animated:YES completion:nil];
                
                [MBProgressHUD showHudOn:TopViewController.view
                                    mode:MBProgressHUDModeText
                                   image:nil
                                 message:[info errorMsg:NO]
                               delayHide:YES
                              completion:nil];
            }
        }];
    }
    else {
        Class loginClass = NSClassFromString(@"ModLoginStyle1ViewController");
        BaseViewController *loginVC = [[loginClass alloc] initWithTitle:@"登录" rightItem:nil];
        [loginVC setValue:self forKey:@"delegate"];
        
        MainNavigationController *nav = [[MainNavigationController alloc] initWithRootViewController:loginVC];
        [TopViewController presentViewController:nav animated:YES completion:nil];
    }
}

- (void)validateLoginWithCompletion:(CommonBlock)completion {
    if ([self isServerSignin]) {
        if (completion) {
            completion(YES, nil);
        }
        
        return;
    }
    
    Class class = NSClassFromString(@"ModLoginStyle1ViewController");
    if (class) {
        BaseViewController *login = [[class alloc] initWithTitle:@"登录" rightItem:nil];
        [login setValue:self forKey:@"delegate"];
        self.loginCompletion = completion;
        
        MainNavigationController *nav = [[MainNavigationController alloc] initWithRootViewController:login];
        [TopViewController presentViewController:nav
                                        animated:YES
                                      completion:nil];
    }
}

#pragma mark - ModLoginStyle1ViewControllerDelegate
- (void)loginViewController:(BaseViewController *)loginViewController loginState:(BOOL)success {
    [loginViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (self.loginCompletion) {
        self.loginCompletion(success, nil);
        self.loginCompletion = nil;
    }
}

#pragma mark - 服务器操作
// 获取验证码
- (void)getSmsWithPhone:(NSString *)phone
             completion:(CommonBlock)completion {
    NSDictionary *dic = @{@"phone"  : phone,
                          @"reason" : @"login",
                          @"type"   : @"text"};
    
    [[MainInterface sharedClient] doWithMethod:@"GET"
                                     urlString:[[MainInterface sharedClient] serverInfo][@"GET_SMS_CODE"]
                                    parameters:dic
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                            NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                            NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                              
                                            if ([error_code errorCodeSuccess]) {
                                                if (completion) {
                                                    completion(YES, responseObject[@"extra"]);
                                                }
                                            }
                                            else if (completion) {
                                                completion(NO, @{@"error_code" : error_code,
                                                                @"error_msg" : error_msg});
                                            }
                                        }
                                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                            if (completion) {
                                                completion(NO, @{@"error_code" : [NSNumber commonNetError],
                                                                   @"error_msg" : [error localizedDescription]});
                                            }
                                        }];
}

// Emis登录
- (void)loginEmisWithUnionid:(NSString *)unionid
                    password:(NSString *)password
                  completion:(CommonBlock)completion {
    NSDictionary *dic = @{@"union_id"     : unionid,
                          @"password"     : [password MD5InShort],
                          @"sha_password" : [password sha1String],
                          @"type"         : @"default"};
    
    [[MainInterface sharedClient] doWithMethod:@"POST"
                                     urlString:[[MainInterface sharedClient] serverInfo][@"LOGIN"]
                                    parameters:dic
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                            NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                            NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                            NSDictionary *extra = responseObject[@"extra"];

                                            if ([error_code errorCodeSuccess]) {
                                                // 解析Token
                                                self.token = extra[@"token"];
                                                // 解析用户信息
                                                NSDictionary *info = extra[@"info"];
                                                self.accountInfo = [AccountInfo modelWithDictionary:info];
                                                // 登录状态改为登录成功
                                                self.accountStatus = YuAccountStatusSigninSuccess;
                                                // 存储登录用户的id和token
                                                [NSUserDefaults saveUserid:self.accountInfo.union_id];
                                                [NSUserDefaults saveToken:self.token];
                                                // 立即存储
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                if (completion) {
                                                    completion(YES, extra);
                                                }
                                            }
                                            else if (completion) {
                                                self.accountInfo = nil;
                                                [[MainInterface sharedClient] updateToken:nil userId:nil];
                                                  
                                                self.accountStatus = YuAccountStatusLogout;
                                                  
                                                completion(NO, @{@"error_code" : error_code,
                                                                 @"error_msg" : VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"")});
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                            self.accountInfo = nil;
                                            [[MainInterface sharedClient] updateToken:nil userId:nil];
                                              
                                            self.accountStatus = YuAccountStatusLogout;
                                            if (completion) {
                                                completion(NO, @{@"error_code" : [NSNumber commonNetError],
                                                                @"error_msg" : [error localizedDescription]});
                                            }
                                        }];
}

// 手机登录
- (void)loginPhoneWithUnionid:(NSString *)unionid
                      smsCode:(NSString *)smsCode
                       smsKey:(NSString *)smsKey
                   completion:(CommonBlock)completion {
    NSDictionary *dic = @{@"union_id" : unionid,
                          @"sms_code" : smsCode,
                          @"sms_key"  : smsKey,
                          @"type"     : @"phone",
                          @"group_id" : @"2"};
    
    [[MainInterface sharedClient] doWithMethod:@"POST"
                                     urlString:[[MainInterface sharedClient] serverInfo][@"LOGIN"]
                                    parameters:dic
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                            NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                            NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");

                                            NSDictionary *extra = responseObject[@"extra"];

                                            if ([error_code errorCodeSuccess]) {
                                                // 解析Token
                                                self.token = extra[@"token"];
                                                // 解析用户信息
                                                NSDictionary *info = extra[@"info"];
                                                self.accountInfo = [AccountInfo modelWithDictionary:info];
                                                // 登录状态改为登录成功
                                                self.accountStatus = YuAccountStatusSigninSuccess;
                                                // 存储登录用户的id和token
                                                [NSUserDefaults saveUserid:self.accountInfo.union_id];
                                                [NSUserDefaults saveToken:self.token];
                                                // 立即存储
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                if (completion) {
                                                    completion(YES, extra);
                                                }
                                            }
                                            else if (completion) {
                                                self.accountInfo = nil;
                                                [[MainInterface sharedClient] updateToken:nil userId:nil];
                                                  
                                                self.accountStatus = YuAccountStatusLogout;
                                                  
                                                completion(NO, @{@"error_code" : error_code,
                                                                @"error_msg" : VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"")});
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                            self.accountInfo = nil;
                                            [[MainInterface sharedClient] updateToken:nil userId:nil];
                                              
                                            self.accountStatus = YuAccountStatusLogout;
                                            if (completion) {
                                                completion(NO, @{@"error_code" : [NSNumber commonNetError],
                                                                @"error_msg" : [error localizedDescription]});
                                            }
                                        }];
}

// Token登录
- (void)loginWithToken:(NSString *)token
            completion:(CommonBlock)completion {
    NSDictionary *dic = @{@"token"  : token,
                          @"type"   : @"token"};
    
    [[MainInterface sharedClient] doWithMethod:@"POST"
                                     urlString:[[MainInterface sharedClient] serverInfo][@"LOGIN"]
                                    parameters:dic
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                            NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                            NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");

                                            NSDictionary *extra = responseObject[@"extra"];

                                            if ([error_code errorCodeSuccess]) {
                                                // 解析Token
                                                self.token = extra[@"token"];
                                                // 解析用户信息
                                                NSDictionary *info = extra[@"info"];
                                                self.accountInfo = [AccountInfo modelWithDictionary:info];
                                                // 登录状态改为登录成功
                                                self.accountStatus = YuAccountStatusSigninSuccess;
                                                // 存储登录用户的id和token
                                                [NSUserDefaults saveUserid:self.accountInfo.union_id];
                                                [NSUserDefaults saveToken:self.token];
                                                // 立即存储
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                if (completion) {
                                                    completion(YES, extra);
                                                }
                                            }
                                            else if (completion) {
                                                self.accountInfo = nil;
                                                [[MainInterface sharedClient] updateToken:nil userId:nil];
                                                  
                                                self.accountStatus = YuAccountStatusLogout;
                                                  
                                                completion(NO, @{@"error_code" : error_code,
                                                                @"error_msg" : VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"")});
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                            self.accountInfo = nil;
                                            [[MainInterface sharedClient] updateToken:nil userId:nil];
                                              
                                            self.accountStatus = YuAccountStatusLogout;
                                            if (completion) {
                                                completion(NO, @{@"error_code" : [NSNumber commonNetError],
                                                                @"error_msg" : [error localizedDescription]});
                                            }
    }];
}

- (void)logoutWithCompletion:(CommonBlock)completion {
    [NSUserDefaults saveUserid:nil];
    [NSUserDefaults saveToken:nil];
    
    [self clearAccount];
    
    if (completion) {
        completion(YES, nil);
    }
}

- (void)clearAccount {
    // 退出登录后 清除token和userid
    [[MainInterface sharedClient].requestSerializer setValue:nil forHTTPHeaderField:@"token"];
    [[MainInterface sharedClient].requestSerializer setValue:nil forHTTPHeaderField:@"account_id"];
    
    self.accountInfo = nil;
    self.accountStatus = YuAccountStatusLogout;
}

#pragma mark - TencentSessionDelegate
- (void)tencentDidLogin {
    [self.tencentOAuth getUserInfo];
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (self.thirdLoginCompletion) {
        self.thirdLoginCompletion(NO, AccountQQ, nil);
    }
}

- (void)tencentDidNotNetWork {
    if (self.thirdLoginCompletion) {
        self.thirdLoginCompletion(NO, AccountQQ, nil);
    }
}

- (void)getUserInfoResponse:(APIResponse *)response {
    if (self.thirdLoginCompletion) {
        self.thirdLoginCompletion(YES, AccountQQ, @{@"openid" : self.tencentOAuth.openId,
                                                    @"nickname" : response.jsonResponse[@"nickname"],
                                                    @"headimgurl" : response.jsonResponse[@"figureurl_qq_2"]});
    }
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        if (authResp.errCode == 0) {
            [[WechatInterface sharedClient] getUserInfoWithAppid:self.wechatAppID
                                                          secret:self.wechatAppSecret
                                                            code:authResp.code
                                                      completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                          self.thirdLoginCompletion(success, AccountWechat, info);
                                                      }];
        }
        else {
            self.thirdLoginCompletion(NO, AccountWechat, nil);
        }
    }
    else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (self.shareCompletion) {
            self.shareCompletion(YES, nil);
        }
    }
    else if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        if (self.shareCompletion) {
            self.shareCompletion(YES, nil);
        }
    }
}

- (void)isOnlineResponse:(NSDictionary *)response {
    
}

- (void)onReq:(QQBaseReq *)req {
    
}

@end
