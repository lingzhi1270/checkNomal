//
//  MainInterface.m
//  YuCloud
//
//  Created by 唐琦 on 15/9/8.
//  Copyright © 2015年 VIROYAL-ELEC. All rights reserved.
//

#import "MainInterface.h"

NSString * const YuCloudNetworkReachabilityNotification = @"com.viroyal.com.network.reachability";


@implementation NSNumber (YuCloud)

- (BOOL)errorCodeSuccess {
    return [self integerValue] == MainInterfaceErrorCodeSuccess;
}

+ (NSNumber *)commonNetError {
    return @(MainInterfaceErrorCodeCommonNetError);
}

- (BOOL)isCommonNetError {
    return [self integerValue] == MainInterfaceErrorCodeCommonNetError;
}

@end

@implementation NSDictionary (YuCloud)

- (NSString *)errorMsg:(BOOL)success {
    if (success) {
        return NSLocalizedString(@"Success", nil);
    }
    else {
        NSString *msg = self[@"error_msg"];
        if (msg.length == 0) {
            msg = NSLocalizedString(@"Failed", nil);
        }
        
        return msg;
    }
}

@end

@interface MainInterface ()
@property (nonatomic, assign) AFNetworkReachabilityStatus   networkReachability;

@end

@implementation MainInterface

+ (instancetype)sharedClient {
    static dispatch_once_t onceToken;
    static MainInterface *client;
    
    NSString *mainBaseUrl = @"TestBaseUrl";
//    NSString *mainBaseUrl = @"ProductBaseUrl";

    NSURL *resourceUrl = [[NSBundle mainBundle] URLForResource:@"servers" withExtension:@"plist"];
    NSDictionary *servers = [NSDictionary dictionaryWithContentsOfURL:resourceUrl];
    NSAssert(servers, @"config should not be failed");
    
    NSURL *url = [NSURL URLWithString:servers[mainBaseUrl]];
    dispatch_once(&onceToken, ^{
        client = [[MainInterface alloc] initWithBaseURL:url
                                      sessionConfiguration:nil];
        
        [client updateToken:nil userId:nil];
    });
    
    return client;
}

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration {
    if (self = [super initWithBaseURL:url sessionConfiguration:configuration]) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.requestSerializer setTimeoutInterval:YuCloudRequestTimeout];
        
        self.networkReachability = AFNetworkReachabilityStatusUnknown;
        WEAK(self, wself);
        [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status != self.networkReachability) {
//                DDLog(@"MainInterface reachability: %ld", (long)status);
                wself.networkReachability = status;
                [[NSNotificationCenter defaultCenter] postNotificationName:YuCloudNetworkReachabilityNotification
                                                                    object:nil
                                                                  userInfo:@{@"status" : [NSNumber numberWithInteger:status]}];
            }
        }];
        
        [self.reachabilityManager startMonitoring];
    }
    
    return self;
}

- (NSDictionary *)serverInfo {
    NSURL *resourceUrl = [[NSBundle mainBundle] URLForResource:@"servers" withExtension:@"plist"];
    NSDictionary *servers = [NSDictionary dictionaryWithContentsOfURL:resourceUrl];
    NSAssert(servers, @"servers.plist should not be failed");
    
    NSDictionary *dict = servers[@"InterfaceApi"];
    NSAssert(dict, @"InterfaceApi List should not be nil");
    
    return dict;
}

- (NSString *)deviceInfo {
    static NSString *string = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = [UIScreen screenSize];
        NSDictionary *info = [NSBundle mainBundle].infoDictionary;
        string = [NSString stringWithFormat:@"%@;%@;%ldx%ld;%@ %@", [UIDevice osVersion], [UIDevice osModel], (long)size.width, (long)size.height, info[@"CFBundleName"], [info objectForKey:@"CFBundleShortVersionString"]];
    });
    
    return string;
}

- (void)updateToken:(NSString *)token
             userId:(NSString *)userId {
    // 登录Token
    if (token.length) {
        [self.requestSerializer setValue:token
                      forHTTPHeaderField:@"token"];
    }
    else {
        [self.requestSerializer setValue:nil
                      forHTTPHeaderField:@"token"];
    }
    // 登录Userid
    if (userId.length) {
        [self.requestSerializer setValue:userId
                      forHTTPHeaderField:@"account_id"];
    }
    else {
        [self.requestSerializer setValue:nil
                      forHTTPHeaderField:@"account_id"];
    }
    // MasterKey
    [self.requestSerializer setValue:YuCloudMasterKey
                  forHTTPHeaderField:@"master_key"];
    // 设备信息
    [self.requestSerializer setValue:[self deviceInfo]
                  forHTTPHeaderField:@"device"];
    
    // 学校id
    if ([NSUserDefaults schoolId].length) {
        [self.requestSerializer setValue:[NSUserDefaults schoolId]
                      forHTTPHeaderField:@"school_id"];
    }
    else {
        [self.requestSerializer setValue:nil
                      forHTTPHeaderField:@"school_id"];
    }
}

