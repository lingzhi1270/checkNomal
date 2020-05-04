//
//  VideoEditViewController.h
//  Conversation
//
//  Created by 唐琦 on 2019/5/29.
//

#import <libComponentBase/ConfigureHeader.h>
#import <AVFoundation/AVFoundation.h>
#import "EditorColorPan.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VideoEditorMode) {
    VideoEditorModeNone,     // 默认
    VideoEditorModeDraw,     // 涂鸦
    VideoEditorModeText,     // 文字
    VideoEditorModeClip,     // 裁剪
};

typedef void(^VideoEditCompleteBlock)(NSURL *fileUrl);

@interface VideoEditViewController : BaseViewController
@property (nonatomic, copy) VideoEditCompleteBlock completeBlock;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *undoButton;

@property (nonatomic, strong, readonly) UIImage *editImage;
@property (nonatomic, strong, readonly) UIImageView *drawingView;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) EditorColorPan *colorPan;

@property (nonatomic, assign) VideoEditorMode currentMode;

- (instancetype)initWithPath:(NSString *)path asset:(AVAsset *)asset;
- (void)resetCurrentTool;

@end

NS_ASSUME_NONNULL_END
