//
//  PayManager.h
//  Unilife
//
//  Created by 唐琦 on 2019/8/3.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibDataModel/PayData.h>
#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface PayMethod : NSObject

@property (nonatomic, copy)   UIImage       *image;
@property (nonatomic, copy)   NSString      *title;
@property (nonatomic, copy)   NSString      *method;
@property (nonatomic)         BOOL          enabled;

+ (instancetype)methodWithData:(NSDictionary *)data;

+ (instancetype)methodWithImage:(UIImage *)image
                          title:(NSString *)title
                         method:(NSString *)method
                        enabled:(BOOL)enabled;

@end

@interface PayManager : BaseManager 

@property (nonatomic, readonly) NSArray<PayMethod *>    *methods;

- (void)startPayWithOrder:(nullable NSString *)orderid
                   amount:(NSNumber *)amount
                    appid:(nullable NSString *)appid
                  product:(nullable NSString *)productid
                  subject:(nullable NSString *)subject
               completion:(nullable CommonBlock)completion;




@end

NS_ASSUME_NONNULL_END