- (void)updateSchoolId:(NSString *)schoolId {
    // 学校id
    if (schoolId.length) {
        [self.requestSerializer setValue:schoolId
                      forHTTPHeaderField:@"school_id"];
    }
    else {
        [self.requestSerializer setValue:nil
                      forHTTPHeaderField:@"school_id"];
    }
}

- (NSDictionary *)headerData {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSString *string = [self.requestSerializer valueForHTTPHeaderField:@"token"];
    if (string) {
        [dic setObject:string forKey:@"token"];
    }
    
    string = [self.requestSerializer valueForHTTPHeaderField:@"account_id"];
    if (string) {
        [dic setObject:string forKey:@"account_id"];
    }
    
    string = [self.requestSerializer valueForHTTPHeaderField:@"master_key"];
    if (string) {
        [dic setObject:string forKey:@"master_key"];
    }
    
    string = [self.requestSerializer valueForHTTPHeaderField:@"school_id"];
    if (string) {
        [dic setObject:string forKey:@"school_id"];
    }
    
    return dic.copy;
}

- (nullable NSURLSessionTask *)doWithMethod:(NSString *)method
                                  urlString:(NSString *)urlString
                                 parameters:(id)parameters
                  constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> _Nonnull))constructingBlock
                                   progress:(void (^)(NSProgress * _Nonnull))progress
                                    success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                                    failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    
    if ([method isEqualToString:@"POST"]) {
        if (constructingBlock) {
            return [self POST:urlString
                   parameters:parameters
    constructingBodyWithBlock:constructingBlock
                     progress:progress
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                          if (success) {
                              success(task, responseObject);
                          }
                      }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          if (failure) {
                              failure(task, error);
                          }
                      }];
        }
        else {
            return [self POST:urlString
                   parameters:parameters
                     progress:progress
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                          if (success) {
                              success(task, responseObject);
                          }
                      }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          if (failure) {
                              failure(task, error);
                          }
                      }];
        }
    }
    else if ([method isEqualToString:@"PUT"]) {
        return [self PUT:urlString
              parameters:parameters
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     if (success) {
                         success(task, responseObject);
                     }
                 }
                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     if (failure) {
                         failure(task, error);
                     }
                 }];
    }
    else if ([method isEqualToString:@"DELETE"]) {
        return [self DELETE:urlString
                 parameters:parameters
                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        if (success) {
                            success(task, responseObject);
                        }
                    }
                    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        if (failure) {
                            failure(task, error);
                        }
                    }];
    }
    else if ([method isEqualToString:@"GET"]) {
        return [self GET:urlString
              parameters:parameters
                progress:progress
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     if (success) {
                         success(task, responseObject);
                     }
                 }
                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     if (failure) {
                         failure(task, error);
                     }
                 }];
    }
    
    NSAssert(NO, @"method error");
    return nil;
}


- (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                            parameters:(id)parameters
                              progress:(void (^)(NSProgress * _Nonnull))downloadProgress
                               success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                               failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    NSURL *url = [NSURL URLWithString:URLString relativeToURL:self.baseURL];
    
//    DDLog(@"MainInterface method: GET, url: %@, parameters: %@", [url absoluteString], parameters?:@"null");
//    DDLog(@"MainInterface request headers: %@", self.requestSerializer.HTTPRequestHeaders);
    
    return [super GET:URLString
           parameters:parameters
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                  DDLog(@"MainInterface success url: %@, responseObject: %@", [url absoluteString], responseObject);
                  if (success) {
                      success(task, responseObject);
                  }
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                  DDLog(@"MainInterface failure url: %@, error: %@", [url absoluteString], [error localizedDescription]);
                  if (failure) {
                      failure(task, error);
                  }
              }];
}

- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(id)parameters
                               progress:(void (^)(NSProgress * _Nonnull))uploadProgress
                                success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                                failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    NSURL *url = [NSURL URLWithString:URLString relativeToURL:self.baseURL];
    
