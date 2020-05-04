//
//  ImageEditViewController.m
//  Conversation
//
//  Created by 唐琦 on 2019/5/27.
//

#import "ImageEditViewController.h"
#import "WBGImageToolBase.h"
#import "WBGDrawTool.h"
#import "WBGTextTool.h"
#import "TOCropViewController.h"
#import "UIImage+CropRotate.h"
#import "WBGTextToolView.h"
#import "UIView+YYAdd.h"
#import "XRGBTool.h"
#import "EditorColorPan.h"
#import "UIImage+JSPP.h"

#define KImageEditPanButtonTag          10001
#define KImageEditTextButtonTag         10002
#define KImageEditClipButtonTag         10003
#define KImageEditMosicaButtonTag       10004

@interface ImageEditViewController () <UINavigationBarDelegate, UIScrollViewDelegate, TOCropViewControllerDelegate>

@property (nonatomic, strong, nullable) WBGImageToolBase *currentTool;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;

@property (nonatomic, strong) UIView *topBannerView;
@property (nonatomic, strong) UIView *bottomBannerView;
@property (nonatomic, strong) UIView *leftBannerView;
@property (nonatomic, strong) UIView *rightBannerView;

@property (nonatomic, strong) ImageEditDrawingView *drawingView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) EditorColorPan *colorPan;

@property (nonatomic, strong) UIButton *panButton;
@property (nonatomic, strong) UIButton *mosicaButton;
@property (nonatomic, strong) NSMutableArray *actionButtons;

@property (nonatomic, strong) WBGDrawTool *drawTool;
@property (nonatomic, strong) WBGTextTool *textTool;
@property (nonatomic, strong) XScratchView *scratchView;

@property (nonatomic, copy  ) UIImage   *originImage;

@property (nonatomic, assign) CGFloat clipInitScale;
@property (nonatomic, assign) BOOL barsHiddenStatus;

@end

@implementation ImageEditViewController

- (instancetype)initWithImage:(UIImage*)image delegate:(id<ImageEditDelegate>)delegate {
    if (self = [self initWithTitle:@"" rightItem:nil]){
        self.originImage = image;
        self.delegate = delegate;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.topView.hidden = YES;
    
    self.topBannerView = [[UIView alloc] init];
    self.topBannerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.topBannerView];
    
    self.bottomBannerView = [[UIView alloc] init];
    self.bottomBannerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.bottomBannerView];
    
    self.leftBannerView = [[UIView alloc] init];
    self.leftBannerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.leftBannerView];
    
    self.rightBannerView = [[UIView alloc] init];
    self.rightBannerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.rightBannerView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollView];

    CGFloat topMargin = [UIScreen resolution] > UIDeviceResolution_iPhoneRetina6p ? 44 : 0;
    self.scratchView = [[XScratchView alloc] initWithFrame:CGRectMake(0, topMargin, SCREENWIDTH, SCREENHEIGHT-topMargin-KBottomSafeHeight)];
    self.scratchView.surfaceImage = self.originImage;
    self.scratchView.mosaicImage = [XRGBTool getMosaicImageWith:self.originImage level:0];
    [self.view addSubview:self.scratchView];
    
    WEAK(self, weakSelf);
    self.scratchView.XScratchViewDidMove = ^(BOOL canRecover) {
        if (weakSelf.undoButton.hidden == canRecover) {
            weakSelf.undoButton.hidden = NO;
        }
    };
    
    self.drawingView = [[ImageEditDrawingView alloc] initWithFrame:CGRectMake(0, topMargin, SCREENWIDTH, SCREENHEIGHT-topMargin-KBottomSafeHeight)];
    self.drawingView.backgroundColor = [UIColor clearColor];
    self.drawingView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:self.drawingView];
    
    self.topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, KTopViewHeight)];
    self.topBar.backgroundColor = [UIColor colorAlphaFromHex:0x00000033];
    [self.view addSubview:self.topBar];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = CGRectMake(15, KStatusBarHeight, 44.f, 44.f);
    [self.backButton setImage:nil forState:UIControlStateNormal];
    [self.backButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar addSubview:self.backButton];
    
    self.undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.undoButton.frame = CGRectMake(SCREENWIDTH-15-44, KStatusBarHeight, 44.f, 44.f);
    [self.undoButton setTitle:@"撤销" forState:UIControlStateNormal];
    [self.undoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.undoButton addTarget:self action:@selector(undoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar addSubview:self.undoButton];
    
    self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT-kTabbarHeight, SCREENWIDTH, kTabbarHeight)];
    self.bottomBar.backgroundColor = [UIColor colorAlphaFromHex:0x00000022];
    [self.view addSubview:self.bottomBar];
    
    self.colorPan = [[EditorColorPan alloc] initWithFrame:CGRectMake(SCREENWIDTH-15-30, KTopViewHeight+36, 30, 30*7)];
    [self.view addSubview:self.colorPan];
    
    NSArray *images = @[@"annotate", @"text", @"clip", @"qrcode"];
    NSArray *selectedImages = @[@"annotate_selected", @"text_selected", @"", @"videoMuteButtonSelected"];
    self.actionButtons = [NSMutableArray arrayWithCapacity:0];
    CGFloat margin = (SCREENWIDTH-44*5) / 6;
    for (int i = 0; i < 5; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 10001+i;
        [self.bottomBar addSubview:button];
        [self.actionButtons addObject:button];
        
        if (i == 0) {
            self.panButton = button;
        }
        
        if (i < images.count) {
            NSString *imageName = images[i];
            NSString *selectedImageName = selectedImages[i];

            [button setImage:[UIImage imageNamed:imageName bundleName:@"ModCameraStyle1"]
                    forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:selectedImageName bundleName:@"ModCameraStyle1"]
                    forState:UIControlStateSelected];
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [button setTitle:@"提交" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRGB:0x2EAAEE] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bottomBar);
            make.left.equalTo(self.bottomBar).offset(margin+(44+margin)*i);
            make.size.equalTo(@(CGSizeMake(44, 44)));
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.undoButton.hidden = YES;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.panButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //ShowBusyIndicatorForView(self.view);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //  HideBusyIndicatorForView(self.view);
        [self refreshImageView];
    });
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - 初始化 &getter
- (WBGDrawTool *)drawTool {
    if (_drawTool == nil) {
        _drawTool = [[WBGDrawTool alloc] initWithImageEditor:self];
        
        __weak typeof(self)weakSelf = self;
        _drawTool.drawToolStatus = ^(BOOL canPrev) {
            if (canPrev) {
                weakSelf.undoButton.hidden = NO;
            }
            else {
                weakSelf.undoButton.hidden = YES;
            }
        };
        _drawTool.drawingCallback = ^(BOOL isDrawing) {
            if (weakSelf.barsHiddenStatus != isDrawing) {
                [weakSelf hiddenTopAndBottomBar:isDrawing animation:YES];
            }
        };
        _drawTool.drawingDidTap = ^(void) {
            [weakSelf hiddenTopAndBottomBar:!weakSelf.barsHiddenStatus animation:YES];
        };
    }
    
    return _drawTool;
}

