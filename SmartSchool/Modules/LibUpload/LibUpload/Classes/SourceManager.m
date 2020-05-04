//
//  SourceManager.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/23.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "SourceManager.h"
#import "UploadManager.h"
#import <LibComponentBase/PreviewModel.h>
#import <TZImagePickerController/TZImagePickerController.h>

@interface SourceManager () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIVideoEditorControllerDelegate>
@property (nonatomic, assign) BOOL              needUpload;         // 是否需要上传
@property (nonatomic, copy)   NSString          *uploadKey;         // 上传文件名
@property (atomic)            CGFloat           uploadQuality;      // 图片压缩率
@property (atomic)            NSUInteger        fileLengthLimit;    // 文件大小
@property (nonatomic, assign) BOOL              needCrop;           // 是否需要裁减
@property (nonatomic, strong) UIViewController  *viewController;    // 所属控制器
@property (nonatomic, copy)   CommonBlock       sourcesCompletion;  // 回调

@end

@implementation SourceManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static SourceManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [[SourceManager alloc] init];
    });
    
    return client;
}

- (void)getSourcesWithLimit:(NSInteger)limit
                       type:(PHAssetMediaType)mediaType
             viewController:(UIViewController *)viewController
                       crop:(BOOL)crop
                     upload:(BOOL)upload
                  uploadKey:(nullable NSString *)uploadKey
              uploadQuality:(CGFloat)uploadQuality
            fileLengthLimit:(NSUInteger)fileLengthLimit
             withCompletion:(nullable CommonBlock)completion {
    self.viewController = viewController;
    self.needCrop = crop;
    self.needUpload = upload;
    self.uploadKey = uploadKey;
    self.uploadQuality = uploadQuality;
    self.fileLengthLimit = fileLengthLimit;
    self.sourcesCompletion = completion;
    
    WEAK(self, weakSelf);
    
    if (mediaType == PHAssetMediaTypeVideo) {
        //视频只能单选
        limit = 1;
        
        UIAlertController *alertContoller = [UIAlertController alertControllerWithTitle:nil message:@"请选择来源" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.mediaTypes = @[(NSString*)kUTTypeMovie];
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [viewController presentViewController:picker animated:YES completion:nil];
            }
        }];
        
        UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:limit delegate:nil];
            // 显示选中序号
            imagePickerVc.showSelectedIndex = YES;
            // 允许选择视频
            imagePickerVc.allowPickingVideo = YES;
            // 允许拍摄视频
            imagePickerVc.allowTakeVideo = YES;
            // 不允许选择图片
            imagePickerVc.allowPickingImage = NO;
            // 不允许拍摄图片
            imagePickerVc.allowTakePicture = NO;
            // 选择图片后的回调
            [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showHudOn:[UIApplication sharedApplication].keyWindow
                                        mode:MBProgressHUDModeText
                                       image:nil
                                     message:@"请选择视频类型的文件"
                                   delayHide:YES
                                  completion:nil];
                });
            }];
            // 选择视频后的回调
            [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *asset) {
                [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPreset640x480 success:^(NSString *outputPath) {
                    // 判断是否需要修改视频
                    if (crop) {
                        if ([UIVideoEditorController canEditVideoAtPath:outputPath]) {
                            UIVideoEditorController *videoEditor = [[UIVideoEditorController alloc] init];
                            videoEditor.delegate = self;
                            videoEditor.videoPath = outputPath;
                            videoEditor.videoMaximumDuration = 0;
                            videoEditor.modalPresentationStyle = UIModalPresentationFullScreen;
                            [viewController presentViewController:videoEditor animated:YES completion:nil];
                        }
                    }
                    else {
                        NSDictionary *dic = @{@"fileUrl":[NSURL fileURLWithPath:outputPath],
                                              @"thumbnail":coverImage,
                                              @"width":@(coverImage.size.width),
                                              @"height":@(coverImage.size.height)};
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // 处理视频上传和回调
                            [weakSelf selectVideoFinishedWithVideo:@[dic]];
                        });
                    }
                } failure:^(NSString *errorMessage, NSError *error) {
                    NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
                }];
            }];
            
            [viewController presentViewController:imagePickerVc animated:YES completion:nil];
        }];
        
        [alertContoller addAction:cameraAction];
        [alertContoller addAction:libraryAction];
        [alertContoller addAction:[UIAlertAction actionWithTitle:YUCLOUD_STRING_CANCEL
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             if (self.sourcesCompletion) {
                                                                 self.sourcesCompletion(NO, nil);
                                                             }
                                                         }]];
        [viewController presentViewController:alertContoller animated:YES completion:nil];
    }
    else {
        UIAlertController *alertContoller = [UIAlertController alertControllerWithTitle:nil message:@"请选择来源" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.mediaTypes = @[(NSString*)kUTTypeImage];
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [viewController presentViewController:picker animated:YES completion:nil];
            }
        }];
        
        UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:limit delegate:nil];
            // 显示选中序号
            imagePickerVc.showSelectedIndex = YES;
            // 允许选择图片
            imagePickerVc.allowPickingImage = YES;
            // 允许拍摄图片
            imagePickerVc.allowTakePicture = YES;
            // 不允许选择视频
            imagePickerVc.allowPickingVideo = NO;
            // 不允许拍摄视频
            imagePickerVc.allowTakeVideo = NO;
            // 选择图片后的回调
            [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                if (photos.count) {
                    // 多余1张直接 进行图片上传和回调
                    if (photos.count > 1) {
                        [self selectImageFinishedWithImage:photos];
                    }
                    // 只有1张则编辑之后再 进行图片上传和回调
                    else {
                        [self editImage:photos.firstObject];
                    }
                }
            }];
            
            [viewController presentViewController:imagePickerVc animated:YES completion:nil];
        }];
        
        [alertContoller addAction:cameraAction];
        [alertContoller addAction:libraryAction];
        [alertContoller addAction:[UIAlertAction actionWithTitle:YUCLOUD_STRING_CANCEL
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             if (self.sourcesCompletion) {
                                                                 self.sourcesCompletion(NO, nil);
                                                             }
                                                         }]];
        [viewController presentViewController:alertContoller animated:YES completion:nil];
    }
}

