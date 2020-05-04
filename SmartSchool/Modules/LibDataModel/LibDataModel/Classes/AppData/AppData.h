//
//  AppData.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/19.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonDefs.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    AppTypeLibrary,         //系统库
    AppTypeNative,          //原生应用
    AppTypeWeb,             //普通h5应用
    AppTypeNormal,          //php 网页
} AppType;

@interface AppCategory : NSObject

@property (nonatomic, assign)   NSInteger       uid;
@property (nonatomic, assign)   NSInteger       index;
@property (nonatomic, copy)     NSString        *name;

- (instancetype)initWithUid:(NSInteger)uid index:(NSInteger)index name:(NSString *)name;

@end

@interface AppData : NSObject

@property (nonatomic, copy)     NSString        *uid;
@property (nonatomic, copy)     NSString        *name_en;
@property (nonatomic, copy)     NSString        *name_chs;
@property (nonatomic, copy)     NSString        *homeUrl;
@property (nonatomic, copy)     NSString        *iconUrl;

@property (nonatomic, assign)   AppType         type;
@property (nonatomic, assign)   NSInteger       categoryId;
@property (nonatomic, assign)   NSInteger       categoryIndex;
@property (nonatomic, copy)     NSString        *categoryName;

@property (nonatomic, assign)   NSInteger       homeIndex;
@property (nonatomic, assign)   BOOL            admin;
@property (nonatomic, copy)     NSString        *qrKey;

+ (void)itemWithData:(NSDictionary *)data
          completion:(CommonBlock)completion;

+ (instancetype)itemWithUid:(NSString *)uid
                       type:(AppType)type
                    name_en:(nullable NSString *)name_en
                   name_chs:(nullable NSString *)name_chs
                    iconUrl:(nullable NSString *)iconUrl
                    homeURL:(nullable NSString *)homeUrl
                      admin:(BOOL)admin;

- (NSString *)name;

- (NSURL *)mainUrl;

- (NSURL *)mainUrlWithParams:(nullable NSArray<NSURLQueryItem *> *)params;

- (BOOL)needLogin;

@end

NS_ASSUME_NONNULL_END
