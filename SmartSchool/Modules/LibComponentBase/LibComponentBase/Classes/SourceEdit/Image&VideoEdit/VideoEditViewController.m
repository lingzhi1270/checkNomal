//
//  VideoEditViewController.m
//  Conversation
//
//  Created by 唐琦 on 2019/5/29.
//

#import "VideoEditViewController.h"
#import "PreviewModel.h"
#import "WBGImageToolBase.h"
#import "WBGDrawTool.h"
#import "WBGTextTool.h"
#import "WBGTextToolView.h"
#import "VideoPieces.h"
#import "FOFMoviePlayer.h"
#import "UIImage+CropRotate.h"

#define KImageEditPanButtonTag          10001
#define KImageEditTextButtonTag         10002
#define KImageEditClipButtonTag         10003

@interface VideoEditViewController ()
@property (nonatomic, strong) UIView            *topBar;
@property (nonatomic, strong) UIView            *bottomBar;
@property (nonatomic, strong) FOFMoviePlayer    *videoPlayView;
@property (nonatomic, strong) UIScrollView      *scrollView;
@property (nonatomic, strong) UIImageView       *drawingView;
@property (nonatomic, strong) EditorColorPan    *colorPan;
@property (nonatomic, strong) NSString          *path;
@property (nonatomic, strong) NSMutableArray    *actionButtons;
@property (nonatomic, strong) VideoPieces       *videoPieces;
@property (nonatomic, strong) UIView            *clipBottomView;
@property (nonatomic, assign) CGFloat           totalSeconds;
@property (nonatomic, assign) CGFloat           lastStartSeconds;
@property (nonatomic, assign) CGFloat           lastEndSeconds;
@property (nonatomic, assign) BOOL              barsHiddenStatus;
@property (nonatomic, assign) BOOL              seeking;
@property (nonatomic, strong) id                timeObserverToken;
@property (nonatomic, strong) AVAsset           *currentAsset;

// 编辑工具
@property (nonatomic, strong, nullable) WBGImageToolBase *currentTool;
@property (nonatomic, strong) WBGDrawTool       *drawTool;
@property (nonatomic, strong) WBGTextTool       *textTool;

@end

@implementation VideoEditViewController

- (instancetype)initWithPath:(NSString *)path asset:(AVAsset *)asset{
    if (self = [super initWithTitle:@"" rightItem:nil]) {
        self.path = path;
        self.currentAsset = asset;
        [self.currentAsset tracksWithMediaType:AVMediaTypeVideo];
    }
    
    return self;
}

#pragma mark - 懒加载
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

- (VideoPieces *)videoPieces {
    if (!_videoPieces) {
        WEAK(self, weakSelf);
        _videoPieces = [[VideoPieces alloc] initWithFrame:CGRectMake(50, CGRectGetMinY(self.bottomBar.frame)-50-20, SCREENWIDTH-50*2, 50)];
        _videoPieces.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_videoPieces];
        [_videoPieces setBlockSeekOffLeft:^(CGFloat offX) {
            weakSelf.seeking = true;
            [weakSelf.videoPlayView fof_pause];
            weakSelf.lastStartSeconds = weakSelf.totalSeconds*offX/CGRectGetWidth(weakSelf.videoPieces.bounds);
            [weakSelf.videoPlayView.player seekToTime:CMTimeMakeWithSeconds(weakSelf.lastStartSeconds, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }];
        [_videoPieces setBlockSeekOffRight:^(CGFloat offX) {
            weakSelf.seeking = true;
            [weakSelf.videoPlayView fof_pause];
            weakSelf.lastEndSeconds = weakSelf.totalSeconds*offX/CGRectGetWidth(weakSelf.videoPieces.bounds);
            if (weakSelf.lastEndSeconds - weakSelf.lastStartSeconds <= 1.0) {
                weakSelf.lastEndSeconds = weakSelf.lastStartSeconds + 1.0;
            }
            
            [weakSelf.videoPlayView.player seekToTime:CMTimeMakeWithSeconds(weakSelf.lastEndSeconds, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }];
        
        [_videoPieces setBlockMoveEnd:^{
            NSLog(@"滑动结束");
            if (weakSelf.seeking) {
                weakSelf.seeking = false;
                [weakSelf private_replayAtBeginTime:weakSelf.lastStartSeconds];
            }
        }];
        
        CGFloat widthIV = (CGRectGetWidth(_videoPieces.frame))/10.0;
        CGFloat heightIV = CGRectGetHeight(_videoPieces.frame);
        
        [self getVideoThumbnail:self.path count:10 splitCompleteBlock:^(BOOL success, NSMutableArray *splitimgs) {
            for (int i = 0; i < splitimgs.count; i++) {
                UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(i*widthIV, 3, widthIV, heightIV-6)];
                iv.contentMode = UIViewContentModeScaleToFill;
                iv.image = splitimgs[i];
                [weakSelf.videoPieces insertSubview:iv atIndex:1];
            }
        }];
    }
    
    return _videoPieces;
}

- (UIView *)clipBottomView {
    if (!_clipBottomView) {
        _clipBottomView = [[UIView alloc] init];
        _clipBottomView.backgroundColor = [UIColor colorAlphaFromHex:0x00000022];
        [self.view addSubview:_clipBottomView];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setImage:nil forState:UIControlStateNormal];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelClipAction) forControlEvents:UIControlEventTouchUpInside];
        [_clipBottomView addSubview:cancelButton];
        
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmClipAction) forControlEvents:UIControlEventTouchUpInside];
        [_clipBottomView addSubview:confirmButton];
        
        [_clipBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-KBottomSafeHeight);
            make.height.equalTo(@40.f);
        }];
        
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_clipBottomView).offset(15);
            make.centerY.equalTo(_clipBottomView);
            make.size.equalTo(@(CGSizeMake(40, 40)));
        }];
        
        [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_clipBottomView).offset(-15);
            make.centerY.equalTo(_clipBottomView);
            make.size.equalTo(@(CGSizeMake(40, 40)));
        }];
    }
    
    return _clipBottomView;
}

