//
//  PayManager.m
//  Unilife
//
//  Created by 唐琦 on 2019/8/3.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "PayManager.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import <ModLoginBase/AccountManager.h>

#define ALIPAY_SCHEME @"SmartSchool"

@implementation PayMethod

+ (instancetype)methodWithData:(NSDictionary *)data {
    return [[self alloc] initWithData:data];
}

+ (instancetype)methodWithImage:(UIImage *)image title:(NSString *)title method:(NSString *)method enabled:(BOOL)enabled {
    return [[self alloc] initWithImage:(UIImage *)image
                                 title:(NSString *)title
                                method:method
                               enabled:enabled];
}

- (instancetype)initWithData:(NSDictionary *)data {
    NSString *method = data[@"method"];
    NSNumber *number = data[@"enabled"];
    
    if ([method isEqualToString:@"alipay"]) {
        return [self initWithImage:[UIImage imageNamed:@"ic_pay_alipay" bundleName:@"ModPayStyle1"]
                             title:@"支付宝"
                            method:method
                           enabled:[number boolValue]];
    }
    else if ([method isEqualToString:@"wechat"]) {
        return [self initWithImage:[UIImage imageNamed:@"ic_pay_wechat" bundleName:@"ModPayStyle1"]
                             title:@"微信"
                            method:method
                           enabled:[number boolValue]];
    }
    else if ([method isEqualToString:@"unionpay"]) {
        return [self initWithImage:[UIImage imageNamed:@"ic_pay_unionpay" bundleName:@"ModPayStyle1"]
                             title:@"中国银联"
                            method:method
                           enabled:[number boolValue]];
    }
    
    return nil;
}

- (instancetype)initWithImage:(UIImage *)image
                        title:(NSString *)title
                       method:(NSString *)method
                      enabled:(BOOL)enabled {
    if (self = [super init]) {
        self.image = image;
        self.title = title;
        self.method = method;
        self.enabled = enabled;
        self.method = method;
    }
    
    return self;
}

@end

@interface PayManager () < WXApiDelegate >

@property (nonatomic, copy) NSArray<PayMethod *>    *methods;

@property (nonatomic, copy)   NSString              *orderid;
@property (nonatomic, strong) NSNumber              *amount;
@property (nonatomic, copy)   NSString              *appid;
@property (nonatomic, copy)   NSString              *productid;
@property (nonatomic, copy)   NSString              *subject;
@property (nonatomic, copy)   CommonBlock           completion;
@property (nonatomic, copy)   CommonBlock           wechatPayCompletion;

@property (nonatomic, copy)   NSString              *className;

@end

@implementation PayManager

+ (instancetype)shareManager {
    static dispatch_once_t token;
    static PayManager *client = nil;
    dispatch_once(&token, ^{
        client = [[PayManager alloc] init];
    });
    
    return client;
}

