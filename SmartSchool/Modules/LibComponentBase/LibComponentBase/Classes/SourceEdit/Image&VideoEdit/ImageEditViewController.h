//
//  ImageEditViewController.h
//  Conversation
//
//  Created by 唐琦 on 2019/5/27.
//

#import "BaseViewController.h"
#import "XScratchView.h"
#import "ImageEditDrawingView.h"
#import "EditorColorPan.h"

typedef NS_ENUM(NSUInteger, ImageEditorMode) {
    ImageEditorModeNone,     // 默认
    ImageEditorModeDraw,     // 涂鸦
    ImageEditorModeText,     // 文字
    ImageEditorModeClip,     // 裁剪
    ImageEditorModeMosica    // 马赛克
};

extern NSString * const kColorPanNotificaiton;



@class ImageEditViewController;
@protocol ImageEditDelegate <NSObject>
@optional
- (void)imageEditor:(ImageEditViewController *)viewController didFinishEdittingWithImage:(UIImage *)image;
- (void)imageEditorDidCancel:(ImageEditViewController *)viewController;

@end

@interface ImageEditViewController : BaseViewController
@property (nonatomic, assign) id<ImageEditDelegate> delegate;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *undoButton;

@property (nonatomic, strong, readonly) UIImage *editImage;
@property (nonatomic, strong, readonly) ImageEditDrawingView *drawingView;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) EditorColorPan *colorPan;

@property (nonatomic, assign) ImageEditorMode currentMode;

- (instancetype)initWithImage:(UIImage*)image delegate:(id<ImageEditDelegate>)delegate;
- (void)resetCurrentTool;
- (void)editTextAgain;
- (void)hiddenTopAndBottomBar:(BOOL)isHide animation:(BOOL)animation;

@end