//    DDLog(@"MainInterface method: POST, url: %@, parameters: %@", [url absoluteString], parameters?:@"null");
//    DDLog(@"MainInterface request headers: %@", self.requestSerializer.HTTPRequestHeaders);
    
    if (parameters && ![NSJSONSerialization isValidJSONObject:parameters]) {
        if (failure) {
            failure(nil, [NSError errorWithDomain:NSURLErrorDomain code:-1000 userInfo:@{NSLocalizedDescriptionKey: @"打包参数非法，暂时不支持"}]);
        }
        
        return nil;
    }
    
    return [super POST:URLString
            parameters:parameters
              progress:uploadProgress
               success:^(NSURLSessionDataTask *task, id responseObject) {
//                   DDLog(@"MainInterface success url: %@, responseObject: %@", [url absoluteString], responseObject);
                   if (success) {
                       success(task, responseObject);
                   }
               }
               failure:^(NSURLSessionDataTask *task, NSError *error) {
//                   DDLog(@"MainInterface failure url: %@, error: %@", [url absoluteString], [error localizedDescription]);
                   if (failure) {
                       failure(task, error);
                   }
               }];
}

- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(id)parameters
              constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> _Nonnull))block
                               progress:(void (^)(NSProgress * _Nonnull))uploadProgress
                                success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                                failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    NSURL *url = [NSURL URLWithString:URLString relativeToURL:self.baseURL];
    
//    DDLog(@"MainInterface method: POST, url: %@, parameters: %@", [url absoluteString], parameters?:@"null");
//    DDLog(@"MainInterface request headers: %@", self.requestSerializer.HTTPRequestHeaders);
    
    return [super POST:URLString
            parameters:parameters constructingBodyWithBlock:block
              progress:uploadProgress
               success:^(NSURLSessionDataTask *task, id responseObject) {
//                   DDLog(@"MainInterface success url: %@, responseObject: %@", [url absoluteString], responseObject);
                   if (success) {
                       success(task, responseObject);
                   }
               }
               failure:^(NSURLSessionDataTask *task, NSError *error) {
//                   DDLog(@"MainInterface failure url: %@, error: %@", [url absoluteString], [error localizedDescription]);
                   if (failure) {
                       failure(task, error);
                   }
               }];
}

- (NSURLSessionDataTask *)PUT:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                      failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    
    NSURL *url = [NSURL URLWithString:URLString relativeToURL:self.baseURL];
    
//    DDLog(@"MainInterface method: PUT, url: %@, parameters: \n%@", [url absoluteString], parameters);
//    DDLog(@"MainInterface request headers: %@", self.requestSerializer.HTTPRequestHeaders);
    
    return [super PUT:URLString
           parameters:parameters
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                  DDLog(@"MainInterface success url: %@, responseObject: %@", [url absoluteString], responseObject);
                  if (success) {
                      success(task, responseObject);
                  }
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                  DDLog(@"MainInterface failure url: %@, error: %@", [url absoluteString], [error localizedDescription]);
                  if (failure) {
                      failure(task, error);
                  }
              }];
}

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                         failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    
    NSURL *url = [NSURL URLWithString:URLString relativeToURL:self.baseURL];
    
//    DDLog(@"MainInterface method: DELETE, url: %@, parameters: %@", [url absoluteString], parameters?:@"null");
//    DDLog(@"MainInterface request headers: %@", self.requestSerializer.HTTPRequestHeaders);
    
    return [super DELETE:URLString
              parameters:parameters
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                     DDLog(@"MainInterface success url: %@, responseObject: %@", [url absoluteString], responseObject);
                     if (success) {
                         success(task, responseObject);
                     }
                 }
                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                     DDLog(@"MainInterface failure url: %@, error: %@", [url absoluteString], [error localizedDescription]);
                     if (failure) {
                         failure(task, error);
                     }
                 }];
}

- (BOOL)isReachable {
    return [self.reachabilityManager isReachable];
}

+ (NSString *)getErrorMsgForResult:(NSDictionary *)result {
    NSString *error_msg = result[@"error_msg"];
    if ([error_msg length]) {
        return error_msg;
    }
    
    NSNumber *error_code = [result valueForKey:@"error_code"];
    return [MainInterface getErrorMsg:[error_code integerValue]];
}

