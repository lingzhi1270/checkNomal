//
//  AFDataResponseSerializer.m
//  Unilife
//
//  Created by 唐琦 on 2019/7/25.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "AFDataResponseSerializer.h"

@implementation AFDataResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing  _Nullable *)error {
    return [NSData dataWithData:data];
}

@end