- (UIImage *)editImage {
    return nil;
}

- (void)loadView {
    [super loadView];
    WEAK(self, weakSelf);
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollView];

    CGFloat topMargin = [UIScreen resolution] > UIDeviceResolution_iPhoneRetina6p ? 44 : 0;
    self.videoPlayView = [[FOFMoviePlayer alloc] initWithFrame:CGRectMake(0, topMargin, SCREENWIDTH, SCREENHEIGHT-KBottomSafeHeight-topMargin)
                                                           url:[NSURL fileURLWithPath:self.path]
                                                    superLayer:self.view.layer];
    
    [self.videoPlayView setBlockStatusReadyPlay:^(AVPlayerItem *playItem){
        [weakSelf.videoPlayView fof_play];
        weakSelf.totalSeconds = CMTimeGetSeconds(playItem.duration);
        weakSelf.lastEndSeconds = weakSelf.totalSeconds;
    }];
    
    [self.videoPlayView setBlockPlayToEndTime:^{
        [weakSelf private_replayAtBeginTime:weakSelf.lastStartSeconds];
    }];
    // 如果对于时间精度要求比较小，可以适当增加timescale的值。这里是1.0/10 = 0.1;
    self.timeObserverToken = [self.videoPlayView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (!weakSelf.seeking) {
            if (fabs(CMTimeGetSeconds(time)-weakSelf.lastEndSeconds) <= 0.2) {
                [weakSelf private_replayAtBeginTime:weakSelf.lastStartSeconds];
            }
        }
    }];
    
    self.drawingView = [[UIImageView alloc] init];
    self.drawingView.backgroundColor = [UIColor clearColor];
    self.drawingView.contentMode = UIViewContentModeCenter;
    self.drawingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.drawingView];
    
    self.topBar = [[UIView alloc] init];
    self.topBar.backgroundColor = [UIColor colorAlphaFromHex:0x00000022];
    [self.view addSubview:self.topBar];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:nil forState:UIControlStateNormal];
    [self.backButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar addSubview:self.backButton];
    
    self.undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.undoButton setTitle:@"撤销" forState:UIControlStateNormal];
    [self.undoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.undoButton addTarget:self action:@selector(undoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar addSubview:self.undoButton];
    
    self.bottomBar = [[UIView alloc] init];
    self.bottomBar.backgroundColor = [UIColor colorAlphaFromHex:0x00000022];
    [self.view addSubview:self.bottomBar];
    
    self.colorPan = [[EditorColorPan alloc] init];
    self.colorPan.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 100, self.colorPan.bounds.size.width, self.colorPan.bounds.size.height);
    [self.view addSubview:self.colorPan];
    
    NSArray *images = @[@"annotate", @"text", @"clip"];
    NSArray *selectedImages = @[@"annotate_selected", @"text_selected", @""];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ModCameraStyle1" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];

    self.actionButtons = [NSMutableArray arrayWithCapacity:0];
    CGFloat margin = (SCREENWIDTH-40*4) / 5;
    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 10001+i;
        [self.bottomBar addSubview:button];
        [self.actionButtons addObject:button];
        
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
            [button addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bottomBar);
            make.left.equalTo(self.bottomBar).offset(margin+(40+margin)*i);
            make.size.equalTo(@(CGSizeMake(40, 40)));
        }];
    }
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.equalTo(@(KTopViewHeight));
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topBar).offset(15);
        make.bottom.equalTo(self.topBar);
        make.size.equalTo(@(CGSizeMake(44, 44)));
    }];
    
    [self.undoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topBar).offset(-15);
        make.bottom.equalTo(self.topBar);
        make.size.equalTo(@(CGSizeMake(44, 44)));
    }];
    
    [self.drawingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(topMargin);
        make.bottom.equalTo(self.view).offset(-KBottomSafeHeight);
        make.size.equalTo(@(CGSizeMake(SCREENWIDTH, SCREENHEIGHT-topMargin-KBottomSafeHeight)));
    }];
    
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-KBottomSafeHeight);
        make.height.equalTo(@40.f);
    }];
    
    [self.colorPan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view).offset(KTopViewHeight+36);
        make.width.equalTo(@(30.f));
        make.height.equalTo(@(30.*7));
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)private_replayAtBeginTime:(Float64)beginTime{
    [self.videoPlayView.player seekToTime:CMTimeMakeWithSeconds(self.lastStartSeconds, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.videoPlayView fof_play];
}

- (void)videoCutIsClip:(BOOL)isClip {
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // 视频轨迹
    AVAssetTrack *videoAssetTrack = [[self.currentAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    // 音频轨迹
    AVAssetTrack *audioAssetTrack = [[self.currentAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    // 2.将素材的视频插入视频轨道 ，音频插入音轨
    AVMutableComposition *composition = [AVMutableComposition composition];
    // 视频轨道
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                     preferredTrackID:kCMPersistentTrackID_Invalid];
    // 在视频轨道插入一个时间段的视频
    NSError *videoError = nil;
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.currentAsset.duration)
                        ofTrack:videoAssetTrack
                         atTime:kCMTimeZero
                          error:&videoError];
    // 音频轨道
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                     preferredTrackID:kCMPersistentTrackID_Invalid];
    // 插入音频数据，否则没有声音
    NSError *audioError = nil;
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.currentAsset.duration)
                        ofTrack:audioAssetTrack
                         atTime:kCMTimeZero
                          error:&audioError];
    
    // 3. 裁剪视频，就是要将所有的视频轨道进行裁剪，就需要得到所有的视频轨道，而得到一个视频轨道就需要得到它上面的所有素材
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    CMTime totalDuration = CMTimeAdd(kCMTimeZero, self.currentAsset.duration);
    
    CGFloat videoAssetTrackNaturalWidth = videoAssetTrack.naturalSize.width;
    CGFloat videoAssetTrackNatutalHeight = videoAssetTrack.naturalSize.height;
    [layerInstruction setOpacity:0.0 atTime:totalDuration];
    
    AVMutableVideoCompositionInstruction *instrucation = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instrucation.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    instrucation.layerInstructions = @[layerInstruction];
    
    AVMutableVideoComposition *mainComposition = [AVMutableVideoComposition videoComposition];
    mainComposition.instructions = @[instrucation];
    mainComposition.frameDuration = CMTimeMake(1, 30);
    mainComposition.renderSize = CGSizeMake(videoAssetTrackNaturalWidth, videoAssetTrackNatutalHeight); // 裁剪出对应大小
    
    int degrees = [self degressFromVideoFileWithAsset:self.currentAsset];
    if (degrees != 0) {
        CGAffineTransform translateToCenter;
        CGAffineTransform mixedTransform;

        if (degrees == 90) {
            // 顺时针旋转90°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2);
            mainComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [layerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 180){
            // 顺时针旋转180°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI);
            mainComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
            [layerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 270){
            // 顺时针旋转270°
            translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2*3.0);
            mainComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [layerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        }
    }
    // 4. 导出
    CMTime start = CMTimeMakeWithSeconds(self.lastStartSeconds, totalDuration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(self.lastEndSeconds - self.lastStartSeconds, totalDuration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    
    if (!isClip) {
        /*添加水印*/
        [self addWaterMark:mainComposition.renderSize withBlock:^(CALayer *parent, CALayer *videoLayer) {
            mainComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parent];
        }];
    }
    
    // 导出视频
    NSString *newVideoPath = [self pathForVideo:@"video"];
    AVAssetExportSession *exportSesstion = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exportSesstion.videoComposition = mainComposition;
    exportSesstion.outputURL = [NSURL fileURLWithPath:newVideoPath];
    exportSesstion.shouldOptimizeForNetworkUse = YES;
    exportSesstion.outputFileType = AVFileTypeMPEG4;
    exportSesstion.timeRange = range;
    
    [exportSesstion exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        AVAssetExportSessionStatus status = exportSesstion.status;
        if (isClip) {
            if (status == AVAssetExportSessionStatusCompleted) {
//                DDLog(@"裁剪成功");
                self.path = newVideoPath;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self cancelClipAction];
                });
            }
            else {
//                DDLog(@"裁剪失败");
                NSString *string = [NSString stringWithFormat:@"裁剪失败%@", exportSesstion.error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud = [MBProgressHUD showFinishHudOn:self.view withResult:NO labelText:string delayHide:YES completion:nil];
                });
            }
        }
        else {
            if (status == AVAssetExportSessionStatusCompleted) {
//                DDLog(@"导出成功");
                if (self.completeBlock) {
                    self.completeBlock([NSURL fileURLWithPath:newVideoPath]);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:NO completion:nil];
                });
            }
            else{
                NSString *string = [NSString stringWithFormat:@"导出失败%@", exportSesstion.error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud = [MBProgressHUD showFinishHudOn:self.view withResult:NO labelText:string delayHide:YES completion:nil];
                });
            }
        }
    }];
}