- (void)selectImageFinishedWithImage:(NSArray<UIImage *> *)images {
    NSMutableArray *arr = [NSMutableArray array];
    
    if (self.needUpload) {
        MBProgressHUD *hud = [MBProgressHUD showHudOn:[UIApplication sharedApplication].keyWindow
                                                 mode:MBProgressHUDModeAnnularDeterminate
                                                image:nil
                                              message:@"上传中"
                                            delayHide:NO
                                           completion:nil];
        
        dispatch_group_t group = dispatch_group_create();
        for (UIImage *item in images) {
            UIImage *image = [item imageResized:1920];
            NSData *data = UIImageJPEGRepresentation(image, self.uploadQuality > 0?:0.7);
            
            dispatch_group_enter(group);
            [[UploadManager shareManager] uploadData:data
                                                 key:self.uploadKey
                                             fileExt:nil
                                            progress:^(NSUInteger completedBytes, NSUInteger totalBytes) {
                                                hud.progress = completedBytes / (float)totalBytes;
                                            }
                                          completion:^(BOOL success, NSDictionary * _Nullable info) {
                                              if (success) {
                                                  [[SDImageCache sharedImageCache] storeImage:item
                                                                                       forKey:info.url
                                                                                   completion:nil];
                                                  
                                                  NSString *thumbnail = [UploadManager urlOfThumbWithSize:CGSizeMake(512, 512)
                                                                                                     mode:UIViewContentModeScaleAspectFit
                                                                                                     type:nil
                                                                                                   forUrl:info.url];
                                                  NSDictionary *dic = @{@"url"        : info.url,
                                                                        @"thumbnail"  : thumbnail,
                                                                        @"width"      : @(item.size.width),
                                                                        @"height"     : @(item.size.height)};
                                                  [arr addObject:dic];
                                              }
                                              dispatch_group_leave(group);
                                          }];
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [MBProgressHUD finishHudWithResult:arr.count > 0
                                           hud:hud
                                     labelText:arr.count > 0?YUCLOUD_STRING_SUCCESS:YUCLOUD_STRING_FAILED
                                    completion:^{
                                        if (self.sourcesCompletion) {
                                            self.sourcesCompletion(arr.count > 0, @{@"images" : arr.copy});
                                        }
                                    }];
        });
    }
    else {
        for (UIImage *item in images) {
            NSDictionary *dic = @{@"image" : item};
            [arr addObject:dic];
        }
        
        if (self.sourcesCompletion) {
            self.sourcesCompletion(arr.count > 0, @{@"images" : arr.copy});
        }
    }
}