- (void)requestPayMethodWithCompletion:(CommonBlock)completion {
    [[MainInterface sharedClient] doWithMethod:@"GET"
                                     urlString:@"app/pay_method"
                                    parameters:nil
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                           NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                           NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                           ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                           
                                           if ([error_code errorCodeSuccess]) {
                                               NSDictionary *extra = responseObject[@"extra"];
                                               NSArray *data = extra[@"data"];
                                               NSMutableArray *arr = [NSMutableArray new];
                                               for (NSDictionary *item in data) {
                                                   PayMethod *method = [PayMethod methodWithData:item];
                                                   [arr addObject:method];
                                               }
                                               self.methods = arr.copy;
                                               
                                               if (completion) {
                                                   completion(arr.count > 0, nil);
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

- (void)showPayMenu {
    Class menuViewClass = NSClassFromString([NSString stringWithFormat:@"%@MenuView", @"ModPayStyle1"]);
    if (menuViewClass) {
        if ([[menuViewClass alloc] respondsToSelector:@selector(initWithMethods:)]) {
            id menu = [[menuViewClass alloc] performSelector:@selector(initWithMethods:) withObject:self.methods];
            if (menu) {
                if ([menu respondsToSelector:@selector(setDelegate:)]) {
                    [menu performSelector:@selector(setDelegate:) withObject:self];
                }
                
                [[UIApplication sharedApplication].keyWindow addSubview:menu];
                [menu mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo([UIApplication sharedApplication].keyWindow);
                }];
                
                [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
                
                if ([menu respondsToSelector:@selector(showMenuAnimated:completion:)]) {
                    [menu performSelectorWithArgs:@selector(showMenuAnimated:completion:), @YES, nil];
                }
            }
        }
    }
    
//    PayMenuView *menu = [[PayMenuView alloc] initWithMethods:self.methods];
//    menu.delegate = self;
//    [APP_DELEGATE_WINDOW addSubview:menu];
//    [menu mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(APP_DELEGATE_WINDOW);
//    }];
//
//    [APP_DELEGATE_WINDOW layoutIfNeeded];
//
//    [menu showMenuAnimated:YES completion:nil];
}

- (void)startPayWithOrder:(NSString *)orderid
                   amount:(NSNumber *)amount
                    appid:(NSString *)appid
                  product:(NSString *)productid
                  subject:(NSString *)subject
               completion:(CommonBlock)completion {
    
    self.orderid = orderid;
    self.amount = amount;
    self.appid = appid;
    self.productid = productid;
    self.subject = subject;
    self.completion = completion;

    [self requestPayMethodWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
        if (success) {
            [self showPayMenu];
        }
        else {
            [YuAlertViewController showAlertWithTitle:nil
                                               message:@"获取支付方式出错"
                                        viewController:TopViewController
                                              okTitle:YUCLOUD_STRING_OK
                                             okAction:nil
                                          cancelTitle:nil
                                         cancelAction:nil
                                           completion:nil];
        }
    }];
}

- (void)prepayWithOrder:(NSString *)orderid
                 amount:(NSNumber *)amount
                 method:(NSString *)method
                  appid:(NSString *)appid
                product:(NSString *)productid
                subject:(NSString *)subject
             completion:(CommonBlock)completion {
    
    NSDictionary *dic;
    NSString *urlString;
    NSNumber *type = @0;
    if ([method isEqualToString:@"wechat"]) {
        type = @2;
    }
    else if ([method isEqualToString:@"alipay"]) {
        type = @1;
    }
    
    if (orderid) {
        urlString = @"app/pay_order";
        dic = @{@"order_id"     : orderid,
                @"online_pay"   : type,
                @"app_id"       : appid?:@""};
    }
    else {
        urlString = @"app/pay";
        dic = @{@"amount"     : amount,
                @"subject"    : subject?:@"",
                @"online_pay" : type,
                @"app_id"     : appid?:@"",
                @"product_id" : productid?:@""};
    }
    
    [[MainInterface sharedClient] doWithMethod:@"POST"
                                        urlString:urlString
                                       parameters:dic
                        constructingBodyWithBlock:nil
                                         progress:nil
                                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                              NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                              NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                              ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                              
                                              if ([error_code errorCodeSuccess]) {
                                                  NSDictionary *extra = responseObject[@"extra"];
                                                  if (completion) {
                                                      completion(YES, extra);
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

- (void)payOrder:(NSString *)orderid
          amount:(NSNumber *)amount
          method:(NSString *)method
           appid:(NSString *)appid
         product:(NSString *)productid
         subject:(NSString *)subject
      completion:(CommonBlock)completion {
    
    [self prepayWithOrder:orderid
                   amount:amount
                   method:method
                    appid:appid
                  product:productid
                  subject:subject
               completion:^(BOOL success, NSDictionary * _Nullable info) {
                    if (success) {
                        if ([method isEqualToString:@"alipay"]) {
                            NSString *params = info[@"request_params"];
                            NSString *out_trade_no = info[@"out_trade_no"];
                            [[AlipaySDK defaultService] payOrder:params
                                                      fromScheme:ALIPAY_SCHEME
                                                        callback:^(NSDictionary *resultDic) {
                                                            NSString *status = resultDic[@"resultStatus"];
                                                            if ([status integerValue] == 9000) {
                                                                [self queryPayResultWithTradeNo:out_trade_no
                                                                                         method:method
                                                                                     completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                                                         if (completion) {
                                                                                             completion(success, @{@"success" : success?@1:@0});
                                                                                         }
                                                                                     }];
                                                            }
                                                            else if (completion) {
                                                                NSString *error_msg;
                                                                switch ([status integerValue]) {
                                                                    case 4000:
                                                                        error_msg = @"订单支付失败";
                                                                        break;
                                                                    case 6001:
                                                                        error_msg = @"用户取消";
                                                                        break;
                                                                    case 6002:
                                                                        error_msg = @"网络连接出错";
                                                                        break;
                                                                        
                                                                    default:
                                                                        error_msg = @"支付失败";
                                                                        break;
                                                                }
                                                                completion(NO, @{@"error_msg" : error_msg});
                                                            }
                                                        }];
                        }
                        else if ([method isEqualToString:@"wechat"]) {
                            PayReq *req = [[PayReq alloc] init];
                            req.partnerId = info[@"partner_id"];
                            req.prepayId = info[@"prepay_id"];
                            req.nonceStr = info[@"nonce_str"];
                            NSNumber *number = info[@"time_stamp"];
                            req.timeStamp = [number intValue];
                            
                            req.package = info[@"package"];
                            req.sign = info[@"sign"];
                            
                            self.wechatPayCompletion = completion;
                            
                            NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
                            NSDictionary *platformInfo = infoDic[@"platformInfo"];
                            
                            if (platformInfo.count) {
                                NSString *wechatAppID = platformInfo[@"WechatAppID"];
                                NSString *universalLink = platformInfo[@"UniversalLink"];
                                
                                [WXApi registerApp:wechatAppID universalLink:universalLink];
                                [WXApi sendReq:req completion:^(BOOL success) {
                                    if (!success) {
                                        if (completion) {
                                            completion(NO, nil);
                                        }
                                    }
                                }];
                            }
                            else {
//                                DDLog(@"微信appID不存在");
                            }
                            
                        }
                    }
                    else if (completion) {
                        completion(NO, info);
                    }
                }];
}

- (void)queryPayResultWithTradeNo:(NSString *)trade
                           method:(NSString *)method
                       completion:(CommonBlock)completion {
    NSDictionary *dic = @{@"out_trade_no"   : trade,
                          @"type"           : method};
    [[MainInterface sharedClient] doWithMethod:@"GET"
                                        urlString:@"app/payresult"
                                       parameters:dic
                        constructingBodyWithBlock:nil
                                         progress:nil
                                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                              NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                              NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                              ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                              
                                              if ([error_code errorCodeSuccess]) {
                                                  if (completion) {
                                                      completion(YES, nil);
                                                  }
                                              }
                                              else if (completion) {
                                                  completion(NO, nil);
                                              }
                                          }
                                          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                              if (completion) {
                                                  completion(NO, @{@"error_code" : [NSNumber commonNetError],
                                                                   @"error_msg" : [error localizedDescription]});
                                              }
                                          }];
}

#pragma mark - PayMenuDelegate

- (void)payMenuView:(id)menu didSelectedMethod:(PayMethod *)method {
    MBProgressHUD *hud = [MBProgressHUD showHudOn:[UIApplication sharedApplication].keyWindow
                                             mode:MBProgressHUDModeIndeterminate
                                            image:nil
                                          message:nil
                                        delayHide:NO
                                       completion:nil];
    
    [self payOrder:self.orderid
            amount:self.amount
            method:method.method
             appid:self.appid
           product:self.productid
           subject:self.subject
        completion:^(BOOL success, NSDictionary * _Nullable info) {
            [MBProgressHUD finishHudWithResult:success
                                           hud:hud
                                     labelText:[info errorMsg:success]
                                    completion:^{
                
                                        if ([menu respondsToSelector:@selector(dismissViewAnimated:completion:)]) {
                                            CommonBlock block = ^(BOOL success, NSDictionary * _Nullable info) {
                                                if (self.completion) {
                                                    self.completion(success, info);
                                                }
                                            };
                                            
                                            [menu performSelectorWithArgs:@selector(dismissViewAnimated:completion:), @YES, block];
                                        }
                
//                                        [menu dismissViewAnimated:YES completion:^{
//                                            if (self.completion) {
//                                                self.completion(success, info);
//                                            }
//                                        }];
                                    }];
        }];
}

- (void)payMenuViewDidCancel {
    if (self.completion) {
        self.completion(NO, nil);
    }
}

#pragma mark - WXApiDelegate

- (void)onResp:(PayResp *)resp {
    if (self.wechatPayCompletion) {
        switch (resp.errCode) {
            case 0:
                self.wechatPayCompletion(YES, @{@"error_msg" : @"支付成功"});
                break;
                
            case -2:
                self.wechatPayCompletion(NO, @{@"error_msg" : @"支付已经取消"});
                break;
                
            default:
                self.wechatPayCompletion(NO, @{@"error_msg" : @"支付失败"});
                break;
        }
    }
}

@end