// 获取视频角度
- (int)degressFromVideoFileWithAsset:(AVAsset *)asset {
    int degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        } else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}

- (void)addWaterMark:(CGSize)size withBlock:(void (^)(CALayer *parent,CALayer *videoLayer)) returnBlock{
    CALayer *drawLayer = [CALayer layer];
    drawLayer.contents = (id)self.drawingView.image.CGImage;
    drawLayer.frame = CGRectMake(0, 0, size.width, size.height);
    drawLayer.opacity = 1.0;
    
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    // 添加视频
    [parentLayer addSublayer:videoLayer];
    // 添加涂鸦
    [parentLayer addSublayer:drawLayer];
    // 添加文字
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
            
            CGFloat selfRw = self.drawingView.width / size.width;
            CGFloat selfRh = self.drawingView.height / size.height;
            
            CGFloat ox = textLabel.frame.origin.x / selfRw;
            CGFloat oy = textLabel.frame.origin.y / selfRw;
            CGFloat sw = textImg.size.width / selfRw;
            CGFloat sh = textImg.size.height / selfRh;
            
            CATextLayer *textLayer = [[CATextLayer alloc] init];
            textLayer.foregroundColor = textLabel.archerBGView.textColor.CGColor;
            textLayer.string = textLabel.text;
            // 设置字号
            CFStringRef fontName = (__bridge CFStringRef)textLabel.archerBGView.textFont.fontName;
            CGFontRef fontRef = CGFontCreateWithFontName(fontName);
            textLayer.font = fontRef;
            textLayer.fontSize = textLabel.archerBGView.textFont.pointSize / selfRw;
            CGFontRelease(fontRef);
            // 渲染分辨率，否则显示模糊
            textLayer.contentsScale = [UIScreen mainScreen].scale;
            textLayer.frame = CGRectMake(ox, oy, sw, sh);
            textLayer.alignmentMode = kCAAlignmentCenter;

            [parentLayer addSublayer:textLayer];
        }
    }

    returnBlock(parentLayer, videoLayer);
}

