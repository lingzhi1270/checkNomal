//
//  CameraManager.m
//  Unilife
//
//  Created by 唐琦 on 2019/9/7.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "CameraManager.h"
#import "CameraData.h"

@interface CameraTemplateData ()

@end

@implementation CameraTemplateData

+ (instancetype)templateFromData:(NSDictionary *)data {
    return [[CameraTemplateData alloc] initWithData:data];
}

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        self.name = data[@"name"];
        self.backgroundImageUrl = data[@"background"];
        
        NSString *string = data[@"text_color"];
        self.textColor = [UIColor colorFromString:string];
        
        self.nameTitle = data[@"name_title"];
        self.numberTitle = data[@"number_title"];
        
        if (self.backgroundImageUrl.length) {
            [[UniManager shareManager] prefetchURLs:@[[NSURL URLWithString:self.backgroundImageUrl]]];
        }
    }
    
    return self;
}

- (UIImage *)backgroundImage {
    return [[SDImageCache sharedImageCache] imageFromCacheForKey:self.backgroundImageUrl];
}

@end

@interface CameraManager ()

@end

@implementation CameraManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static CameraManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [[CameraManager alloc] init];
    });
    
    return client;
}

- (instancetype)init {
    if (self = [super init]) {
        self.taskColors = @[@{@"total" : [UIColor colorWithRGB:0xed8388],
                              @"finished" : [UIColor colorWithRGB:0xea5a61]},
                            @{@"total" : [UIColor colorWithRGB:0x6eb1f7],
                              @"finished" : [UIColor colorWithRGB:0x4199f5]},
                            @{@"total" : [UIColor colorWithRGB:0x79cbf7],
                              @"finished" : [UIColor colorWithRGB:0x35b3f7]},
                            @{@"total" : [UIColor colorWithRGB:0x77d5e5],
                              @"finished" : [UIColor colorWithRGB:0x31c6df]},
                            @{@"total" : [UIColor colorWithRGB:0x81dab8],
                              @"finished" : [UIColor colorWithRGB:0x2ad896]}];
    }
    
    return self;
}

- (NSString *)logoUrl {
    return [NSUserDefaults objectForApp:APP_CAMERA_UID key:@"logo"];
}

- (void)setLogoUrl:(NSString *)logoUrl {
    [NSUserDefaults saveObject:logoUrl?:@"" forApp:APP_CAMERA_UID key:@"logo"];
}

- (NSString *)message {
    return [NSUserDefaults objectForApp:APP_CAMERA_UID key:@"message"];
}

- (void)setMessage:(NSString *)message {
    [NSUserDefaults saveObject:message?:@"" forApp:APP_CAMERA_UID key:@"message"];
}

- (NSString *)qrImage {
    return [NSUserDefaults objectForApp:APP_CAMERA_UID key:@"qrimage"];
}

- (void)setQrImage:(NSString *)qrImage {
    [NSUserDefaults saveObject:qrImage?:@"" forApp:APP_CAMERA_UID key:@"qrimage"];
}

- (NSString *)qrName {
    return [NSUserDefaults objectForApp:APP_CAMERA_UID key:@"qrname"];
}

- (void)setQrName:(NSString *)qrName {
    [NSUserDefaults saveObject:qrName?:@"" forApp:APP_CAMERA_UID key:@"qrname"];
}

- (UIImage *)logoImage {
    if (self.logoUrl.length) {
        UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:self.logoUrl];
        return [[UIImage alloc] initWithCGImage:image.CGImage scale:2 orientation:image.imageOrientation];
    }
    
    return nil;
}

- (NSString *)appMessage {
    return self.message;
}

- (UIImage *)appQrImage {
    if (self.qrImage.length) {
        return [[SDImageCache sharedImageCache] imageFromCacheForKey:self.qrImage];
    }
    
    return nil;
}

- (NSString *)appQrName {
    return self.qrName;
}

