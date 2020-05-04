//
//  ACMediaModel.m
//  Created by lingzhi on 2020/1/7.
//

#import "ACMediaModel.h"
#import <TZImagePickerController/TZImagePickerController.h>
@implementation ACMediaModel

+ (instancetype)mediaInfoWithDict: (NSDictionary *)dict
{
    ACMediaModel *model = [[ACMediaModel alloc] init];
    
    NSString *mediaType = [dict objectForKey:UIImagePickerControllerMediaType]; //UIImagePickerControllerPHAsset
    NSURL *referenceURL = [dict objectForKey:UIImagePickerControllerReferenceURL];
    PHAsset *asset;
    //录像与拍照没有引用地址 所以 referenceURL 为nil
    if (referenceURL) {
        PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[referenceURL] options:nil];
        asset = [result firstObject];
    }
    model.asset = asset;
    
    if ([mediaType isEqualToString:@"public.movie"]) {
        NSURL *videoURL = [dict objectForKey:UIImagePickerControllerMediaURL];
        model.name = [self videoNameWithAsset:asset];
        model.data = [NSData dataWithContentsOfURL:videoURL];
        model.videoURL = videoURL;
        model.image = [self coverImageWithVideoURL:videoURL];
    }else if ([mediaType isEqualToString:@"public.image"]) {
        UIImage * image = [dict objectForKey:UIImagePickerControllerEditedImage];
        //如果 picker 没有设置可编辑，那么image 为 nil
        if (image == nil) {
            image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        }
        model.name = [self imageNameWithAsset:asset];
        model.image = [self fixOrientation:image];
        model.data = [self imageDataWithImage:model.image];
    }
    
    return model;
}

+ (instancetype)imageInfoWithAsset: (PHAsset *)asset image: (UIImage *)image
{
    ACMediaModel *model = [[ACMediaModel alloc] init];
    
    model.asset = asset;
    model.data = [self imageDataWithImage:image];
    model.name = [self imageNameWithAsset:asset];
    model.image = image;
    return model;
}

+ (void)videoInfoWithAsset: (PHAsset *)asset coverImage: (UIImage *)coverImage completion: (void(^)(ACMediaModel *model))completion
{
    ACMediaModel *model = [[ACMediaModel alloc] init];
    model.asset = asset;
    model.name = [self videoNameWithAsset:asset];
    model.image = coverImage;
    
//    [self videoDataWithAsset:asset completion:^(NSData * _Nonnull data, NSURL * _Nonnull videoURL) {
//        model.data = data;
//        model.videoURL = videoURL;
//        if (completion) completion(model);
//    }];
    [self videoDataWithAsset:asset completion:^(NSData *data, NSURL *videoURL) {
        model.data = data;
        model.videoURL = videoURL;
        if (completion) completion(model);
    } success:^(NSString *outputPath) {
        
    } failure:^(NSString *errorMessage, NSError *error) {
        
    }];
}

@end

@implementation ACMediaModel (Tool)

#pragma mark - data

+ (NSData *)imageDataWithImage: (UIImage *)image
{
    NSData *imageData = nil;
    if (UIImagePNGRepresentation(image) == nil)
    {
        imageData = UIImageJPEGRepresentation(image, 1);
    } else
    {
        imageData = UIImagePNGRepresentation(image);
    }
    return imageData;
}

