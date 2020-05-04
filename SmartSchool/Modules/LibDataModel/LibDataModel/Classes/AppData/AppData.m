//
//  AppData.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/19.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "AppData.h"
#import <YYKit/NSObject+YYModel.h>

@implementation AppCategory

- (instancetype)initWithUid:(NSInteger)uid
                      index:(NSInteger)index
                       name:(NSString *)name {
    if (self = [self init]) {
        self.uid = uid;
        self.index = index;
        self.name = name;
    }
    
    return self;
}

@end

@interface AppData ()

@end

@implementation AppData

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return [self modelInitWithCoder:aDecoder];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self modelCopy];
}

+ (void)itemWithData:(NSDictionary *)data
          completion:(CommonBlock)completion {
    NSString *uid = data[@"uid"];
    NSString *homeUrl = data[@"home_url"];
    NSString *iconUrl = data[@"icon_url"];
    NSString *name = data[@"name"];
    NSString *type = data[@"type"];
    NSNumber *category = data[@"category_id"];
    
    homeUrl = [homeUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    AppType appType;
    if ([type isEqualToString:@"library"]) {
        appType = AppTypeLibrary;
    }
    else if ([type isEqualToString:@"native"]) {
        appType = AppTypeNative;
    }
    else if ([type isEqualToString:@"normal"]) {
        appType = AppTypeNormal;
    }
    else {
        appType = AppTypeWeb;
    }
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[name dataUsingEncoding:NSUTF8StringEncoding]
                                                        options:0
                                                          error:nil];
    
//    [[AppManager shareManager] appWithUid:uid completion:^(BOOL success, NSDictionary * _Nullable info) {
//        AppData *app = info[@"data"];
//        
//        if (!app) {
//            app = [[AppData alloc] initWithUid:uid
//                                          type:appType
//                                       name_en:dic[@"en-us"]
//                                      name_chs:dic[@"zh-Hans"]
//                                       iconUrl:iconUrl
//                                       homeUrl:homeUrl
//                                         admin:NO];
//        }
//        else {
//            //可能有更新
//            app.type = appType;
//            app.name_en = dic[@"en-us"];
//            app.name_chs = dic[@"zh-Hans"];
//            app.iconUrl = iconUrl;
//            app.homeUrl = homeUrl;
//        }
//        
//        NSArray *cateData = [HomeManager shareManager].appCateData;
//        BOOL found = NO;
//        for (AppCategory *item in cateData) {
//            if (item.uid == [category integerValue]) {
//                app.categoryId = item.uid;
//                app.categoryIndex = item.index;
//                app.categoryName = item.name;
//                
//                found = YES;
//                break;
//            }
//        }
//        
//        if (!found) {
//            app.categoryId = 100;
//            app.categoryIndex = 100;
//            app.categoryName = @"未分类";
//        }
//        
//        app.qrKey = VALIDATE_STRING(data[@"qr_key"]);
//        
//        if (completion) {
//            completion(YES, @{@"data":app});
//        }
//    }];
}

+ (instancetype)itemWithUid:(NSString *)uid
                       type:(AppType)type
                    name_en:(NSString *)name_en
                   name_chs:(NSString *)name_chs
                    iconUrl:(NSString *)iconUrl
                    homeURL:(NSString *)homeUrl
                      admin:(BOOL)admin {
    return [[self alloc] initWithUid:uid
                                type:type
                             name_en:name_en
                            name_chs:name_chs
                             iconUrl:iconUrl
                             homeUrl:homeUrl
                               admin:admin];
}

- (instancetype)initWithUid:(NSString *)uid
                       type:(AppType)type
                    name_en:(NSString *)name_en
                   name_chs:(NSString *)name_chs
                    iconUrl:(NSString *)iconUrl
                    homeUrl:(NSString *)homeUrl
                      admin:(BOOL)admin {
    if (self = [self init]) {
        self.uid = uid;
        self.type = type;
        self.name_en = name_en;
        self.name_chs = name_chs;
        self.iconUrl = iconUrl;
        self.homeUrl = homeUrl;
        self.admin = admin;
        
        self.homeIndex = -1;
    }
    
    return self;
}

- (NSString *)name {
    return self.name_chs;
}

- (NSURL *)mainUrl {
    return [self mainUrlWithParams:nil];
}

//- (NSURL *)mainUrlWithParams:(NSArray<NSURLQueryItem *> *)params {
//    NSURL *url = [NSURL URLWithString:self.homeUrl];
//    
//    NSMutableArray *queryItems = [NSMutableArray array];
//    NSURLComponents *comps = [NSURLComponents componentsWithString:self.homeUrl];
//    
//    AccountInfo *info = [AccountManager shareManager].accountInfo;
//    for (NSURLQueryItem *item in comps.queryItems) {
//        if ([item.name isEqualToString:@"userid"] || [item.name isEqualToString:@"user_id"]) {
//            [queryItems addObject:[NSURLQueryItem queryItemWithName:item.name value:info.unionid]];
//        }
//        else if ([item.name isEqualToString:@"token"]) {
//            [queryItems addObject:[NSURLQueryItem queryItemWithName:item.name value:info.token]];
//        }
//        else if ([item.name isEqualToString:@"school_id"]) {
//            [queryItems addObject:[NSURLQueryItem queryItemWithName:item.name value:[NSString stringWithFormat:@"%ld", (long)SchoolId]]];
//        }
//        else {
//            [queryItems addObject:item];
//        }
//    }
//    
//    if (params) {
//        [queryItems addObjectsFromArray:params];
//    }
//    
//    if (queryItems.count) {
//        comps.queryItems = queryItems.copy;
//    }
//    
//    url = comps.URL;
//    
//    return url;
//}

- (BOOL)needLogin {
    NSURLComponents *comps = [NSURLComponents componentsWithString:self.homeUrl];
    for (NSURLQueryItem *item in comps.queryItems) {
        if ([item.name isEqualToString:@"userid"] || [item.name isEqualToString:@"token"] || [item.name isEqualToString:@"union_id"]) {
            return YES;
        }
    }
    
    return NO;
}

@end