- (void)requestCameraTaskWithAction:(YuCloudDataActions)action
                             taskid:(NSInteger)taskid
                               info:(nullable NSDictionary *)info
                         completion:(nullable CommonBlock)completion {
    NSString *method;
    NSMutableDictionary *dic = @{}.mutableCopy;
    switch (action) {
        case YuCloudDataList:
            method = @"GET";
            break;
            
        case YuCloudDataAdd:
            method = @"POST";
            if (info) {
                [info enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [dic setObject:obj forKey:key];
                }];
            }
            break;
            
        default:
            method = @"GET";
            break;
    }
    
    [[MainInterface sharedClient] doWithMethod:method
                                     urlString:@"app/avatar/task"
                                    parameters:dic
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                           NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                           NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                           ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                           
                                           if ([error_code errorCodeSuccess]) {
                                               NSDictionary *extra = responseObject[@"extra"];
                                               NSArray *data = extra[@"data"];
                                               
                                               if (action == YuCloudDataList) {
                                                   NSMutableArray *arr = [NSMutableArray new];
                                                   for (NSDictionary *item in data) {
                                                       CameraTaskData *task = [CameraTaskData modelWithDictionary:item];
                                                       if (task) {
                                                           [arr addObject:task];
                                                       }
                                                   }
                                                   [[CacheManager shareManager] saveData:arr
                                                                                  forUid:APP_CAMERA_TASK_UID
                                                                                  forKey:APP_CAMERA_KEY
                                                                              completion:^(BOOL success, NSArray * _Nullable resultArray) {
                                                                                  DDLog(@"保存照片采集任务成功");
                                                                                  if (completion) {
                                                                                      completion(YES, extra);
                                                                                  }
                                                                              }];
                                               }
                                               else if (action == YuCloudDataAdd) {
                                                   if (completion) {
                                                       completion(YES, extra);
                                                   }
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

- (void)requestCameraPickWithAction:(YuCloudDataActions)action
                             taskid:(NSInteger)taskid
                                uid:(NSInteger)uid
                           imageUrl:(NSString *)imageUrl
                        originalUrl:(NSString *)originalUrl
                         completion:(CommonBlock)completion {
    NSString *method;
    NSString *urlString;
    NSMutableDictionary *dic = @{}.mutableCopy;
    switch (action) {
        case YuCloudDataList:
            method = @"GET";
            urlString = [NSString stringWithFormat:@"app/avatar/task/%ld", (long)taskid];
            break;
            
        case YuCloudDataAdd:
            method = @"POST";
            urlString = [NSString stringWithFormat:@"app/avatar/task/%ld/photo/%ld", (long)taskid, (long)uid];
            [dic setObject:imageUrl forKey:@"image_url"];
            break;
            
        case YuCloudDataEdit:
            method = @"PUT";
            urlString = [NSString stringWithFormat:@"app/avatar/task/%ld/photo/%ld", (long)taskid, (long)uid];
            [dic setObject:imageUrl?:@"" forKey:@"image_url"];
            [dic setObject:originalUrl?:@"" forKey:@"original_url"];
            break;
            
        case YuCloudDataDelete:
            method = @"DELETE";
            urlString = [NSString stringWithFormat:@"app/avatar/task/%ld/photo/%ld", (long)taskid, (long)uid];
            break;
            
        default:
            method = @"GET";
            break;
    }
    
    [[MainInterface sharedClient] doWithMethod:method
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
                                               
                                               if (action == YuCloudDataList) {
                                                   NSDictionary *data = extra[@"data"];
                                                   NSArray *staff = data[@"staff"];
                                                
                                                   
                                                   NSMutableArray *arr = [NSMutableArray new];
                                                   for (NSDictionary *item in staff) {
                                                       CameraPhotoData *data = [CameraPhotoData dataWithData:item];
                                                       data.taskid = taskid;
                                                       [arr addObject:data];
                                                   }
                                                   
                                                   [[CacheManager shareManager] saveData:arr
                                                                                  forUid:APP_CAMERA_PHOTO_UID
                                                                                  forKey:APP_CAMERA_KEY
                                                                              completion:^(BOOL success, NSArray * _Nullable resultArray) {
                                                                                  DDLog(@"保存照片采集任务中的图片成功");
                                                                                  
                                                                                  if (completion) {
                                                                                      completion(YES, extra);
                                                                                  }
                                                                              }];
                                               }
                                               else if (action == YuCloudDataAdd) {
                                                   [self photoWithTask:taskid uid:uid completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                       CameraPhotoData *data = info[@"data"];
                                                       data.image_url = imageUrl;
                                                       [self addPhoto:data completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                           DDLog(@"新增照片采集任务中的图片成功");
                                                           
                                                           if (completion) {
                                                               completion(YES, extra);
                                                           }
                                                       }];
                                                   }];
                                               }
                                               else if (action == YuCloudDataEdit) {
                                                   [self photoWithTask:taskid uid:uid completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                       CameraPhotoData *data = info[@"data"];
                                                       
                                                       data.image_url = imageUrl;
                                                       [self addPhoto:data completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                           DDLog(@"修改照片采集任务中的图片成功");
                                                           
                                                           if (completion) {
                                                               completion(YES, extra);
                                                           }
                                                       }];
                                                   }];
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

- (void)updateExtraInfo {
    [self requestExtraWithApp:APP_CAMERA_UID
                   completion:^(BOOL success, NSDictionary * _Nullable info) {
                       if (success) {
                           NSString *extra = info[@"extra"];
                           NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[extra dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                           NSArray *templates = data[@"templates"];
                           NSMutableArray *arr = [NSMutableArray array];
                           for (NSDictionary *item in templates) {
                               CameraTemplateData *data = [CameraTemplateData templateFromData:item];
                               [arr addObject:data];
                           }
                           
                           self.templates = arr.copy;
                       }
                   }];
}

- (void)requestExtraWithApp:(NSString *)appid completion:(CommonBlock)completion {
    NSString *urlString = [NSString stringWithFormat:@"home/app/%@/extra", appid];
    
    [[MainInterface sharedClient] doWithMethod:@"GET"
                                     urlString:urlString
                                    parameters:nil
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                           NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                           NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                           ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                           
                                           if ([error_code errorCodeSuccess]) {
                                               if (completion) {
                                                   completion(YES, @{@"extra" : responseObject[@"extra"]});
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

- (NSArray *)allTask {
    return [[CacheManager shareManager] getDataForUid:APP_CAMERA_TASK_UID
                                               forKey:APP_CAMERA_KEY];
}

- (void)allTaskWithCompletion:(CacheBlock)completion {
    [[CacheManager shareManager] getDataForUid:APP_CAMERA_TASK_UID
                                        forKey:APP_CAMERA_KEY
                                    completion:^(BOOL success, NSArray * _Nullable resultArray) {
                                        NSSortDescriptor *endDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateEnd" ascending:YES];
                                        NSSortDescriptor *pubDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datePub" ascending:NO];
        
                                        NSArray *array = [resultArray sortedArrayUsingDescriptors:@[endDescriptor, pubDescriptor]];
                                        
                                        if (completion) {
                                            completion(success, array);
                                        }
                                    }];
}

- (void)allPhotoDataWithCompletion:(CacheBlock)completion {
    [[CacheManager shareManager] getDataForUid:APP_CAMERA_PHOTO_UID
                                        forKey:APP_CAMERA_KEY
                                    completion:^(BOOL success, NSArray * _Nullable resultArray) {
                                        
                                        if (completion) {
                                            completion(success, resultArray);
                                        }
                                    }];
}

- (void)addPhoto:(CameraPhotoData *)photo
      completion:(nullable CommonBlock)completion {
    [self allPhotoDataWithCompletion:^(BOOL success, NSArray * _Nullable resultArray) {
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:resultArray];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskid == %ld && uid == %ld", photo.taskid, photo.uid];
        NSArray *array = [resultArray filteredArrayUsingPredicate:predicate];
        
        if (array.count) {
            [tempArr removeObjectsInArray:array];
        }
        
        [tempArr addObject:photo];
        
        [[CacheManager shareManager] saveData:tempArr
                                       forUid:APP_CAMERA_PHOTO_UID
                                       forKey:APP_CAMERA_KEY
                                   completion:^(BOOL success, NSArray * _Nullable resultArray) {
                                       if (completion) {
                                           completion(success, success?@{@"data":@"保存成功!"}:@{@"data":@"保存失败"});
                                       }
                                   }];
    }];
}

- (void)taskWithId:(NSInteger)uid
        completion:(nullable CommonBlock)completion {
    [self allTaskWithCompletion:^(BOOL success, NSArray * _Nullable resultArray) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %ld", uid];
        NSArray *array = [resultArray filteredArrayUsingPredicate:predicate];
        
        if (array.count) {
            if (completion) {
                completion(YES, @{@"data":array.firstObject});
            }
        }
        else if (completion) {
            completion(NO, nil);
        }
    }];
}

- (void)photoWithTask:(NSInteger)taskid
                  uid:(NSInteger)uid
           completion:(nullable CommonBlock)completion {
    [self allPhotoDataWithCompletion:^(BOOL success, NSArray * _Nullable resultArray) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskid == %ld && uid == %ld", taskid, uid];
        NSArray *array = [resultArray filteredArrayUsingPredicate:predicate];
        
        if (array.count) {
            if (completion) {
                completion(YES, @{@"data":array.firstObject});
            }
        }
        else if (completion) {
            completion(NO, nil);
        }
    }];
}

- (void)photosWithTask:(NSInteger)taskid
            completion:(nullable CacheBlock)completion {
    [self allPhotoDataWithCompletion:^(BOOL success, NSArray * _Nullable resultArray) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskid == %ld && image_url != nil", taskid];
        NSSortDescriptor *numberDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
        NSSortDescriptor *idDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES];
        // 筛选
        NSArray *array = [resultArray filteredArrayUsingPredicate:predicate];
        // 排序
        array = [array sortedArrayUsingDescriptors:@[numberDescriptor, idDescriptor]];
        
        if (completion) {
            completion(YES, array);
        }
    }];
}

@end
