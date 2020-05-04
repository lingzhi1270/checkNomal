//
//  AppManager.m
//  Unilife
//
//  Created by 唐琦 on 2019/8/22.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "AppManager.h"
#import <ModLoginBase/AccountManager.h>

@interface AppManager ()

@end

@implementation AppManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static AppManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [[AppManager alloc] init];
    });
    
    return client;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (NSArray *)allApps {
    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[AppEntity entityName]
                                                                  predicate:nil
                                                            sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]]];
    
    return array;
}

- (NSArray *)allHomeApps {
    // 筛选条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type > %ld && homeIndex >= 0", AppTypeLibrary];
    // 排序规则
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"homeIndex" ascending:YES];
    
    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[AppEntity entityName]
                                                                  predicate:predicate
                                                            sortDescriptors:@[sortDescriptor]];
    
    return array;
}

- (void)addAppDatas:(NSArray *)array {
    for (AppData *data in array) {
        [self addAppData:data];
    }
}

- (void)addAppData:(AppData *)data {
    [[CacheDataSource sharedClient] addObject:data
                                   entityName:[AppEntity entityName]];
}

- (NSString *)similarName:(NSString *)name {
    NSArray *array = [self allApps];
    NSString *pinyin = [name pinyin];
    NSInteger diff = 100;
    AppData *found = nil;
    
    for (AppData *item in array) {
        NSString *string = [item.name pinyin];
        
        if ([string isEqualToString:pinyin]) {
            return item.name;
        }
        
        NSInteger aa = [pinyin pinyinDiffWithString:string];
        if (aa < diff) {
            diff = aa;
            found = item;
        }
    }
    
    if (diff < 4) {
        return found.name;
    }
    else {
        return name;
    }
}

- (AppData *)appWithUid:(NSString *)uid {
    // 筛选条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@", uid];
    
    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[AppEntity entityName]
                                                                  predicate:predicate
                                                            sortDescriptors:@[]];
    if (array.count) {
        return array.firstObject;
    }
    else {
        return nil;
    }
}

- (NSArray *)allAppImages {
    NSArray *array = [self allApps];

    NSMutableArray *arr = [NSMutableArray array];
    
    for (AppData *item in array) {
        if (item.iconUrl.length) {
            [arr addObject:item.iconUrl];
        }
    }
    
    return arr;
}

- (AppData *)appToProcessQRKey:(NSString *)key {
    // 筛选条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"qrKey == %@", key];
    // 排序规则
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES];
    
    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[AppEntity entityName]
                                                                  predicate:predicate
                                                            sortDescriptors:@[sortDescriptor]];
    
    if (array.count) {
        return array.firstObject;
    }
    else {
        return nil;
    }
}

- (void)fetchAllContactsWithCompletion:(CommonBlock)completion {
    [[MainInterface sharedClient] GET:@"app/contacts"
                           parameters:nil
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
                                 } else {
                                     if (completion) {
                                         completion(NO, @{@"error_code" : [NSNumber commonNetError],
                                                          @"error_msg" : error_msg});
                                     }
                                 }
                             }
                              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                 if (completion) {
                                     completion(NO, @{@"error_code" : [NSNumber commonNetError],
                                                      @"error_msg" : [error localizedDescription]});
                                 }
                              }];
}

@end
