//
//  UserCenterManager.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/20.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "UserCenterManager.h"
#import <LibCoredata/CacheDataSource.h>
#import <ModLoginBase/AccountManager.h>

@implementation UserCenterManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static UserCenterManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[UserCenterManager alloc] init];
    });
    
    return manager;
}

- (FavData *)favWithId:(NSNumber *)uid {
    // 根据uid筛选
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@", uid];

    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[FavEntity entityName]
                                                                predicate:predicate
                                                          sortDescriptors:@[]];
    if (array.count) {
        return array.firstObject;
    }

    return nil;
}

- (FavData *)favWithContent:(NSString *)content {
    // 根据content筛选
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"content == %@", content];

    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[FavEntity entityName]
                                                                predicate:predicate
                                                          sortDescriptors:@[]];
    if (array.count) {
        return array.firstObject;
    }
        
    return nil;
}

- (void)requestFavWithAction:(YuCloudDataActions)action
                         uid:(NSNumber *)uid
                        data:(nullable NSDictionary *)data
                  completion:(CommonBlock)completion {
    
    NSString *urlString;
    NSString *method;
    
    switch (action) {
        case YuCloudDataList:
            urlString = @"account/fav";
            method = @"GET";
            data = nil;
            break;
            
        case YuCloudDataAdd:
            urlString = @"account/fav";
            method = @"POST";
            break;
            
        case YuCloudDataDelete:
            urlString = [NSString stringWithFormat:@"account/fav/%@", uid];
            method = @"DELETE";
            data = nil;
            break;
            
        default:
            break;
    }
    
    [[MainInterface sharedClient] doWithMethod:method
                                     urlString:urlString
                                    parameters:data
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                           NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                           NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                           ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                           
                                           if ([error_code errorCodeSuccess]) {
                                               NSDictionary *extra = responseObject[@"extra"];
//                                               if (action == YuCloudDataList) {
//                                                   NSArray *data = extra[@"data"];
//                                                   NSMutableArray *arr = [NSMutableArray new];
//                                                   for (NSDictionary *item in data) {
//                                                       FavData *data = [FavData favWithData:item];
//                                                       [arr addObject:data];
//                                                   }
//                                                   
//                                                   [[CacheManager shareManager] saveData:arr
//                                                                                  forUid:APP_FAV_UID
//                                                                                  forKey:APP_FAV_KEY
//                                                                              completion:^(BOOL success, NSDictionary * _Nullable info) {
//                                                                                  DDLog(@"保存收藏数据成功!");
//                                                                              }];
//
////                                                   [[AppDataSource sharedClient] addObjects:arr
////                                                                                 entityName:[FavEntity entityName]
////                                                                                    syncAll:NO
////                                                                              syncPredicate:nil];
//                                               }
//                                               else if (action == YuCloudDataAdd) {
//                                                   NSNumber *uid = extra[@"uid"];
//                                                   FavData *fav = [FavData favWithData:data];
//                                                   fav.uid = [uid integerValue];
//                                                   [[AppDataSource sharedClient] addObject:fav
//                                                                                entityName:[FavEntity entityName]];
//                                               }
//                                               else if (action == YuCloudDataDelete) {
//                                                   FavData *fav = [[AppDataSource sharedClient] favWithId:uid];
//                                                   if (fav) {
//                                                       [[AppDataSource sharedClient] deleteObject:fav];
//                                                   }
//                                               }
//                                               else {
//                                                   NSAssert(NO, @"not supported");
//                                               }
                                               
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

- (void)submitFeedback:(NSString *)feedback
                  name:(NSString *)name
                 phone:(NSString *)phone
                images:(NSArray *)images
            completion:(CommonBlock)completion {
    NSDictionary *dic = @{@"text"   : feedback?:@"",
                          @"name"   : name?:@"",
                          @"phone"  : phone?:@"",
                          @"images" : images?:@[]};
    
    [[MainInterface sharedClient] doWithMethod:@"POST"
                                     urlString:@"home/feedback"
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

@end
