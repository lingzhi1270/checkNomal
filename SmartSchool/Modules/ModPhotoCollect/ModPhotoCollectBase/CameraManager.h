//
//  CameraManager.h
//  Unilife
//
//  Created by 唐琦 on 2019/9/7.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "BaseManager.h"
#import "CameraData.h"
#import "AccountManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface CameraTemplateData : NSObject

@property (nonatomic, copy) NSString    *name;
@property (nonatomic, copy) NSString    *backgroundImageUrl;
@property (nonatomic, copy) UIColor     *textColor;
@property (nonatomic, copy) NSString    *nameTitle;
@property (nonatomic, copy) NSString    *numberTitle;

- (UIImage *)backgroundImage;

+ (instancetype)templateFromData:(NSDictionary *)data;

@end

@interface CameraManager : BaseManager
@property (nonatomic, copy) NSArray         *taskColors;
@property (nonatomic, copy) NSArray         *templates;

- (void)requestCameraTaskWithAction:(YuCloudDataActions)action
                             taskid:(NSInteger)taskid
                               info:(nullable NSDictionary *)info
                         completion:(nullable CommonBlock)completion;

- (void)requestCameraPickWithAction:(YuCloudDataActions)action
                             taskid:(NSInteger)taskid
                                uid:(NSInteger)uid
                           imageUrl:(nullable NSString *)imageUrl
                        originalUrl:(nullable NSString *)originalUrl
                         completion:(nullable CommonBlock)completion;

- (void)updateExtraInfo;

- (UIImage *)logoImage;
- (NSString *)appMessage;
- (UIImage *)appQrImage;
- (NSString *)appQrName;

#pragma mark - 照片采集任务相关
- (NSArray *)allTask;
- (void)allTaskWithCompletion:(CacheBlock)completion;

- (void)taskWithId:(NSInteger)uid
        completion:(nullable CommonBlock)completion;

#pragma mark - 照片采集任务中的照片相关
- (void)photoWithTask:(NSInteger)taskid
                  uid:(NSInteger)uid
           completion:(nullable CommonBlock)completion;

- (void)photosWithTask:(NSInteger)taskid
            completion:(nullable CacheBlock)completion;

- (void)addPhoto:(CameraPhotoData *)photo
      completion:(nullable CommonBlock)completion;

@end

NS_ASSUME_NONNULL_END
