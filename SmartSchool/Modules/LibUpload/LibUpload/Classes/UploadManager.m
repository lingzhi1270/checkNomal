//
//  QiniuManager.m
//  Dreamedu
//
//  Created by 唐琦 on 2019/2/21.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "UploadManager.h"
#import <AliyunOSSiOS/AliyunOSSiOS.h>

@implementation NSDictionary (Qiniu)

- (NSString *)key {
    return self[@"key"];
}

- (NSString *)hash {
    return self[@"hash"];
}

- (NSString *)url {
    return self[@"url"];
}

@end

#pragma mark - QiniuBucket

@interface QiniuBucket : NSObject

@property (nonatomic, copy)   NSString              *bucketDomain;
@property (nonatomic, copy)   NSString              *uploadToken;

@end

@implementation QiniuBucket

@end

@interface AliOssBucket : NSObject

@property (nonatomic, copy) NSString        *ak;
@property (nonatomic, copy) NSString        *sk;
@property (nonatomic, copy) NSString        *st;
@property (nonatomic, copy) NSString        *name;
@property (nonatomic, copy) NSString        *endpoint;

+ (instancetype)bucketFromData:(NSDictionary *)data;

@end

@implementation AliOssBucket

+ (instancetype)bucketFromData:(NSDictionary *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        self.name = VALIDATE_STRING(data[@"bucket_name"]);
        self.ak = VALIDATE_STRING(data[@"access_key"]);
        self.sk = VALIDATE_STRING(data[@"secret_key"]);
        self.st = VALIDATE_STRING(data[@"security_token"]);
        self.endpoint = VALIDATE_STRING(data[@"endpoint"]);
        
        self.endpoint = [self.endpoint stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    }
    
    return self;
}

@end

#pragma mark - QiniuManager

@interface QiniuManager ()

@property (nonatomic, strong) QNUploadManager           *uploadManager;
@property (nonatomic, strong) NSArray<QiniuBucket *>    *buckets;

@end

@implementation QiniuManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static QiniuManager *client;
    dispatch_once(&onceToken, ^{
        client = [[QiniuManager alloc] init];
    });
    
    return client;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    
    return self;
}

+ (NSString *)urlOfThumbWithSize:(CGSize)size
                 forImageWithURL:(NSString *)urlString {
    if ([urlString containsString:@"bkt.clouddn.com"]) {
        NSString *string = [NSString stringWithFormat:@"%@?imageMogr2/thumbnail/%ldx%ld>", urlString, (long)size.width, (long)size.height];
        string = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        return string;
    }
    
    return urlString;
}

- (void)updateTokenFromData:(NSArray *)store {
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *item in store) {
        NSString *domain = VALIDATE_STRING(item[@"domain"]);
        if ([domain containsString:@".clouddn."]) {
            QiniuBucket *bucket = [[QiniuBucket alloc] init];
            bucket.bucketDomain = domain;
            bucket.uploadToken = item[@"upload_token"];
            
            [arr addObject:bucket];
        }
        else {
            
        }
    }
    
    [QiniuManager shareManager].buckets = arr.copy;
}

- (QNUploadManager *)uploadManager {
    if (!_uploadManager) {
        QNConfiguration *conf = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
            builder.zone = [QNFixedZone zone2];
        }];
        
        _uploadManager = [[QNUploadManager alloc] initWithConfiguration:conf];
    }
    
    return _uploadManager;
}

- (void)uploadFile:(NSString *)filePath
               key:(NSString *)key
          progress:(nullable void (^)(NSUInteger, NSUInteger))progressBlock
        completion:(CommonBlock)completion {
    
    QiniuBucket *bucket = self.buckets.firstObject;
    NSAssert([bucket.bucketDomain length] > 0 && [bucket.uploadToken length] > 0, @"七牛的 bucket name 和 upload token 必须要初始化好");
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath], @"本地文件必须要存在");
    
    [self.uploadManager putFile:filePath
                            key:key
                          token:bucket.uploadToken
                       complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                           if (completion) {
                               NSMutableDictionary *dic = resp.mutableCopy;
                               if (info.statusCode == 200) {
                                   [dic setObject:[NSString stringWithFormat:@"http://%@/%@", bucket.bucketDomain, resp[@"key"]]
                                           forKey:@"url"];
                                   
//                                   DDLog(@"Qiniu uploaded dic: %@", dic);
                               }
                               else {
//                                   DDLog(@"Qiniu upload failed status: %d error: %@", info.statusCode, info.error.userInfo);
                               }
                               
                               completion(info.statusCode == 200, [NSDictionary dictionaryWithDictionary:dic]);
                           }
                       }
                         option:nil];
}

