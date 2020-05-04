//
//  WechatInterface.m
//  YuCloud
//
//  Created by 唐琦 on 15/9/16.
//  Copyright © 2015年 VIROYAL-ELEC. All rights reserved.
//

#import "WechatInterface.h"
#import "AFPlainTextResponseSerializer.h"

static NSString * const WechatServerBaseURLString = @"https://api.weixin.qq.com/";



@implementation WechatInterface

+ (instancetype)sharedClient
{
    static WechatInterface *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[WechatInterface alloc] initWithBaseURL:[NSURL URLWithString:WechatServerBaseURLString]];
        _sharedClient.responseSerializer = [AFPlainTextResponseSerializer serializer];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    return _sharedClient;
}

- (void)getUserInfoWithAppid:(NSString *)appid
                      secret:(NSString *)secret
                        code:(NSString *)code
                  completion:(CommonBlock)completion {
    NSString *string = [NSString stringWithFormat:@"/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",
                        appid, secret, code];
    
    [self GET:string
   parameters:nil
     progress:nil
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
          NSString *access_token = VALIDATE_STRING([responseObject valueForKey:@"access_token"]);
          NSString *refresh_token = VALIDATE_STRING([responseObject valueForKey:@"refresh_token"]);
          NSString *openid = VALIDATE_STRING([responseObject valueForKey:@"openid"]);
          
          if (completion && access_token && refresh_token && openid) {
              NSString *string = [NSString stringWithFormat:@"/sns/userinfo?access_token=%@&openid=%@",
                                  access_token, openid];
              
              [self GET:string
             parameters:nil
               progress:nil
                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                    NSString *nickname = [responseObject valueForKey:@"nickname"];
                    NSString *headimgurl = [responseObject valueForKey:@"headimgurl"];
                    NSString *unionid = responseObject[@"unionid"];
                    
                    NSDictionary *dic = @{@"unionid" : unionid,
                                          @"nickname" : nickname,
                                          @"headimgurl" : headimgurl};
                    
                    if (completion) {
                        completion(YES, dic);
                    }
                }
                failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                    if (completion) {
                        completion(NO, nil);
                    }
                }];
          }
          else if (completion) {
              completion(NO, @{@"error_msg" : responseObject[@"errmsg"]});
          }
      }
      failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
          if (completion) {
              completion(NO, nil);
          }
      }];
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                     progress:(void (^)(NSProgress * _Nonnull))downloadProgress
                      success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                      failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    NSURL *url = [NSURL URLWithString:URLString relativeToURL:self.baseURL];
    if (parameters) {
//        DDLog(@"WechatInterface method: GET, url: %@, parameters: \n%@", [url absoluteString], parameters);
    }
    else {
//        DDLog(@"WechatInterface method: GET, url: %@, parameters: %@", [url absoluteString], parameters);
    }
    
    return [super GET:URLString
           parameters:parameters
             progress:nil
              success:^(NSURLSessionDataTask *task, id responseObject){
//                  DDLog(@"WechatInterface success url: %@, responseObject: %@", [url absoluteString], responseObject);
                  if (success) {
                      success(task, responseObject);
                  }
              }
              failure:^(NSURLSessionDataTask *task, NSError *error){
//                  DDLog(@"WechatInterface failure url: %@, error: %@", [url absoluteString], [error localizedDescription]);
                  if (failure) {
                      failure(task, error);
                  }
              }];
}

@end