- (NSString *)pathForVideo:(NSString *)videoName{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddHHMMss"];
    NSString *now = [formatter stringFromDate:[NSDate date]];
    
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.mp4", videoName, now]];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    // 判断文件夹是否存在 不存在创建
    BOOL exits = [manager fileExistsAtPath:tempPath isDirectory:nil];
    if (!exits) {
        // 创建文件夹
        [manager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 判断文件是否存在
    if ([manager fileExistsAtPath:tempPath isDirectory:nil]) {
        // 存在 删除之前的视频
        [manager removeItemAtPath:tempPath error:nil];
    }
    
//    DDLog(@"编辑视频路径：%@\n",tempPath);
    return tempPath;
}

- (void)setCurrentTool:(WBGImageToolBase *)currentTool {
    if(_currentTool != currentTool) {
        [_currentTool cleanup];
        _currentTool = currentTool;
        [_currentTool setup];
        
    }
    
    switch (_currentMode) {
        case VideoEditorModeDraw : {
            if (self.drawTool.allLineMutableArray.count > 0) {
                self.undoButton.hidden  = NO;
            }
        }
            break;
        case VideoEditorModeText:
        case VideoEditorModeClip:
        case VideoEditorModeNone: {
            self.undoButton.hidden  = YES;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Actions
// 发送
- (void)sendAction {
    [self videoCutIsClip:NO];
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

        default:
            break;
    }
}

// 涂鸦模式
- (void)panAction {
    if (_currentMode == VideoEditorModeDraw) {
        return;
    }
    
    //先设置状态，然后在干别的
    self.currentMode = VideoEditorModeDraw;
    
    self.currentTool = self.drawTool;
    [self hiddenColorPan:NO animation:YES];
    self.clipBottomView.hidden = YES;
}

// 文字模式
- (void)textAction {
    if (_currentMode == VideoEditorModeText) {
        return;
    }
    
    //先设置状态，然后在干别的
    self.currentMode = VideoEditorModeText;
    
    self.currentTool = self.textTool;
    [self hiddenColorPan:YES animation:YES];
    self.clipBottomView.hidden = YES;
}

// 裁剪模式
- (void)clipAction {
    CGRect rect = self.videoPlayView.playerLayer.frame;
    CGFloat scale = rect.size.height / rect.size.width;
    rect.origin.x = 35;
    rect.size.width = SCREENWIDTH-35*2;
    rect.size.height = rect.size.width * scale;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.videoPlayView.playerLayer.frame = rect;
        self.drawingView.frame = rect;
    }];
    
    self.videoPieces.hidden = NO;
    self.clipBottomView.hidden = NO;
    [self hiddenTopAndBottomBar:YES animation:YES];
}

- (void)closeView {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)undoAction {
    if (self.currentMode == VideoEditorModeDraw) {
        WBGDrawTool *tool = (WBGDrawTool *)self.currentTool;
        [tool backToLastDraw];
    }
}

- (void)cancelClipAction {
    CGFloat topMargin = [UIScreen resolution] > UIDeviceResolution_iPhoneRetina6p ? 44 : 0;
    CGRect rect = CGRectMake(0, topMargin, SCREENWIDTH, SCREENHEIGHT-KBottomSafeHeight-topMargin);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.videoPlayView.playerLayer.frame = rect;
        self.drawingView.frame = rect;
    }];
    
    self.videoPieces.hidden = YES;
    self.clipBottomView.hidden = YES;
    [self hiddenTopAndBottomBar:NO animation:YES];
}