+ (void)videoDataWithAsset: (PHAsset *)asset completion: (void(^)(NSData *data, NSURL *videoURL))completion success:(void (^)(NSString *outputPath))success failure:(void (^)(NSString *errorMessage, NSError *error))failure 
{
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
       options.version = PHVideoRequestOptionsVersionOriginal;
       options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
       options.networkAccessAllowed = YES;
    
    /**
     *  旧代码无效 (没有 @"PHImageFileSandboxExtensionTokenKey")
     */
    //    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:options resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
    //        NSString *key = info[@"PHImageFileSandboxExtensionTokenKey"];
    //        NSString *path = [key componentsSeparatedByString:@";"].lastObject;
    //        NSURL *url = [NSURL fileURLWithPath:path];
    //        NSData *data = [NSData dataWithContentsOfURL:url];
    //        if (completion) completion(data,url);
    //    }];

    
      [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
        // NSLog(@"Info:\n%@",info);
        AVURLAsset *videoAsset = (AVURLAsset*)avasset;
        // NSLog(@"AVAsset URL: %@",myAsset.URL);
       NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
        
     
        if ([presets containsObject:AVAssetExportPreset640x480]) {
            AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPreset640x480];
            NSDateFormatter *formater = [[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss-SSS"];
            NSString *outputPath = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/video-%@.mp4", [formater stringFromDate:[NSDate date]]];
            
            // Optimize for network use.
            session.shouldOptimizeForNetworkUse = true;
            
            NSArray *supportedTypeArray = session.supportedFileTypes;
            if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
                session.outputFileType = AVFileTypeMPEG4;
            } else if (supportedTypeArray.count == 0) {
                if (failure) {
                    failure(@"该视频类型暂不支持导出", nil);
                }
                NSLog(@"No supported file types 视频类型暂不支持导出");
                return;
            } else {
                session.outputFileType = [supportedTypeArray objectAtIndex:0];
                if (videoAsset.URL && videoAsset.URL.lastPathComponent) {
                    outputPath = [outputPath stringByReplacingOccurrencesOfString:@".mp4" withString:[NSString stringWithFormat:@"-%@", videoAsset.URL.lastPathComponent]];
                }
            }
            session.outputURL = [NSURL fileURLWithPath:outputPath];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"]]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"] withIntermediateDirectories:YES attributes:nil error:nil];
            }
        
            [session exportAsynchronouslyWithCompletionHandler:^(void) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (session.status) {
                        case AVAssetExportSessionStatusUnknown: {
                            NSLog(@"AVAssetExportSessionStatusUnknown");
                        }  break;
                        case AVAssetExportSessionStatusWaiting: {
                            NSLog(@"AVAssetExportSessionStatusWaiting");
                        }  break;
                        case AVAssetExportSessionStatusExporting: {
                            NSLog(@"AVAssetExportSessionStatusExporting");
                        }  break;
                        case AVAssetExportSessionStatusCompleted: {
                            NSLog(@"AVAssetExportSessionStatusCompleted");
                            if (success) {
                                success(outputPath);
                            NSURL *url = [NSURL fileURLWithPath:outputPath];
                            NSData *data = [NSData dataWithContentsOfURL:url];
                            if (completion) completion(data,url);
                            }
                        }  break;
                        case AVAssetExportSessionStatusFailed: {
                            NSLog(@"AVAssetExportSessionStatusFailed");
                            if (failure) {
                                failure(@"视频导出失败", session.error);
                            }
                        }  break;
                        case AVAssetExportSessionStatusCancelled: {
                            NSLog(@"AVAssetExportSessionStatusCancelled");
                            if (failure) {
                                failure(@"导出任务已被取消", nil);
                            }
                        }  break;
                        default: break;
                    }
                });
            }];
        } else {
            if (failure) {
                NSString *errorMessage = [NSString stringWithFormat:@"当前设备不支持该预设:%@", AVAssetExportPreset640x480];
                failure(errorMessage, nil);
            }
        }
    }];
}
#pragma mark - name

+ (NSString *)imageNameWithAsset: (PHAsset *)asset
{
    return [self mediaNameWithAsset:asset suffixName:@"IMG.PNG"];
}

+ (NSString *)videoNameWithAsset: (PHAsset *)asset
{
    return [self mediaNameWithAsset:asset suffixName:@"Video.MOV"];
}

+ (NSString *)mediaNameWithAsset: (PHAsset *)asset suffixName: (NSString *)suffixName
{
    //default user current time as name.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *normalName = [formatter stringFromDate:[NSDate date]];
    normalName = [normalName stringByAppendingString:suffixName];
    
    if (asset) {
        PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
        //获取本地原图的名称
        if (resource.originalFilename) {
            normalName = resource.originalFilename;
        }
    }
    return normalName;
}

#pragma mark - image

+ (UIImage *)coverImageWithVideoURL: (NSURL *)videoURL
{
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:videoURL];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    //视频总时长
    Float64 duration = CMTimeGetSeconds([urlAsset duration]);
    //取某个帧的时间，参数一表示哪个时间（秒），参数二表示每秒多少帧
    CMTime midPoint = CMTimeMake(duration * 0.5, 600);
    
    NSError *error = nil;
    //缩略图实际生成的时间
    CMTime actucalTime;
    
    //中间帧图片
    CGImageRef centerFrameImage = [imageGenerator copyCGImageAtTime:midPoint actualTime:&actucalTime error:&error];
    
    UIImage *image = nil;
    if (centerFrameImage) {
        image = [UIImage imageWithCGImage:centerFrameImage];
        CGImageRelease(centerFrameImage);
    }
    return image;
}

+ (UIImage *)fixOrientation:(UIImage *)aImage
{
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