+ (NSString *)getErrorMsg:(MainInterfaceErrorCode)code
{
    switch (code)
    {
        case MainInterfaceErrorCodeNumberAlreadyRegistered:
            return NSLocalizedString(@"Number already registered", nil);
           
        case MainInterfaceErrorCodeNumberAlreadyUsed:
            return NSLocalizedString(@"Number already used", nil);
        case MainInterfaceErrorCodeParamError:
            return NSLocalizedString(@"Param error", nil);
        case MainInterfaceErrorCodeAccountPasswordFail:
            return NSLocalizedString(@"Login account or password error", nil);
        case MainInterfaceErrorCodeBindAuthSuccessBefore:
            return NSLocalizedString(@"Bind auth sucess before", nil);
        case MainInterfaceErrorCodeBindFailNotAdmin:
            return NSLocalizedString(@"Bind fail not admin", nil);
        case MainInterfaceErrorCodeBindFailRejected:
            return NSLocalizedString(@"Bind fail rejected", nil);
        case MainInterfaceErrorCodeDeviceUnbinded:
            return NSLocalizedString(@"Unbind fail device not binded", nil);
        case MainInterfaceErrorCodeSystemBusy:
            return NSLocalizedString(@"System busy, try later", nil);
        case MainInterfaceErrorCodeTokenExpired:
            return NSLocalizedString(@"Login expired", nil);
        case MainInterfaceErrorCodeOldPasswordWrong:
            return NSLocalizedString(@"Old password wrong", nil);
        case MainInterfaceErrorCodeQRCodeError:
            return NSLocalizedString(@"QR code recognition failed", nil);
        case MainInterfaceErrorCodePhoneFormatError:
            return NSLocalizedString(@"Phone format error", nil);
        case MainInterfaceErrorCodeSmsVerifyError:
            return NSLocalizedString(@"Sms verify error", nil);
        case MainInterfaceErrorCodeApiVersionFail:
            return NSLocalizedString(@"Api version fail", nil);
        case MainInterfaceErrorCodeSetNumberFailed:
            return NSLocalizedString(@"Set watch number failed", nil);
        case MainInterfaceErrorCodeContactAlreadyUsed:
            return NSLocalizedString(@"Contact already used", nil);
        case MainInterfaceErrorCodeDeviceOffline:
            return NSLocalizedString(@"Device offline", nil);
        case MainInterfaceErrorCodeNumberNotRegistered:
            return NSLocalizedString(@"Phone not registered", nil);
        case MainInterfaceErrorCodeFenceNameAlreadyUsed:
            return NSLocalizedString(@"Fence name already used", nil);
        case MainInterfaceErrorCodeThirdAccountAlreadyUsed:
            return NSLocalizedString(@"Third account already used", nil);
        case MainInterfaceErrorCodeThirdAuthFailed:
            return NSLocalizedString(@"Third account authorize failed", nil);
        case MainInterfaceErrorCodeThirdAuthUserCanceled:
            return NSLocalizedString(@"Third account authorize user canceled", nil);
        case MainInterfaceErrorCodeCmdRspDeviceError:
            return NSLocalizedString(@"Device failed to excute the command", nil);
        case MainInterfaceErrorCodeCmdTimeout:
            return NSLocalizedString(@"Command execute time out", nil);
        case MainInterfaceErrorCodeServerTimeout:
            return NSLocalizedString(@"Server time out", nil);
        case MainInterfaceErrorCodeSmsVerifyExceeded:
            return NSLocalizedString(@"Sms verify exceeded limit", nil);
        case MainInterfaceErrorCodeItemDeleted:
            return NSLocalizedString(@"Item was deleted", nil);
        case MainInterfaceErrorCodeFenceRegionDuplicate:
            return NSLocalizedString(@"Fence region duplicate", nil);
        case MainInterfaceErrorCodeDeviceNotActivated:
            return NSLocalizedString(@"Device not activated message", nil);
        case MainInterfaceErrorCodeBindRelationNotExist:
            return NSLocalizedString(@"Bind relation not exist", nil);
        case MainInterfaceErrorCodeSecurityCodeError:
            return NSLocalizedString(@"Security code error", nil);
        case MainInterfaceErrorCodeReachedMax:
            return NSLocalizedString(@"Reached maximum", nil);
            
        case MainInterfaceErrorCodeSigninInfoError:
            return NSLocalizedString(@"Please sign in", nil);
            
        default:
//            DDLog(@"getErrorMsg message not defined for code: %ld", (long)code);
            return [NSString stringWithFormat:@"%@ code: %ld", YUCLOUD_STRING_FAILED, (long)code];
            break;
    }
}

- (void)headURL:(NSURL *)url {
    [[MainInterface sharedClient] HEAD:@"asdf"
                               parameters:nil
                                  success:^(NSURLSessionDataTask * _Nonnull task) {
                                      
                                  }
                                  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                      
                                  }];
}

@end
