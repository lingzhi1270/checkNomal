//
//  QiniuManager.h
//  Dreamedu
//
//  Created by 唐琦 on 2019/2/21.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <ModLoginBase/AccountManager.h>
#import <Qiniu/QiniuSDK.h>
#import <SDWebImage/SDWebImagePrefetcher.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Qiniu)

- (NSString *)key;
- (NSString *)hash;
- (NSString *)url;

@end

@interface QiniuManager : BaseManager

- (void)updateTokenFromData:(NSArray *)store;

@end

@interface AliOssManager : BaseManager

- (void)requestOssInfoWithCompletion:(nullable CommonBlock)completion;

@end

@interface UploadManager : BaseManager

+ (NSString *)urlOfThumbWithSize:(CGSize)size
                            mode:(UIViewContentMode)mode
                            type:(nullable NSString *)type
                          forUrl:(NSString *)urlString;

- (void)uploadFile:(NSString *)filePath
               key:(nullable NSString *)key
           fileExt:(nullable NSString *)fileExt
          progress:(nullable void(^)(NSUInteger, NSUInteger))progressBlock
        completion:(nullable CommonBlock)completion;

- (void)uploadData:(NSData *)data
               key:(nullable NSString *)key
           fileExt:(nullable NSString *)fileExt
          progress:(nullable void(^)(NSUInteger completedBytes, NSUInteger totalBytes))progressBlock
        completion:(nullable CommonBlock)completion;

- (void)statMediaWithApp:(nullable NSString *)appid
               urlString:(NSString *)urlString
                    size:(CGFloat)fileSize
              completion:(nullable CommonBlock)completion;

@end

NS_ASSUME_NONNULL_END
