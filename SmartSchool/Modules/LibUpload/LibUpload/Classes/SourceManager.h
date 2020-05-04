//
//  SourceManager.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/23.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface SourceManager : BaseManager

/**
 获取图片或视频
 
 @param limit 个数限制
 @param mediaType 资源类型
 @param viewController 所属控制器
 @param crop 是否需要裁减
 @param upload 是否需要上传
 @param uploadKey 上传文件名
 @param uploadQuality 资源压缩比例
 @param fileLengthLimit 文件大小限制
 @param completion 回调
 */
- (void)getSourcesWithLimit:(NSInteger)limit
                       type:(PHAssetMediaType)mediaType
             viewController:(UIViewController *)viewController
                       crop:(BOOL)crop
                     upload:(BOOL)upload
                  uploadKey:(nullable NSString *)uploadKey
              uploadQuality:(CGFloat)uploadQuality
            fileLengthLimit:(NSUInteger)fileLengthLimit
             withCompletion:(nullable CommonBlock)completion;

@end

NS_ASSUME_NONNULL_END
