//
//  WechatInterface.h
//  YuCloud
//
//  Created by 唐琦 on 15/9/16.
//  Copyright © 2015年 VIROYAL-ELEC. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

@interface WechatInterface : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (void)getUserInfoWithAppid:(NSString *)appid
                      secret:(NSString *)secret
                        code:(NSString *)code
                  completion:(CommonBlock)completion;

@end
