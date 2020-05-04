//
//  CommonCheckManager.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/7.
//

#import "CommonCheckManager.h"

@implementation CommonCheckManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static CommonCheckManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[CommonCheckManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

//获取校历
- (void)getSchoolCalendarCompletion:(CommonBlock)completion
{
    [[MainInterface sharedClient] doWithMethod:@"GET" urlString:[[MainInterface sharedClient] serverInfo][@"Common_Check_calendar"] parameters:nil constructingBodyWithBlock:nil progress:nil   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
         NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
           
         if ([error_code errorCodeSuccess]) {
             if (completion) {
                 completion(YES, responseObject[@"extra"]);
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

//常规检查(获取顶级检查项目)
- (void)getCommonCheckInfoWithUserId:(NSString *)userId deptCode:(NSString *)deptCode gradeNo:(NSString *)gradeNo completion:(CommonBlock)completion
{
    NSDictionary *parma = @{@"user_id":userId,
                            @"dept_code":deptCode,
                            @"grade_no":gradeNo};
    [[MainInterface sharedClient] doWithMethod:@"GET" urlString:[[MainInterface sharedClient] serverInfo][@"Common_Check_TopItems"] parameters:parma constructingBodyWithBlock:nil progress:nil   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                                NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                                  
                                                if ([error_code errorCodeSuccess]) {
                                                    if (completion) {
                                                        completion(YES, responseObject[@"extra"]);
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

//根据学号获取个人信息
- (void)getStudentCheckProjectWithStudentId:(NSString *)studentId completion:(CommonBlock)completion
{
    NSDictionary *param = @{@"id":studentId};
    [[MainInterface sharedClient] doWithMethod:@"GET" urlString:[[MainInterface sharedClient] serverInfo][@"Common_Check_getStudentInfo"] parameters:param constructingBodyWithBlock:nil progress:nil   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
            NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
              
            if ([error_code errorCodeSuccess]) {
                if (completion) {
                    completion(YES, responseObject[@"extra"]);
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

//获取包干区信息
- (void)getEachareaCheckProjectWithCode:(NSString *)code completion:(CommonBlock)completion
{
    NSDictionary *param = @{@"code":code};
    [[MainInterface sharedClient] doWithMethod:@"GET" urlString:[[MainInterface sharedClient] serverInfo][@"Common_Check_getAreaInfo"] parameters:param constructingBodyWithBlock:nil progress:nil   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
            NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
              
            if ([error_code errorCodeSuccess]) {
                if (completion) {
                    completion(YES, responseObject[@"extra"]);
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

//获取学校部门、年级、班级（传inspectId）
- (void)getCommonCheckClassRequstWithInspectId:(NSNumber *)inspectId Completion:(CommonBlock)completion
{
    NSDictionary *param = @{@"inspect_id":inspectId};
    [[MainInterface sharedClient] doWithMethod:@"GET" urlString:[[MainInterface sharedClient] serverInfo][@"Common_Check_getClass"] parameters:param constructingBodyWithBlock:nil progress:nil   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
         NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
           
         if ([error_code errorCodeSuccess]) {
             if (completion) {
                 completion(YES, responseObject);
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

//获取学校部门、年级、班级(不传参)
- (void)getCommonCheckClassRequstCompletion:(CommonBlock)completion
{
    [[MainInterface sharedClient] doWithMethod:@"GET" urlString:[[MainInterface sharedClient] serverInfo][@"Common_Check_getClass"] parameters:nil constructingBodyWithBlock:nil progress:nil   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
         NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
           
         if ([error_code errorCodeSuccess]) {
             if (completion) {
                 completion(YES, responseObject);
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

- (void)getChildClassCheckProjectWithParentId:(NSString *)parentId completion:(CommonBlock)completion
{
    NSDictionary *parma = @{@"parent_id":parentId};
    [[MainInterface sharedClient] doWithMethod:@"GET" urlString:[[MainInterface sharedClient] serverInfo][@"Common_Check_getChildClass"] parameters:parma constructingBodyWithBlock:nil progress:nil   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                    NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                                     NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                                       
                                                     if ([error_code errorCodeSuccess]) {
                                                         if (completion) {
                                                             completion(YES, responseObject[@"extra"]);
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

//检查项结果查询
- (void)getCheckResultWithParentId:(NSString *)parentId gradeNo:(NSNumber *)gradeNo date:(NSString *)date completion:(CommonBlock)completion
{
    NSDictionary *parma = @{@"parent_id":parentId,
                            @"grade_no":gradeNo,
                            @"date":date};
    [[MainInterface sharedClient] doWithMethod:@"GET" urlString:[[MainInterface sharedClient] serverInfo][@"Common_Check_qureyResult"] parameters:parma constructingBodyWithBlock:nil progress:nil   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                    NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                                     NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                                       
                                                     if ([error_code errorCodeSuccess]) {
                                                         if (completion) {
                                                             completion(YES, responseObject);
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

//当日汇总结果查询
- (void)getCheckTodayResultWithUserId:(NSString *)userId gradeNo:(NSNumber *)gradeNo classNo:(NSNumber *)classNo date:(NSString *)date completion:(CommonBlock)completion
{
    NSDictionary *parma = @{@"user_id":userId,
                            @"grade_no":gradeNo,
                            @"class_no":classNo,
                            @"date":date};
    [[MainInterface sharedClient] doWithMethod:@"GET" urlString:[[MainInterface sharedClient] serverInfo][@"Common_Check_qureyTodayResult"] parameters:parma constructingBodyWithBlock:nil progress:nil   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                    NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                                     NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                                       
                                                     if ([error_code errorCodeSuccess]) {
                                                         if (completion) {
                                                             completion(YES, responseObject[@"extra"]);
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

//提交检查信息(班级)
-(void)commitCheckClassResultInfoWithFromType:(NSInteger)type classId:(NSNumber *)targetClassId studentId:(NSString *)studentId areaId:(NSNumber *)areaId imagesIds:(NSString *)imagesIds videoIds:(NSString *)videoIds comment:(NSString *)comment reportUserNo:(NSString *)reportUserNo items:(NSArray*)items completion:(CommonBlock)completion
{
    NSDictionary *parma;

    switch (type) {
        case 0://个人
        {
        parma = @{@"target_class_id":targetClassId,
                  @"target_user_no":studentId,
                  @"images_ids":imagesIds,
                  @"video_ids":videoIds,
                  @"comment":comment,
                  @"report_user_no":reportUserNo,
                  @"items":items};
        }
            break;
        case 1://班级
        {
           parma = @{@"target_class_id":targetClassId,
                     @"images_ids":imagesIds,
                     @"video_ids":videoIds,
                     @"comment":comment,
                     @"report_user_no":reportUserNo,
                     @"items":items};
        }
        break;
        case 2://包干区
        {
          parma = @{@"target_class_id":targetClassId,
                    @"target_loc_id":areaId,
                    @"images_ids":imagesIds,
                    @"video_ids":videoIds,
                    @"comment":comment,
                    @"report_user_no":reportUserNo,
                    @"items":items};
        }
        break;
        default:
            parma = @{};
            break;
    }
       [[MainInterface sharedClient] doWithMethod:@"POST" urlString:[[MainInterface sharedClient] serverInfo][@"Common_Check_report"] parameters:parma constructingBodyWithBlock:nil progress:nil   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                       NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                                        NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                                          
                                                        if ([error_code errorCodeSuccess]) {
                                                            if (completion) {
                                                                completion(YES, responseObject[@"extra"]);
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
@end