- (void)uploadData:(NSData *)data
               key:(NSString *)key
           fileExt:(nullable NSString *)fileExt
          progress:(nullable void (^)(NSUInteger, NSUInteger))progressBlock
        completion:(CommonBlock)completion {
    
    QiniuBucket *bucket = self.buckets.firstObject;
    NSAssert([bucket.bucketDomain length] > 0 && [bucket.uploadToken length] > 0, @"七牛的 bucket name 和 upload token 必须要初始化好");
    NSAssert([data length] > 0, @"内容不能为空");
    
//    DDLog(@"File size: %ld k", (long)[data length] / 1024);
    
    QNUploadOption *options;
    if (progressBlock) {
        options = [[QNUploadOption alloc] initWithProgressHandler:^(NSString *key, float percent) {
            progressBlock(data.length * percent, data.length);
        }];
    }
    
    [self.uploadManager putData:data
                            key:key
                          token:bucket.uploadToken
                       complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                           if (completion) {
                               NSMutableDictionary *dic = resp.mutableCopy;
                               if (info.statusCode == 200) {
                                   [dic setObject:[NSString stringWithFormat:@"http://%@/%@", bucket.bucketDomain, resp[@"key"]]
                                           forKey:@"url"];
                                   
//                                   DDLog(@"Qiniu uploaded dic: %@", dic);
                               }
                               else {
//                                   DDLog(@"Qiniu upload failed status: %d error: %@", info.statusCode, info.error.userInfo);
                               }
                               
                               completion(info.statusCode == 200, [NSDictionary dictionaryWithDictionary:dic]);
                           }
                       } option:options];
}

@end

@interface AliOssManager ()

@property (nonatomic, strong) OSSClient     *client;
@property (nonatomic, strong) AliOssBucket  *bucket;
@property (nonatomic, copy)   NSDate        *tokenDate;

@end

@implementation AliOssManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static AliOssManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [[AliOssManager alloc] init];
    });
    
    return client;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    
    return self;
}

- (void)requestOssInfoWithCompletion:(nullable CommonBlock)completion {
    if (self.bucket && self.tokenDate && [[NSDate date] timeIntervalSinceDate:self.tokenDate] < 60 * 30) {
        if (completion) {
            completion(YES, nil);
        }
        
        return;
    }
    
    [[MainInterface sharedClient] doWithMethod:@"GET"
                                     urlString:@"home/ossinfo"
                                    parameters:nil
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                           NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                           NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                           ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                           
                                           if ([error_code errorCodeSuccess]) {
                                               NSDictionary *extra = responseObject[@"extra"];
                                               self.bucket = [AliOssBucket bucketFromData:extra];
                                               if (completion) {
                                                   completion(YES, nil);
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

+ (NSString *)urlOfThumbWithSize:(CGSize)size
                            mode:(UIViewContentMode)mode
                            type:(nullable NSString *)type
                          forUrl:(NSString *)urlString {
    if (![urlString containsString:@".aliyuncs.com"]) {
        return urlString;
    }
    
    switch (mode) {
        case UIViewContentModeScaleAspectFit: {
            // 按长边缩略
            return [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_lfit,w_%ld,h_%ld/format,%@", urlString, (long)size.width, (long)size.height, type?:@"jpg"];
        }
            
        case UIViewContentModeScaleAspectFill: {
            // 按短边压缩
            return [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_mfit,w_%ld,h_%ld/format,%@", urlString, (long)size.width, (long)size.height, type?:@"jpg"];
        }
            break;
            
        default: {
            // 按短边压缩，居中裁剪
            return [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,w_%ld,h_%ld/format,%@", urlString, (long)size.width, (long)size.height, type?:@"jpg"];
        }
    }
}

- (void)setBucket:(AliOssBucket *)bucket {
    _bucket = bucket;
    
    self.tokenDate = [NSDate date];
    
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 2;
    conf.timeoutIntervalForRequest = 30;
    conf.timeoutIntervalForResource = 24 * 60 * 60;
    
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:bucket.ak
                                                                                          secretKeyId:bucket.sk
                                                                                        securityToken:bucket.st];
    
    self.client = [[OSSClient alloc] initWithEndpoint:bucket.endpoint
                                   credentialProvider:credential
                                  clientConfiguration:conf];
}

- (void)uploadData:(NSData *)data
               key:(nullable NSString *)key
           fileExt:(nullable NSString *)fileExt
          progress:(nullable void(^)(NSUInteger completedBytes, NSUInteger totalBytes))progressBlock
        completion:(CommonBlock)completion {
    static NSInteger index = 0;
    [self requestOssInfoWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
        if (success) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSString *schoolName;
            switch (SchoolId) {
                case 1001:
                    schoolName = @"青海师大";
                    break;
                    
                case 1002:
                    schoolName = @"百家湖中学";
                    break;
                    
                case 1003:
                    schoolName = @"竹山路中学";
                    break;
                    
                default:
                    schoolName = @"学校";
                    break;
            }
            NSString *objectKey = [NSString stringWithFormat:@"%@/%@/-%@-%ld.%@", schoolName, key, [formatter shortDayTimeStringFromDate:[NSDate date]], (long)index++, fileExt?:@"jpg"];
            objectKey = [objectKey stringByReplacingOccurrencesOfString:@":" withString:@"-"];
            objectKey = [objectKey stringByReplacingOccurrencesOfString:@" " withString:@"-"];
            
            OSSPutObjectRequest * put = [OSSPutObjectRequest new];
            put.bucketName = self.bucket.name;
            put.objectKey = objectKey;
            put.uploadingData = data;
            put.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                if (progressBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progressBlock((NSUInteger)totalBytesSent, (NSUInteger)totalBytesExpectedToSend);
                    });
                }
            };
            
            OSSTask *task = [self.client putObject:put];
            [task continueWithBlock:^id _Nullable(OSSTask * _Nonnull task) {
                NSString *url;
                if (!task.error) {
                    url = [NSString stringWithFormat:@"http://%@.%@/%@", self.bucket.name, self.bucket.endpoint, objectKey];
                    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
                
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (task.error) {
                            completion(NO, @{@"error" : task.error});
                        }
                        else {
                            completion(YES, url?@{@"url" : url,
                                                  @"size" : @(data.length)}:nil);
                        }
                        
                    });
                }
                
                return task;
            }];
        }
        else {
            if (completion) {
                completion(NO, nil);
            }
        }
    }];
}