- (void)selectVideoFinishedWithVideo:(NSArray<NSDictionary *> *)videos {
    NSMutableArray *arr = [NSMutableArray array];
    
    if (self.needUpload) {
        MBProgressHUD *hud = [MBProgressHUD showHudOn:[UIApplication sharedApplication].keyWindow
                                                 mode:MBProgressHUDModeIndeterminate
                                                image:nil
                                              message:YUCLOUD_STRING_PLEASE_WAIT
                                            delayHide:NO
                                           completion:nil];
        
        dispatch_group_t group = dispatch_group_create();
        
        for (NSDictionary *item in videos) {
            NSURL *file = item[@"fileUrl"];
            UIImage *image = item[@"thumbnail"];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            NSNumber *height = item[@"height"];
            if (height) {
                [dic setObject:height forKey:@"height"];
            }
            NSNumber *width = item[@"width"];
            if (width) {
                [dic setObject:width forKey:@"width"];
            }
            
            NSData *data = [NSData dataWithContentsOfURL:file];
            
            dispatch_group_enter(group);
            [[UploadManager shareManager] uploadData:data
                                                 key:self.uploadKey
                                             fileExt:@"mov"
                                            progress:^(NSUInteger completedBytes, NSUInteger totalBytes) {
                                                CGFloat progress = (CGFloat)completedBytes / totalBytes;
//                                                DDLog(@"progress: %.0f", progress * 100);
                                                [hud setMode:MBProgressHUDModeDeterminate];
                                                [hud setProgress:progress];
                                                hud.detailsLabel.text = @"上传中";
                                            }
                                          completion:^(BOOL success, NSDictionary * _Nullable info) {
                                              if (success) {
                                                  [dic setObject:info.url forKey:@"url"];
                                                  [arr addObject:dic];
                                              }
                                              dispatch_group_leave(group);
                                          }];
            
            dispatch_group_enter(group);
            [[UploadManager shareManager] uploadData:UIImageJPEGRepresentation(image, .6)
                                                 key:self.uploadKey
                                             fileExt:nil
                                            progress:nil
                                          completion:^(BOOL success, NSDictionary * _Nullable info) {
                                              if (success) {
                                                  [dic setObject:info.url forKey:@"thumbnail"];
                                              }
                                              dispatch_group_leave(group);
                                          }];
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [hud setMode:MBProgressHUDModeIndeterminate];
            [MBProgressHUD finishHudWithResult:arr.count > 0
                                           hud:hud
                                     labelText:arr.count > 0?YUCLOUD_STRING_SUCCESS:YUCLOUD_STRING_FAILED
                                    completion:^{
                                        if (self.sourcesCompletion) {
                                            self.sourcesCompletion(arr.count > 0, @{@"videos" : arr.copy});
                                        }
                                    }];
        });
    }
    else {
        for (NSDictionary *item in videos) {
            [arr addObject:item.copy];
        }
        
        if (self.sourcesCompletion) {
            self.sourcesCompletion(arr.count > 0, @{@"videos" : arr.copy});
        }
    }
}

- (void)editImage:(UIImage *)image {
    [TZImageManager manager].shouldFixOrientation = YES;
    UIImage *fixedImage = [[TZImageManager manager] fixOrientation:image];
    ImageEditViewController *editVC = [[ImageEditViewController alloc] initWithImage:fixedImage delegate:self];
    [TopViewController presentViewController:editVC animated:NO completion:nil];
}

