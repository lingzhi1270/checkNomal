//
//  MainInterface.h
//  YuCloud
//
//  Created by 唐琦 on 15/9/8.
//  Copyright © 2015年 VIROYAL-ELEC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "ConfigureHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (YuCloud)

- (BOOL)errorCodeSuccess;
+ (NSNumber *)commonNetError;
- (BOOL)isCommonNetError;

@end

@interface NSDictionary (YuCloud)

- (NSString *)errorMsg:(BOOL)success;

@end

typedef NS_ENUM(NSInteger, MainInterfaceErrorCode)
{
    MainInterfaceErrorCodeSuccess                                = 1000,
    MainInterfaceErrorCodeParamError                             = 1001,
    MainInterfaceErrorCodeSystemBusy                             = 1002,
    MainInterfaceErrorCodeBindNeedSmsVerify                      = 1003,
    MainInterfaceErrorCodeSmsVerifyError                         = 1004,
    MainInterfaceErrorCodeBindStudentFirst                       = 1005,
    MainInterfaceErrorCodeReachedMax                             = 1006,
    MainInterfaceErrorCodeItemDeleted                            = 1007,
    MainInterfaceErrorCodeServerTimeout                          = 1008,
    MainInterfaceErrorCodePhoneFormatError                       = 1009,
    MainInterfaceErrorCodeQRCodeError                            = 1011,
    MainInterfaceErrorCodeSmsVerifyExceeded                      = 1012,
    
    MainInterfaceErrorCodeTokenExpired                           = 1055,
    MainInterfaceErrorCodeNumberAlreadyUsed                      = 2003,
    MainInterfaceErrorCodeNumberNotRegistered                    = 2004,
    MainInterfaceErrorCodeAccountPasswordFail                    = 2006,
    MainInterfaceErrorCodeOldPasswordWrong                       = 2009,
    MainInterfaceErrorCodeApiVersionFail                         = 2010,
    MainInterfaceErrorCodeThirdAccountAlreadyUsed                = 2011,
    MainInterfaceErrorCodeAccountWithNoPassword                  = 2012,
    MainInterfaceErrorCodeNumberAlreadyRegistered                = 2051,
    
    MainInterfaceErrorCodeCmdSentSuccess                         = 3001,
    MainInterfaceErrorCodeCmdTimeout                             = 3002,
    MainInterfaceErrorCodeDeviceOffline                          = 3003,
    MainInterfaceErrorCodeDeviceNotActivated                     = 3007,
    MainInterfaceErrorCodeBindRelationNotExist                   = 3010,
    MainInterfaceErrorCodeWaitAuth                               = 3012,
    MainInterfaceErrorCodeSetNumberFailed                        = 3014,
    MainInterfaceErrorCodeContactAlreadyUsed                     = 3015,
    MainInterfaceErrorCodeFenceNameAlreadyUsed                   = 3016,
    MainInterfaceErrorCodeFenceRegionDuplicate                   = 3017,
    MainInterfaceErrorCodeBindNeedSecurityCode                   = 3019,
    MainInterfaceErrorCodeSecurityCodeError                      = 3020,
    
    MainInterfaceErrorCodeBindFailNotAdmin                       = 3251,
    MainInterfaceErrorCodeBindFailRejected                       = 3252,
    MainInterfaceErrorCodeBindAuthSuccessBefore                  = 3253,
    
    MainInterfaceErrorCodeDeviceUnbinded                         = 3301,
    
    MainInterfaceErrorCodeCmdRspSuccess                          = 9000,
    MainInterfaceErrorCodeCmdRspDeviceError                      = 9003,
    
    //自定义的一些错误码
    MainInterfaceErrorCodeSigninInfoError                        = -100,
    MainInterfaceErrorCodeThirdAuthFailed                        = -101,
    MainInterfaceErrorCodeThirdAuthUserCanceled                  = -102,
    
    MainInterfaceErrorCodeCommonNetError                         = -200,

};

#define YuCloudRequestTimeout           15
#define YuCloudMasterKey                @"abcdefghijkopqrstuvwxyz123456"

extern NSString * const YuCloudNetworkReachabilityNotification;

@interface MainInterface : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (void)updateToken:(nullable NSString *)token
             userId:(nullable NSString *)userId;

- (void)updateSchoolId:(NSString *)schoolId;

- (NSDictionary *)headerData;

- (nullable NSURLSessionTask *)doWithMethod:(NSString *)method
                                  urlString:(NSString *)urlString
                                 parameters:(nullable id)parameters
                  constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))constructingBlock
                                   progress:(nullable void (^)(NSProgress *progress))progress
                                    success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;


+ (NSString *)getErrorMsgForResult:(nullable NSDictionary *)result;
+ (NSString *)getErrorMsg:(MainInterfaceErrorCode)code;

- (BOOL)isReachable;

- (void)headURL:(NSURL *)url;

- (NSDictionary *)serverInfo;

@end

NS_ASSUME_NONNULL_END
