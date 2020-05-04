//
//  UserManager.m
//  Unilife
//
//  Created by 唐琦 on 2019/7/15.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "UserManager.h"
#import "AccountManager.h"

@interface UserManager ()

@property (nonatomic, copy) NSString        *refreshKey;

@end

@implementation UserManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static UserManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [[UserManager alloc] init];
    });
    
    return client;
}

- (instancetype)init {
    if (self = [super init]) {
        self.refreshKey = [NSString stringWithFormat:@"%p", self];
    }
    
    return self;
}

- (NSArray *)allUserData {
    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[UserEntity entityName]
                                                                  predicate:nil
                                                            sortDescriptors:@[]];
    
    return array;
}

- (void)addUserData:(UserData *)data {
    [[CacheDataSource sharedClient] addObject:data
                                   entityName:[UserEntity entityName]];
    
}

- (UserData *)userWithUserid:(NSString *)userid {
    // 筛选条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userid == %@ && loginid == %@", userid, ACCOUNT_USERID];
    // 查找对应数据
    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[UserEntity entityName]
                                                                  predicate:predicate
                                                            sortDescriptors:@[]];
    if (array.count) {
        return array.firstObject;
    }
    
    return nil;
}

- (UserData *)userWithImid:(NSString *)imid {
    // 筛选条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"im_id == %@ && loginid == %@", imid, ACCOUNT_USERID];
    // 查找对应数据
    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[UserEntity entityName]
                                                                  predicate:predicate
                                                            sortDescriptors:@[]];
    if (array.count) {
        return array.firstObject;
    }
    
    return nil;
}

- (void)requestUserInfoWithUserid:(NSString *)userid
                     forceRefresh:(BOOL)refresh
                      localholder:(nullable CommonBlock)localholder
                       completion:(nullable CommonBlock)completion {
    /*
     * 1. 如果本地有数据，则 localholder 调用一次
     * 2. 如果不需要刷新，则 completion 调用一次
     * 3. 如果需要刷新，则刷新完成后 completion 调用一次
     */
    NSAssert(userid, @"userid should not be nil");
    
    UserData *user =  [self userWithUserid:userid];
    if (user && localholder) {
        localholder(YES, @{@"user" : user});
    }
    
    if (!refresh && user && [user.refreshKey isEqualToString:[UserManager shareManager].refreshKey]) {
        if (completion) {
            completion(YES, @{@"user" : user});
        }
    }
    else {
        [self searchUserWithId:userid
                          imID:nil
                      keywords:nil
                       startid:nil
                    completion:^(BOOL success, NSDictionary * _Nullable info) {
                        if (success) {
                            NSArray *arr = info[@"result"];
                            NSDictionary *dic = arr.firstObject;
                            
                            UserData *user = [UserData userFromData:dic];
                            if (completion) {
                                completion(YES, @{@"user" : user});
                            }
                        }
                        else if (completion) {
                            completion(NO, nil);
                        }
                    }];
    }
}

- (void)requestUserInfoWithImid:(NSString *)imid
                   forceRefresh:(BOOL)refresh
                    localholder:(nullable CommonBlock)localholder
                     completion:(nullable CommonBlock)completion {
    /*
     * 1. 如果本地有数据，则 localholder 调用一次
     * 2. 如果不需要刷新，则 completion 调用一次
     * 3. 如果需要刷新，则刷新完成后 completion 调用一次
     */
    NSAssert(imid, @"imid should not be nil");
    UserData *user =  [self userWithImid:imid];
    if (user && localholder) {
        localholder(YES, @{@"user" : user});
    }
    
    if (!refresh && user && [user.refreshKey isEqualToString:[UserManager shareManager].refreshKey]) {
        if (completion) {
            completion(YES, @{@"user" : user});
        }
    }
    else {
        [self searchUserWithId:nil
                          imID:imid
                      keywords:nil
                       startid:nil
                    completion:^(BOOL success, NSDictionary * _Nullable info) {
                        if (success) {
                            NSArray *arr = info[@"result"];
                            NSDictionary *dic = arr.firstObject;
                            UserData *user = [UserData userFromData:dic];
                            if (completion) {
                                completion(YES, @{@"user" : user});
                            }
                        }
                        else if (completion) {
                            //失败时返回本地数据
                            completion(NO, user?@{@"user" : user}:nil);
                        }
                        
                    }];
    }
}

- (void)searchUserWithId:(NSString *)userid
                    imID:(NSString *)imid
                keywords:(NSString *)keywords
                 startid:(nullable NSNumber *)startid
              completion:(CommonBlock)completion {
    NSString *urlString = [NSString stringWithFormat:@"community/people"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (userid) {
        [dic setObject:userid forKey:@"user_id"];
    }
    else if (keywords) {
        [dic setObject:keywords forKey:@"key_words"];
        
    } else if(imid) {
        [dic setObject:imid forKey:@"im_id"];
    }
    
    if (startid) {
        [dic setObject:startid forKey:@"start_id"];
    }
    
    [[MainInterface sharedClient] doWithMethod:@"GET"
                                     urlString:urlString
                                    parameters:dic.copy
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                           NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                           NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                           ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                           
                                           NSDictionary *extra = responseObject[@"extra"];
                                           NSNumber *next_id = extra[@"next_id"];
                                           if ([error_code errorCodeSuccess]) {
                                               NSArray *data = extra[@"data"];
                                               
                                               //此处将查询到的用户信息，缓存在本地
                                               NSMutableArray *arr = [NSMutableArray new];
                                               for (NSDictionary *item in data) {
                                                   UserData *user = [UserData userFromData:item];
                                                   [arr addObject:user];
                                               }
                                               
                                               [[CacheDataSource sharedClient] addObjects:arr
                                                                               entityName:[UserEntity entityName]
                                                                                  syncAll:NO
                                                                            syncPredicate:nil];
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