#pragma mark - UINavigationControllerDelegate, UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   NSString *mediaType = info[UIImagePickerControllerMediaType];
                                   // 拍摄的是图片
                                   if ([mediaType isEqualToString:@"public.image"]) {
                                       UIImage *image = info[UIImagePickerControllerOriginalImage];
                                       
                                       if (image) {
                                           // 判断是否需要修改图片
                                           if (self.needCrop) {
                                               [self editImage:[image fixOrientation]];
//                                               CameraImageEditViewController *editVC = [[CameraImageEditViewController alloc] initWithImage:image];
//                                               [self.viewController presentViewController:editVC animated:YES completion:nil];
//
//                                               editVC.comletionBlock = ^(UIImage * _Nonnull editImage) {
//                                                   [self selectImageFinishedWithImage:@[editImage]];
//                                               };
                                           }
                                           else {
                                               [self selectImageFinishedWithImage:@[image]];
                                           }
                                       }
                                       
                                   }
                                   // 拍摄的是视频
                                   else if ([mediaType isEqualToString:@"public.movie"]) {
                                       NSURL *outputPath = info[UIImagePickerControllerMediaURL];
                                       // 判断是否需要修改视频
                                       if (self.needCrop) {
                                           if ([UIVideoEditorController canEditVideoAtPath:outputPath.path]) {
                                               UIVideoEditorController *videoEditor = [[UIVideoEditorController alloc] init];
                                               videoEditor.delegate = self;
                                               videoEditor.videoPath = outputPath.path;
                                               videoEditor.videoMaximumDuration = 0;
                                               videoEditor.modalPresentationStyle = UIModalPresentationFullScreen;
                                               [self.viewController presentViewController:videoEditor animated:YES completion:nil];
                                           }
                                       }
                                       else {
                                           [self thumbnailImageForVideo:outputPath.path atTime:0 block:^(UIImage *thumbImage) {
                                               NSDictionary *dic = @{@"fileUrl":outputPath.path,
                                                                     @"thumbnail":thumbImage,
                                                                     @"width":@(thumbImage.size.width),
                                                                     @"height":@(thumbImage.size.height)};
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   // 处理视频上传和回调
                                                   [self selectVideoFinishedWithVideo:@[dic]];
                                               });
                                           }];
                                       }
                                   }
                               }];
}

#pragma mark - 获取视频缩略图
- (void)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time block:(void(^)(UIImage *thumbImage))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        NSParameterAssert(asset);
        AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
        assetImageGenerator.appliesPreferredTrackTransform = YES;
        assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
        
        CGImageRef thumbnailImageRef = NULL;
        CFTimeInterval thumbnailImageTime = time;
        NSError *thumbnailImageGenerationError = nil;
        thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
        
        if (!thumbnailImageRef)
            NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
        
        __block UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
        
        if (block) {
            block(thumbnailImage);
        }
    });
}

#pragma mark - UIVideoEditorControllerDelegate
- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath {
//    DDLog(@"%@", editedVideoPath);
    [editor dismissViewControllerAnimated:YES completion:nil];
    
    [self thumbnailImageForVideo:[NSURL fileURLWithPath:editedVideoPath] atTime:0 block:^(UIImage *thumbImage) {
        NSDictionary *dic = @{@"fileUrl":[NSURL fileURLWithPath:editedVideoPath],
                              @"thumbnail":thumbImage,
                              @"width":@(thumbImage.size.width),
                              @"height":@(thumbImage.size.height)};
        dispatch_async(dispatch_get_main_queue(), ^{
            // 处理视频上传和回调
            [self selectVideoFinishedWithVideo:@[dic]];
        });
    }];
}

- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error {
//    DDLog(@"%@", error);
    [editor dismissViewControllerAnimated:YES completion:nil];
    
    [MBProgressHUD showFinishHudOn:[UIApplication sharedApplication].keyWindow
                        withResult:NO
                         labelText:error.domain
                         delayHide:YES
                        completion:nil];
}

- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor {
//    DDLog(@"取消编辑");
    [editor dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ImageEditDelegate
- (void)imageEditor:(ImageEditViewController *)viewController didFinishEdittingWithImage:(UIImage *)image {
    [viewController dismissViewControllerAnimated:NO completion:nil];

    [self selectImageFinishedWithImage:@[image]];
}

- (void)imageEditorDidCancel:(ImageEditViewController *)viewController {
//    DDLog(@"取消选择图片");
}

@end