- (WBGTextTool *)textTool {
    if (_textTool == nil) {
        _textTool = [[WBGTextTool alloc] initWithImageEditor:self];
        __weak typeof(self)weakSelf = self;
        _textTool.dissmissTextTool = ^(NSString *currentText) {
            [weakSelf hiddenColorPan:NO animation:YES];
            weakSelf.currentMode = ImageEditorModeNone;
            weakSelf.drawingView.isMosica = NO;
        };
        _textTool.textToolDidTap = ^(BOOL isHidden) {
            if (weakSelf.barsHiddenStatus != isHidden) {
                [weakSelf hiddenTopAndBottomBar:isHidden animation:YES];
            }
        };
        _textTool.textToolDidPan = ^(BOOL isHidden) {
            if (weakSelf.barsHiddenStatus != isHidden) {
                [weakSelf hiddenTopAndBottomBar:isHidden animation:YES];
            }
        };
        _textTool.textToolDidPinch = ^(BOOL isHidden) {
            if (weakSelf.barsHiddenStatus != isHidden) {
                [weakSelf hiddenTopAndBottomBar:isHidden animation:YES];
            }
        };
            
        _textTool.textToolDidRotate = ^(BOOL isHidden) {
            if (weakSelf.barsHiddenStatus != isHidden) {
                [weakSelf hiddenTopAndBottomBar:isHidden animation:YES];
            }
        };
    }
    
    return _textTool;
}

- (UIImage *)editImage {
    return self.scratchView.surfaceImage;
}

- (void)refreshImageView {
    if (self.scratchView.surfaceImage == nil) {
        self.scratchView.surfaceImage = self.originImage;
    }
    
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimated:NO];
    
    self.topBannerView.frame = CGRectMake(0, 0, self.scratchView.width, CGRectGetMinY(self.scratchView.frame));
    self.bottomBannerView.frame = CGRectMake(0, CGRectGetMaxY(self.scratchView.frame), self.scratchView.width, self.drawingView.height - CGRectGetMaxY(self.scratchView.frame));
    self.leftBannerView.frame = CGRectMake(0, 0, CGRectGetMinX(self.scratchView.frame), self.drawingView.height);
    self.rightBannerView.frame = CGRectMake(CGRectGetMaxX(self.scratchView.frame), 0, self.drawingView.width - CGRectGetMaxX(self.scratchView.frame), self.drawingView.height);
}

