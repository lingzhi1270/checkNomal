//
//  CameraManager.m
//  Dreamedu
//
//  Created by 唐琦 on 2019/2/21.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "CameraManager.h"
#import <LibUpload/UploadManager.h>

typedef void(^cameraBlock)(NSData *videoData, UIImage *thumbImage, NSData *imageData, UIImage *image);

@interface CameraManager ()
@property (nonatomic, copy) NSString        *uploadKey;         // 上传文件名
@property (nonatomic, copy) CommonBlock     sourcesCompletion;  // 回调

@end

@implementation CameraManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static CameraManager *client;
    dispatch_once(&onceToken, ^{
        client = [[CameraManager alloc] init];
    });
    
    return client;
}

- (void)startCameraWithCameraType:(CameraType)cameraType
                   viewController:(UIViewController *)viewController {
    if (cameraType == CameraTypeDefault) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"调用摄像头"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *backAction = [UIAlertAction actionWithTitle:@"后置摄像头" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            Class CameraClass = NSClassFromString(@"ModCameraStyle1ViewController");
            if (CameraClass && [[CameraClass alloc] respondsToSelector:@selector(initWithTitle:rightItem:)]) {
                BaseViewController *cameraVC = [[CameraClass alloc] initWithTitle:@"" rightItem:nil];
                cameraVC.modalPresentationStyle = UIModalPresentationFullScreen;
                
                if (cameraVC && [cameraVC respondsToSelector:NSSelectorFromString(@"isFrontCamera")]) {
                    [cameraVC setValue:@(NO) forKey:@"isFrontCamera"];
                }
                
                if (cameraVC && [cameraVC respondsToSelector:@selector(setBlock:)]) {
                    cameraBlock block = ^(NSData *videoData, UIImage *thumbImage, NSData *imageData, UIImage *image) {
                        if (videoData && thumbImage) {
                           
                        }
                        else if (imageData && image) {
                           
                        }
                    };
                    [cameraVC performSelector:@selector(setBlock:) withObject:block];
                }
                
                [viewController presentViewController:cameraVC animated:YES completion:nil];
            }
        }];
        
        UIAlertAction *frontAction = [UIAlertAction actionWithTitle:@"前置摄像头" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            Class CameraClass = NSClassFromString(@"ModCameraStyle1ViewController");
            if (CameraClass && [[CameraClass alloc] respondsToSelector:@selector(initWithTitle:rightItem:)]) {
                BaseViewController *cameraVC = [[CameraClass alloc] initWithTitle:@"" rightItem:nil];
                cameraVC.modalPresentationStyle = UIModalPresentationFullScreen;
                
                if (cameraVC && [cameraVC respondsToSelector:NSSelectorFromString(@"isFrontCamera")]) {
                    [cameraVC setValue:@(YES) forKey:@"isFrontCamera"];
                }
                
                if (cameraVC && [cameraVC respondsToSelector:@selector(setBlock:)]) {
                    cameraBlock block = ^(NSData *videoData, UIImage *thumbImage, NSData *imageData, UIImage *image) {
                        if (videoData && thumbImage) {
                           
                        }
                        else if (imageData && image) {
                           
                        }
                    };
                    [cameraVC performSelector:@selector(setBlock:) withObject:block];
                }
                
                [viewController presentViewController:cameraVC animated:YES completion:nil];
            }
        }];
        
        [alert addAction:backAction];
        [alert addAction:frontAction];
        [alert addAction:[UIAlertAction actionWithTitle:YUCLOUD_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
        [viewController presentViewController:alert animated:YES completion:nil];
    }
    else if (cameraType == CameraTypeBack) {
        Class CameraClass = NSClassFromString(@"ModCameraStyle1ViewController");
        if (CameraClass) {
            BaseViewController *cameraVC = [[CameraClass alloc] initWithTitle:@"" rightItem:nil];
            cameraVC.modalPresentationStyle = UIModalPresentationFullScreen;
            
            if (cameraVC && [cameraVC respondsToSelector:NSSelectorFromString(@"isFrontCamera")]) {
                [cameraVC setValue:@(NO) forKey:@"isFrontCamera"];
            }
            
            if (cameraVC && [cameraVC respondsToSelector:@selector(setBlock:)]) {
                cameraBlock block = ^(NSData *videoData, UIImage *thumbImage, NSData *imageData, UIImage *image) {
                    if (videoData && thumbImage) {
                       
                    }
                    else if (imageData && image) {
                       
                    }
                };
                [cameraVC performSelector:@selector(setBlock:) withObject:block];
            }
            
            [viewController presentViewController:cameraVC animated:YES completion:nil];
        }
    }
    else {
        Class CameraClass = NSClassFromString(@"ModCameraStyle1ViewController");
        if (CameraClass && [[CameraClass alloc] respondsToSelector:@selector(initWithTitle:rightItem:)]) {
            BaseViewController *cameraVC = [[CameraClass alloc] initWithTitle:@"" rightItem:nil];
            cameraVC.modalPresentationStyle = UIModalPresentationFullScreen;
            
            if (cameraVC && [cameraVC respondsToSelector:NSSelectorFromString(@"isFrontCamera")]) {
                [cameraVC setValue:@(NO) forKey:@"isFrontCamera"];
            }
            
            if (cameraVC && [cameraVC respondsToSelector:@selector(setBlock:)]) {
                cameraBlock block = ^(NSData *videoData, UIImage *thumbImage, NSData *imageData, UIImage *image) {
                    if (videoData && thumbImage) {
                       
                    }
                    else if (imageData && image) {
                       
                    }
                };
                [cameraVC performSelector:@selector(setBlock:) withObject:block];
            }
            
            [viewController presentViewController:cameraVC animated:YES completion:nil];
        }
    }
}

#pragma mark - 上传图片
- (void)selectImageFinishedWithImage:(NSArray<UIImage *> *)images {
    NSMutableArray *arr = [NSMutableArray array];
    
    MBProgressHUD *hud = [MBProgressHUD showHudOn:[UIApplication sharedApplication].keyWindow
                                             mode:MBProgressHUDModeAnnularDeterminate
                                            image:nil
                                          message:@"上传中"
                                        delayHide:NO
                                       completion:nil];
    
    dispatch_group_t group = dispatch_group_create();
    for (UIImage *item in images) {
        UIImage *image = [item imageResized:1920];
        NSData *data = UIImageJPEGRepresentation(image, 0.7);
        
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

#pragma mark - 上传视频
- (void)selectVideoFinishedWithVideo:(NSArray<NSDictionary *> *)videos {
    NSMutableArray *arr = [NSMutableArray array];
    
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
//                       DDLog(@"progress: %.0f", progress * 100);
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


@end

