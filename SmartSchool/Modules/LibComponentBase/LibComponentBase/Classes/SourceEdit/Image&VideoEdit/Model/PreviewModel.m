//
//  PreviewModel.m
//  Conversation
//
//  Created by qlon 2019/4/16.
//

#import "PreviewModel.h"
#import <AVKit/AVKit.h>

@implementation PreviewModel

- (instancetype)initWithUrl:(NSString *)url
                      image:(UIImage *)image
                    tapView:(UIButton *)tapView
             thumbnailImage:(UIImage *)thumbnailImage
                       type:(PreviewType)type {
    if (self = [super init]) {
        self.url = url;
        self.image = image;
        self.tapView = tapView;
        self.type = type;
        self.firstLoad = YES;
        self.thumbnailImage = thumbnailImage;
        
        if (type == PreviewTypeVideo && !self.thumbnailImage) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                self.thumbnailImage = [self thumbnailImageForVideo:[NSURL URLWithString:url] atTime:0];
            });
        }
    }
    
    return self;
}

- (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
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
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

@end