- (void)resetImageViewFrame {
    CGSize size = (self.scratchView.surfaceImage) ? self.scratchView.surfaceImage.size : self.scratchView.frame.size;
    if (size.width > 0 && size.height > 0) {
        CGFloat ratio = MIN(self.scrollView.frame.size.width / size.width, self.scrollView.frame.size.height / size.height);
        CGFloat W = ratio * size.width * self.scrollView.zoomScale;
        CGFloat H = ratio * size.height * self.scrollView.zoomScale;
        
        [self.scratchView changeRectWithFrame:CGRectMake(MAX(0, (self.scrollView.width-W)/2), MAX(0, (self.scrollView.height-H)/2), W, H)];
        self.drawingView.frame = CGRectMake(MAX(0, (_scrollView.width-W)/2), MAX(0, (_scrollView.height-H)/2), W, H);
    }
}

- (void)resetZoomScaleWithAnimated:(BOOL)animated {
    CGFloat Rw = _scrollView.frame.size.width / self.scratchView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / self.scratchView.frame.size.height;
    
    //CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat scale = 1;
    Rw = MAX(Rw, self.scratchView.surfaceImage.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, self.scratchView.surfaceImage.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = self.scratchView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 3);
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
    [self scrollViewDidZoom:_scrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- ScrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.scratchView.superview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
}

#pragma mark - Property
- (void)setCurrentTool:(WBGImageToolBase *)currentTool {
    if(_currentTool != currentTool) {
        [_currentTool cleanup];
        _currentTool = currentTool;
        [_currentTool setup];
        
    }
    
    [self swapToolBarWithEditting];
}

#pragma mark - Actions
// 发送
- (void)sendAction:(UIButton *)sender {
    [self buildClipImageShowHud:YES clipedCallback:^(UIImage *clipedImage) {
        if ([self.delegate respondsToSelector:@selector(imageEditor:didFinishEdittingWithImage:)]) {
            [self.delegate imageEditor:self didFinishEdittingWithImage:clipedImage];
        }
    }];
}

- (void)buttonAction:(UIButton *)sender {
    for (UIButton *button in self.actionButtons) {
        if (button == sender) {
            sender.selected = YES;
        }
        else {
            sender.selected = NO;
        }
    }
    
    switch (sender.tag) {
        case KImageEditPanButtonTag:
            [self panAction];
            break;
        
        case KImageEditTextButtonTag:
            [self textAction];
            break;
            
        case KImageEditClipButtonTag:
            [self clipAction];
            break;
            
        case KImageEditMosicaButtonTag:
            [self mosicaAction];
            break;
        default:
            break;
    }
}

// 涂鸦模式
- (void)panAction {
    if (_currentMode == ImageEditorModeDraw) {
        return;
    }
    
    //先设置状态，然后在干别的
    self.currentMode = ImageEditorModeDraw;
    self.drawingView.isMosica = NO;
    
    self.currentTool = self.drawTool;
    [self hiddenColorPan:NO animation:YES];
}

// 文字模式
- (void)textAction {
    if (_currentMode == ImageEditorModeText) {
        return;
    }

    //先设置状态，然后在干别的
    self.currentMode = ImageEditorModeText;
    self.drawingView.isMosica = NO;
    
    self.currentTool = self.textTool;
    [self hiddenColorPan:YES animation:YES];
}

// 裁剪模式
- (void)clipAction {
    __weak typeof(self)weakSelf = self;
    
    [self buildClipImageShowHud:NO clipedCallback:^(UIImage *clipedImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:TOCropViewCroppingStyleDefault image:clipedImage];
            cropController.delegate = weakSelf;
            CGRect viewFrame = [weakSelf.view convertRect:weakSelf.scratchView.frame toView:weakSelf.navigationController.view];
            [cropController presentAnimatedFromParentViewController:weakSelf
                                                          fromImage:clipedImage
                                                           fromView:nil
                                                          fromFrame:viewFrame
                                                              angle:0
                                                       toImageFrame:CGRectZero
                                                              setup:^{
                                                                  [weakSelf refreshImageView];
                                                                  weakSelf.colorPan.hidden = YES;
                                                                  weakSelf.currentMode = ImageEditorModeClip;
                                                                  weakSelf.drawingView.isMosica = NO;
                                                              }
                                                         completion:nil];
        });
    }];
}