- (void)confirmClipAction {
    [self videoCutIsClip:YES];
}

- (void)editTextAgain {
    //WBGTextTool 钩子调用
    
    if (_currentMode == VideoEditorModeText) {
        return;
    }
    //先设置状态，然后在干别的
    self.currentMode = VideoEditorModeText;
    
    if(_currentTool != self.textTool) {
        [_currentTool cleanup];
        _currentTool = self.textTool;
        [_currentTool setup];
        
    }
    
    [self hiddenColorPan:YES animation:YES];
}

- (void)resetCurrentTool {
    self.currentMode = VideoEditorModeNone;
}

- (NSArray *)getVideoThumbnail:(NSString *)path count:(NSInteger)count splitCompleteBlock:(void(^)(BOOL success, NSMutableArray *splitimgs))splitCompleteBlock {
    AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:path]];
    NSMutableArray *arrayImages = [NSMutableArray array];
    [asset loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        //        generator.maximumSize = CGSizeMake(480,136);//如果是CGSizeMake(480,136)，则获取到的图片是{240, 136}。与实际大小成比例
        generator.appliesPreferredTrackTransform = YES;//这个属性保证我们获取的图片的方向是正确的。比如有的视频需要旋转手机方向才是视频的正确方向。
        /**因为有误差，所以需要设置以下两个属性。如果不设置误差有点大，设置了之后相差非常非常的小**/
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        Float64 seconds = CMTimeGetSeconds(asset.duration);
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i<count; i++) {
            CMTime time = CMTimeMakeWithSeconds(i*(seconds/10.0),1);//想要获取图片的时间位置
            [array addObject:[NSValue valueWithCMTime:time]];
        }
        __block int i = 0;
        [generator generateCGImagesAsynchronouslyForTimes:array completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
            
            i++;
            if (result==AVAssetImageGeneratorSucceeded) {
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                [arrayImages addObject:image];
            }
            else{
                NSLog(@"获取图片失败！！！");
            }
            
            if (i == count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    splitCompleteBlock(YES, arrayImages);
                });
            }
        }];
    }];
    
    return arrayImages;
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