- (void)uploadFile:(NSString *)filePath
               key:(nullable NSString *)key
           fileExt:(nullable NSString *)fileExt
          progress:(nullable void(^)(NSUInteger completedBytes, NSUInteger totalBytes))progressBlock
        completion:(CommonBlock)completion {
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [self uploadData:data
                 key:key
             fileExt:fileExt
            progress:progressBlock
          completion:completion];
}

@end

@interface UploadManager ()

@end

@implementation UploadManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static UploadManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [[UploadManager alloc] init];
    });
    
    return client;
}

+ (NSString *)urlOfThumbWithSize:(CGSize)size
                            mode:(UIViewContentMode)mode
                            type:(nullable NSString *)type
                          forUrl:(NSString *)urlString {
    if ([urlString containsString:@".aliyuncs.com"]) {
        return [AliOssManager urlOfThumbWithSize:size
                                            mode:mode
                                            type:type
                                          forUrl:urlString];
    }
    
    return [QiniuManager urlOfThumbWithSize:size
                            forImageWithURL:urlString];
}

- (instancetype)init {
    if (self = [super init]) {
    }
    
    return self;
}

- (void)uploadData:(NSData *)data
               key:(NSString *)key
           fileExt:(nullable NSString *)fileExt
          progress:(void (^)(NSUInteger, NSUInteger))progressBlock
        completion:(CommonBlock)completion {
    AliOssManager *oss = [AliOssManager shareManager];
    
    if (oss.bucket) {
        [oss uploadData:data
                    key:key
                fileExt:fileExt
               progress:progressBlock
             completion:^(BOOL success, NSDictionary * _Nullable info) {
                 if (completion) {
                     completion(success, info);
                 }
                 
                 // 媒体上传统计
                 NSString *urlString = info[@"url"];
                 NSNumber *size = info[@"size"];
                 [self statMediaWithApp:nil
                              urlString:urlString
                                   size:[size integerValue]
                             completion:nil];
             }];
    }
    else {
        [[QiniuManager shareManager] uploadData:data
                                            key:nil
                                        fileExt:nil
                                       progress:progressBlock
                                     completion:nil];
    }
}

- (void)uploadFile:(NSString *)filePath
               key:(NSString *)key
           fileExt:(nullable NSString *)fileExt
          progress:(void (^)(NSUInteger, NSUInteger))progressBlock
        completion:(CommonBlock)completion {
    AliOssManager *oss = [AliOssManager shareManager];
    if (oss.bucket) {
        [oss uploadFile:filePath
                    key:key
                fileExt:fileExt
               progress:progressBlock
             completion:completion];
    }
    else {
        [[QiniuManager shareManager] uploadFile:filePath
                                       key:nil
                                  progress:progressBlock
                                completion:completion];
    }
}

- (void)statMediaWithApp:(NSString *)appid
               urlString:(NSString *)urlString
                    size:(CGFloat)fileSize
              completion:(CommonBlock)completion {
    NSDictionary *dic = @{@"app_id"     : appid?:@"",
                          @"url"        : urlString?:@"",
                          @"file_size"  : @(fileSize)};
    
    [[MainInterface sharedClient] doWithMethod:@"POST"
                                        urlString:@"app/stat/media"
                                       parameters:dic
                        constructingBodyWithBlock:nil
                                         progress:nil
                                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                              NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                              NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                              ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                              
                                              if ([error_code errorCodeSuccess]) {
                                                  if (completion) {
                                                      completion(YES, nil);
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