// 马赛克
- (void)mosicaAction {
    if (_currentMode == ImageEditorModeMosica) {
        return;
    }
    //先设置状态，然后在干别的
    self.currentMode = ImageEditorModeMosica;
    self.drawingView.isMosica = YES;
    [self hiddenColorPan:YES animation:YES];
}

- (void)closeView {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageEditorDidCancel:)]) {
        [self.delegate imageEditorDidCancel:self];
    }
}

- (void)undoAction {
    if (self.currentMode == ImageEditorModeDraw) {
        WBGDrawTool *tool = (WBGDrawTool *)self.currentTool;
        [tool backToLastDraw];
    }
    else if (self.currentMode == ImageEditorModeMosica) {
        [self.scratchView recover];
        self.undoButton.hidden = YES;
    }
}
- (void)editTextAgain {
    //WBGTextTool 钩子调用
    
    if (_currentMode == ImageEditorModeText) {
        return;
    }
    //先设置状态，然后在干别的
    self.currentMode = ImageEditorModeText;
    self.drawingView.isMosica = NO;
    
    if(_currentTool != self.textTool) {
        [_currentTool cleanup];
        _currentTool = self.textTool;
        [_currentTool setup];
        
    }
    
    [self hiddenColorPan:YES animation:YES];
}

- (void)resetCurrentTool {
    self.currentMode = ImageEditorModeNone;
    self.drawingView.isMosica = NO;
}

#pragma mark - Cropper Delegate
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle {
    [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}

- (void)updateImageViewWithImage:(UIImage *)image fromCropViewController:(TOCropViewController *)cropViewController {
    self.scratchView.surfaceImage = image;
    self.scratchView.mosaicImage = [XRGBTool getMosaicImageWith:image level:0];
    
    __unused CGFloat drawingWidth = self.drawingView.bounds.size.width;
    CGRect bounds = cropViewController.cropView.foregroundImageView.bounds;
    bounds.size = CGSizeMake(bounds.size.width/self.clipInitScale, bounds.size.height/self.clipInitScale);
    
    [self refreshImageView];
    
    __weak typeof(self)weakSelf = self;
    if (cropViewController.croppingStyle != TOCropViewCroppingStyleCircular) {
        [cropViewController dismissAnimatedFromParentViewController:self
                                                   withCroppedImage:image
                                                             toView:self.scratchView
                                                            toFrame:CGRectZero
                                                              setup:^{
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      [weakSelf refreshImageView];
                                                                      weakSelf.colorPan.hidden = NO;
                                                                  });
                                                              }
                                                         completion:^{
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 weakSelf.colorPan.hidden = NO;
                                                             });
                                                         }];
    }
    else {
        [cropViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    //生成图片后，清空画布内容
    [self.drawTool.allLineMutableArray removeAllObjects];
    [self.drawTool drawLine];
    [_drawingView removeAllSubviews];
    self.undoButton.hidden = YES;
}

- (void)cropViewController:(TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled {
    __weak typeof(self)weakSelf = self;
    [cropViewController dismissAnimatedFromParentViewController:self
                                               withCroppedImage:self.scratchView.surfaceImage
                                                         toView:self.scratchView
                                                        toFrame:CGRectZero
                                                          setup:^{
                                                              [weakSelf refreshImageView];
                                                              weakSelf.colorPan.hidden = NO;
                                                          }
                                                     completion:^{
                                                         [UIView animateWithDuration:.3f animations:^{
                                                             weakSelf.colorPan.hidden = NO;
                                                         }];
                                                     }];
}

#pragma mark -
- (void)swapToolBarWithEditting {
    switch (_currentMode) {
        case ImageEditorModeDraw : {
            self.panButton.selected = YES;
            if (self.drawTool.allLineMutableArray.count > 0) {
                self.undoButton.hidden  = NO;
            }
        }
            break;
        case ImageEditorModeText:
        case ImageEditorModeClip:
        case ImageEditorModeMosica:
        case ImageEditorModeNone: {
            self.panButton.selected = NO;
            self.undoButton.hidden  = YES;
        }
            break;
        default:
            break;
    }
}

- (void)hiddenTopAndBottomBar:(BOOL)isHide animation:(BOOL)animation {
    if (isHide) {
        self.topBar.alpha = 1.0;
        self.bottomBar.alpha = 1.0;
        self.colorPan.alpha = 1.0;
    }
    else {
        self.topBar.alpha = 0.0;
        self.bottomBar.alpha = 0.0;
        self.colorPan.alpha = 0.0;
    }
    
    [UIView animateWithDuration:animation ? .25f : 0.f
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:1
                        options:isHide ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         if (isHide) {
                             self.topBar.alpha = 0.0;
                             self.bottomBar.alpha = 0.0;
                             self.colorPan.alpha = 0.0;
                         }
                         else {
                             self.topBar.alpha = 1.0;
                             self.bottomBar.alpha = 1.0;
                             self.colorPan.alpha = 1.0;
                         }
                         self.barsHiddenStatus = isHide;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)hiddenColorPan:(BOOL)yesOrNot animation:(BOOL)animation {
    [UIView animateWithDuration:animation ? .25f : 0.f
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:1
                        options:yesOrNot ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.colorPan.hidden = yesOrNot;
                     } completion:^(BOOL finished) {
                         
                     }];
}

+ (UIImage *)createViewImage:(UIView *)shareView {
    UIGraphicsBeginImageContextWithOptions(shareView.bounds.size, NO, [UIScreen mainScreen].scale);
    [shareView.layer renderInContext:UIGraphicsGetCurrentContext()];
    shareView.layer.affineTransform = shareView.transform;
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)buildClipImageShowHud:(BOOL)showHud clipedCallback:(void(^)(UIImage *clipedImage))clipedCallback {
    if (showHud) {
        //ShowBusyTextIndicatorForView(self.view, @"生成图片中...", nil);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat WS = self.scratchView.width/ self.drawingView.width;
        CGFloat HS = self.scratchView.height/ self.drawingView.height;
        
        UIGraphicsBeginImageContextWithOptions(self.scratchView.frame.size, NO, self.scratchView.surfaceImage.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.scratchView.layer renderInContext:context];
        UIImage *mosicaImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIGraphicsBeginImageContext(self.scratchView.surfaceImage.size);
        [mosicaImage drawAtPoint:CGPointZero];
        CGFloat viewToimgW = self.scratchView.width/self.scratchView.surfaceImage.size.width;
        CGFloat viewToimgH = self.scratchView.height/self.scratchView.surfaceImage.size.height;
        __unused CGFloat drawX = self.scratchView.left/viewToimgW;
        CGFloat drawY = self.scratchView.top/viewToimgH;
        
        // 绘制底图+马赛克
        [mosicaImage drawInRect:CGRectMake(0, 0, self.scratchView.surfaceImage.size.width/WS, self.scratchView.surfaceImage.size.height/HS)];
        // 绘制涂鸦
        [self.drawingView.image drawInRect:CGRectMake(0, -drawY, self.scratchView.surfaceImage.size.width/WS, self.scratchView.surfaceImage.size.height/HS)];
        // 绘制文字
        for (UIView *subV in self.drawingView.subviews) {
            if ([subV isKindOfClass:[WBGTextToolView class]]) {
                WBGTextToolView *textLabel = (WBGTextToolView *)subV;
                //进入正常状态
                [WBGTextToolView setInactiveTextView:textLabel];
                
                //生成图片
                __unused UIView *tes = textLabel.archerBGView;
                UIImage *textImg = [self.class screenshot:textLabel.archerBGView orientation:UIDeviceOrientationPortrait usePresentationLayer:YES];
                CGFloat rotation = textLabel.archerBGView.layer.transformRotationZ;
                textImg = [textImg imageRotatedByRadians:rotation];
                
                CGFloat selfRw = self.scratchView.bounds.size.width / self.scratchView.surfaceImage.size.width;
                CGFloat selfRh = self.scratchView.bounds.size.height / self.scratchView.surfaceImage.size.height;
                
                CGFloat sw = textImg.size.width / selfRw;
                CGFloat sh = textImg.size.height / selfRh;
                
                [textImg drawInRect:CGRectMake(textLabel.left/selfRw, (textLabel.top/selfRh) - drawY, sw, sh)];
            }
        }
        
        UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //HideBusyIndicatorForView(self.view);
//            UIImage *image = [UIImage imageWithCGImage:tmp.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            UIImage *image = [tmp fixOrientation];
            clipedCallback(image);
            
        });
    });
}

+ (UIImage *)screenshot:(UIView *)view orientation:(UIDeviceOrientation)orientation usePresentationLayer:(BOOL)usePresentationLayer {
    CGSize size = view.bounds.size;
    CGSize targetSize = CGSizeMake(size.width * view.layer.transformScaleX, size.height *  view.layer.transformScaleY);
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, [UIScreen mainScreen].scale);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    [view drawViewHierarchyInRect:CGRectMake(0, 0, targetSize.width, targetSize.height) afterScreenUpdates:NO];
    CGContextRestoreGState(ctx);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end


