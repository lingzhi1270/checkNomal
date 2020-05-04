//
//  ModCameraStyle1ViewController.m
//  Conversation
//
//  Created by qlon 2019/4/24.
//

#import "ModCameraStyle1ViewController.h"
#import "CameraButtonView.h"
#import <AVKit/AVKit.h>
#import <CoreMotion/CoreMotion.h>
#import <LibComponentBase/PreviewModel.h>
#import "VideoPlayView.h"
//#import "MessageModel.h"
#import "UIImage+JSPP.h"
#import "VideoEditViewController.h"
#import "ImageEditViewController.h"

@interface cameraFocusView : UIView

@end

@implementation cameraFocusView

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 画方框
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, 0, rect.size.height);
    CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height);
    CGContextAddLineToPoint(ctx, rect.size.width, 0);
    CGContextAddLineToPoint(ctx, 0, 0);
    [MAIN_COLOR setStroke];
    CGContextSetLineWidth(ctx, 2.0);
    CGContextStrokePath(ctx);

    // 画4个短线
    for (int i = 0; i < 4; i++) {
        switch (i) {
            case 0:
                CGContextMoveToPoint(ctx, rect.size.width/2, 0);
                CGContextAddLineToPoint(ctx, rect.size.width/2, 8);

                break;
                
            case 1:
                CGContextMoveToPoint(ctx, rect.size.width, rect.size.height/2);
                CGContextAddLineToPoint(ctx, rect.size.width-8, rect.size.height/2);
                break;
                
            case 2:
                CGContextMoveToPoint(ctx, rect.size.width/2, rect.size.height);
                CGContextAddLineToPoint(ctx, rect.size.width/2, rect.size.height-8);
    
                break;
                
            case 3:
                CGContextMoveToPoint(ctx, 0, rect.size.height/2);
                CGContextAddLineToPoint(ctx, 8, rect.size.height/2);
            
                break;
                
            default:
                break;
        }
        
        CGContextSetLineWidth(ctx, 1.0);
    }
    
    CGContextStrokePath(ctx);
}

@end

@interface ModCameraStyle1ViewController () <CameraButtonViewDelegate, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate, CAAnimationDelegate, ImageEditDelegate>
@property (nonatomic, strong) CameraButtonView              *cameraView;
@property (nonatomic, strong) CMMotionManager               *motionManager;     // 陀螺仪管理
@property (nonatomic, strong) AVCaptureSession              *captureSession;    // 捕获会话
@property (nonatomic, strong) AVCaptureDeviceInput          *backCameraInput;   // 后置摄像头输入
@property (nonatomic, strong) AVCaptureDeviceInput          *frontCameraInput;  // 前置摄像头输入
@property (nonatomic, strong) AVCaptureVideoPreviewLayer    *previewLayer;      // 默认预览界面
@property (nonatomic, strong) AVCaptureDevice               *device;
@property (nonatomic, assign) AVCaptureVideoOrientation     orientation;        // 当前设备方向

@property (nonatomic, strong) UILabel                       *tipsLabel;
@property (nonatomic, strong) cameraFocusView               *focusView;         // 聚焦方框
@property (nonatomic, strong) UIButton                      *cameraButton;      // 前置后置切换
// 视频相关
@property (nonatomic, strong) AVCaptureDeviceInput          *audioInput;        // 音频输入
@property (nonatomic, strong) AVCaptureMovieFileOutput      *videoOutput;       // 视频输出
@property (nonatomic, strong) NSURL                         *saveVideoUrl;      // 保存视频路径
@property (nonatomic, strong) VideoPlayView                 *videoPlayView;     // 拍摄视频预览
// 照片相关
@property (nonatomic, strong) AVCapturePhotoOutput          *photoOutput;       // 照片输出
@property (nonatomic, strong) UIImageView                   *previewImageView;  // 拍摄照片预览
// 缩放比例
@property (nonatomic, assign) CGFloat                       scaleNum;
// 当前是拍照还是摄像
@property (nonatomic, assign) BOOL                          isTakePhoto;
// 判断聚焦方框是否结束
@property (nonatomic, assign) BOOL                          isAnimateStop;
@property (nonatomic, strong) AVAsset *asset;


@end

@implementation ModCameraStyle1ViewController

- (void)dealloc {
    // 删除缓存的视频文件
    if (self.saveVideoUrl) {
        [[NSFileManager defaultManager] removeItemAtURL:self.saveVideoUrl error:nil];
    }
    
//    DDLog(@"拍照界面释放");
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        
        if (self.isFrontCamera) {
            // 前置摄像头设置镜像
            if ([_captureSession canAddInput:self.frontCameraInput]) {
                [_captureSession addInput:self.frontCameraInput];
            }
            
            if (self.device.position == AVCaptureDevicePositionUnspecified ||
                self.device.position == AVCaptureDevicePositionFront) {
                AVCaptureConnection *connection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
                // 前置摄像头设置镜像
                if (self.device.position == AVCaptureDevicePositionUnspecified ||
                    self.device.position == AVCaptureDevicePositionFront) {
                    connection.videoMirrored = YES;
                }
            }
        }
        else {
            if ([_captureSession canAddInput:self.backCameraInput]) {
                [_captureSession addInput:self.backCameraInput];
            }
        }
        
        // 添加图片输出
        if ([_captureSession canAddOutput:self.photoOutput]) {
            [_captureSession addOutput:self.photoOutput];
        }
        // 添加音频输入
        if ([_captureSession canAddInput:self.audioInput]) {
            [_captureSession addInput:self.audioInput];
        }
        // 添加视频输出
        if ([_captureSession canAddOutput:self.videoOutput]) {
            // 设置视频防抖
            AVCaptureConnection *connection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported]) {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
            }
            [_captureSession addOutput:self.videoOutput];
        }

        // 使用高质量的视频和音频输出
        [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    }
    
    return _captureSession;
}

- (AVCapturePhotoOutput *)photoOutput {
    if (!_photoOutput) {
        _photoOutput = [[AVCapturePhotoOutput alloc] init];
    }
    
    return _photoOutput;
}

- (AVCaptureMovieFileOutput *)videoOutput {
    if (!_videoOutput) {
        _videoOutput = [[AVCaptureMovieFileOutput alloc] init];
    }
    
    return _videoOutput;
}

- (AVCaptureDeviceInput *)audioInput {
    if (!_audioInput) {
        NSError *error = nil;
        AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInMicrophone mediaType:AVMediaTypeAudio position:AVCaptureDevicePositionUnspecified];
        _audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
    }
    
    return _audioInput;
}

- (AVCaptureInput *)backCameraInput {
    if (!_backCameraInput) {
        NSError *error = nil;
        self.device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        _backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
    }
    
    return _backCameraInput;
}

- (AVCaptureInput *)frontCameraInput {
    if (!_frontCameraInput) {
        NSError *error = nil;
        self.device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
    }
    
    return _frontCameraInput;
}

- (CMMotionManager *)motionManager {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1/15.0;
    }
    
    return _motionManager;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocus:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGesture];
    
    UIPinchGestureRecognizer *zoomGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomGesture:)];
    [self.view addGestureRecognizer:zoomGesture];
    [tapGesture requireGestureRecognizerToFail:zoomGesture];
    
    self.focusView = [[cameraFocusView alloc] init];
    self.focusView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.focusView];
    
    self.previewImageView = [[UIImageView alloc] init];
    self.previewImageView.backgroundColor = [UIColor blackColor];
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.previewImageView];
    self.previewImageView.hidden = YES;
    
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cameraButton setImage:[UIImage imageNamed:@"ic_camera_change" bundleName:@"ModCameraStyle1"] forState:UIControlStateNormal];
    [self.cameraButton addTarget:self action:@selector(changeCameraInputDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cameraButton];
    
    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.text = @"轻触拍照，按住摄像";
    self.tipsLabel.textColor = [UIColor whiteColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:14];
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    [self.tipsLabel sizeToFit];
    [self.view addSubview:self.tipsLabel];

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *hudView = [[UIVisualEffectView alloc] initWithEffect:blur];
    hudView.alpha = 0.3f;
    hudView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tipsLabel.frame)+10, CGRectGetHeight(self.tipsLabel.frame)+5);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:hudView.frame
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = hudView.frame;
    maskLayer.path = maskPath.CGPath;
    hudView.layer.mask = maskLayer;
    [self.tipsLabel addSubview:hudView];

    self.cameraView = [[CameraButtonView alloc] init];
    self.cameraView.delegate = self;
    [self.view addSubview:self.cameraView];
    
    if ([UIScreen resolution] > UIDeviceResolution_iPhoneRetina6p) {
        UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, KTopViewHeight)];
        statusView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:statusView];
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT-KBottomSafeHeight-kTabbarHeight, SCREENWIDTH, KBottomSafeHeight+kTabbarHeight)];
        bottomView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:bottomView];
        
        [self.previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(KTopViewHeight);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-KBottomSafeHeight-kTabbarHeight);
        }];
        
        [self.cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(KTopViewHeight);
            make.right.equalTo(self.safeArea);
            make.size.equalTo(@(CGSizeMake(50, 50)));
        }];
        
        [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(30);
            make.right.equalTo(self.view).offset(-30);
            make.bottom.equalTo(self.safeArea).offset(-(50+KBottomSafeHeight+kTabbarHeight));
            make.height.equalTo(@75.f);
        }];
    }
    else {
        [self.previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        [self.cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.right.equalTo(self.safeArea);
            make.size.equalTo(@(CGSizeMake(50, 50)));
        }];
        
        [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(30);
            make.right.equalTo(self.view).offset(-30);
            make.bottom.equalTo(self.safeArea).offset(-50);
            make.height.equalTo(@75.f);
        }];
    }
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.cameraView.mas_top).offset(-10);
        make.width.equalTo(@(CGRectGetWidth(self.tipsLabel.frame)+10));
        make.height.equalTo(@(CGRectGetHeight(self.tipsLabel.frame)+5));
    }];
    
    [self.focusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.equalTo(@(CGSizeMake(70, 70)));
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isTakePhoto = YES;
    self.isEdit = NO;
    self.scaleNum = 1.0;
    
    WEAK(self, weakSelf);
    [NSTimer scheduledTimerWithTimeInterval:3.0
                                      block:^(NSTimer * _Nonnull timer) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [UIView animateWithDuration:0.3 animations:^{
                                                  weakSelf.tipsLabel.alpha = 0.0;
                                              } completion:^(BOOL finished) {
                                                  [weakSelf.tipsLabel removeFromSuperview];
                                              }];
                                          });
                                          [timer invalidate];
                                          timer = nil;
                                      }
                                    repeats:3.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!self.previewLayer) {
        self.topView.hidden = YES;

        // 初始化界面
        self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        [self.view.layer insertSublayer:self.previewLayer atIndex:0];
        
        if ([UIScreen resolution] > UIDeviceResolution_iPhoneRetina6p) {
            self.previewLayer.frame = CGRectMake(0, KTopViewHeight, SCREENWIDTH, SCREENHEIGHT-KTopViewHeight-KBottomSafeHeight-kTabbarHeight);
        }
        else {
            self.previewLayer.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
        }
    }
    
    // 使用陀螺仪判断当前设备方向
    WEAK(self, weakSelf);
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *motion, NSError *error){
        double x = motion.gravity.x;
        double y = motion.gravity.y;
        
        if (fabs(y) >= fabs(x)) {
            if (y >= 0) {
                weakSelf.orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            }
            else {
                weakSelf.orientation = AVCaptureVideoOrientationPortrait;
            }
        }
        else {
            if (x >= 0) {
                weakSelf.orientation = AVCaptureVideoOrientationLandscapeLeft;
            }
            else {
                weakSelf.orientation = AVCaptureVideoOrientationLandscapeRight;
            }
        }
    }];
    
    if (!self.isEdit) {
        [self.captureSession startRunning];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    WEAK(self, weakSelf);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakSelf.captureSession stopRunning];
    });
    
    self.previewLayer = nil;
    // 释放陀螺仪
    [self.motionManager stopDeviceMotionUpdates];
    self.motionManager = nil;
}

#pragma mark - 对焦、缩放镜头
- (void)zoomGesture:(UIPinchGestureRecognizer *)zoomTap {
    switch (zoomTap.state) {
        case UIGestureRecognizerStateBegan:
            
            break;
            
        case UIGestureRecognizerStateChanged: {
            self.scaleNum = zoomTap.scale;
            AVCaptureConnection *captureConnection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];

            if (self.scaleNum < 1.0) {
                self.scaleNum = 1.0;
            }
            
            if (self.scaleNum > captureConnection.videoMaxScaleAndCropFactor) {
                self.scaleNum = captureConnection.videoMaxScaleAndCropFactor;
            }
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.3];
            [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.scaleNum, self.scaleNum)];
            [CATransaction commit];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
            
            break;
            
        default:
            break;
    }
    
}

- (void)tapToFocus:(UIGestureRecognizer *)rec {
    // 聚焦方框动画结束前 不允许修改聚焦点
    if (!self.isAnimateStop) {
        return;
    }
    
    CGPoint point = [rec locationInView:self.view];
    AVCaptureFocusMode focueMode = AVCaptureFocusModeAutoFocus;
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeAutoExpose;
    
    BOOL canResetFocus = [self.device isFocusModeSupported:focueMode] && [self.device isFocusPointOfInterestSupported];
    BOOL canResetExposure = [self.device isExposureModeSupported:exposureMode] && [self.device isExposurePointOfInterestSupported];
    NSError *error = nil;
    
    if ([self.device lockForConfiguration:&error]) {
        if (canResetFocus) {
            self.device.focusMode = focueMode;
            self.device.focusPointOfInterest = point;
        }
        if (canResetExposure && [self.device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            self.device.exposureMode = exposureMode;
            self.device.exposurePointOfInterest = point;
        }
        
        [self.device unlockForConfiguration];
    }
    
    [self focusViewAnimateWithPoint:point];
}

- (void)focusViewAnimateWithPoint:(CGPoint)point {
    self.focusView.hidden = NO;
    self.focusView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    self.isAnimateStop = NO;
    
    WEAK(self, weakSelf);
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.focusView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
        animation.delegate = self;
        animation.fromValue = [NSNumber numberWithFloat:1.0f];
        animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度。
        animation.autoreverses = YES;
        animation.duration = 0.08;
        animation.repeatCount = 3;
        [weakSelf.focusView.layer addAnimation:animation forKey:@"opacity"];
    }];
    
    self.focusView.center = point;
}

- (void)changeCameraInputDevice {
    self.isFrontCamera = !self.isFrontCamera;
    
    WEAK(self, weakSelf);
    if (self.isFrontCamera) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [weakSelf.captureSession stopRunning];
            [weakSelf.captureSession removeInput:weakSelf.backCameraInput];
            if ([weakSelf.captureSession canAddInput:weakSelf.frontCameraInput]) {
                [weakSelf.captureSession addInput:weakSelf.frontCameraInput];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CATransition *animation = [CATransition animation];
                animation.type = @"oglFlip";
                animation.subtype = kCATransitionFromRight;
                animation.duration = 0.3;
                [weakSelf.previewLayer addAnimation:animation forKey:@"flip"];
            });
            
            [weakSelf.captureSession startRunning];
            
            AVCaptureConnection *connection = [weakSelf.videoOutput connectionWithMediaType:AVMediaTypeVideo];
            // 前置摄像头设置镜像
            if (weakSelf.device.position == AVCaptureDevicePositionUnspecified || weakSelf.device.position == AVCaptureDevicePositionFront) {
                connection.videoMirrored = YES;
            }
        });
    }
    else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [weakSelf.captureSession stopRunning];
            [weakSelf.captureSession removeInput:weakSelf.frontCameraInput];
            if ([weakSelf.captureSession canAddInput:weakSelf.backCameraInput]) {
                [weakSelf.captureSession addInput:weakSelf.backCameraInput];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CATransition *animation = [CATransition animation];
                animation.type = @"oglFlip";
                animation.subtype = kCATransitionFromLeft;
                animation.duration = 0.3;
                [weakSelf.previewLayer addAnimation:animation forKey:@"flip"];
            });
            
            [weakSelf.captureSession startRunning];
        });
    }
}

#pragma mark - CameraButtonViewDelegate
- (void)dismiss {
    self.isEdit = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)removeData {
    self.isEdit = NO;
    self.cameraButton.hidden = NO;
    self.previewImageView.hidden = YES;
    self.previewImageView.image = nil;
    
    if (self.saveVideoUrl) {
        [[NSFileManager defaultManager] removeItemAtURL:self.saveVideoUrl error:nil];
        self.saveVideoUrl = nil;
        [self.videoPlayView removeFromSuperview];
        self.videoPlayView = nil;
        self.asset = nil;
    }
    
    [self.captureSession startRunning];
}

- (void)sendData {
    self.isEdit = NO;

    if (self.block) {
        WEAK(self, weakSelf);
        // 发送视频
        if (self.saveVideoUrl) {
            NSData *data = [NSData dataWithContentsOfURL:self.saveVideoUrl];
            
//            [MessageModel thumbnailImageForVideo:self.saveVideoUrl atTime:0 block:^(UIImage *thumbImage) {
//                weakSelf.block(data, thumbImage, nil, nil);
//            }];
        }
        // 发送图片
        else {
            self.block(nil, nil, UIImageJPEGRepresentation(self.previewImageView.image, 0.7), self.previewImageView.image);
        }
    }
    
    [self dismiss];
}

- (void)takePhoto {
    self.isEdit = YES;

    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecJPEG}];
    // 设置光学防抖动
    settings.autoStillImageStabilizationEnabled = YES;
    // 设置闪光灯状态
    settings.flashMode = AVCaptureFlashModeOff;
    
    // 设置是否支持双摄(iOS 10.2以上支持)
    if (@available(iOS 10.2, *)) {
        settings.autoDualCameraFusionEnabled = YES;
    }
    // 根据缩放比例设置图片的缩放比
    AVCaptureConnection *captureConnection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
    [captureConnection setVideoScaleAndCropFactor:self.scaleNum];
    // 拍照, 数据从delegate回调中获取
    [self.photoOutput capturePhotoWithSettings:settings delegate:self];
}

- (void)startTakeVideo {
    //根据连接取得设备输出的数据
    if (![self.videoOutput isRecording]) {
        self.isEdit = YES;

        // 删除原有视频
        if (self.saveVideoUrl) {
            [[NSFileManager defaultManager] removeItemAtURL:self.saveVideoUrl error:nil];
        }
        // 根据设备输出获得连接
        AVCaptureConnection *captureConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
        // 预览图层和拍摄时的设备方向保持一致
        if ([captureConnection isVideoOrientationSupported]) {
            captureConnection.videoOrientation = self.orientation;
        }

        NSURL *fileUrl = [NSURL fileURLWithPath:[self getVideoMergeFilePathString]];
//        DDLog(@"fileUrl:%@",fileUrl);
        [self.videoOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
    }
    else {
        [self.videoOutput stopRecording];
    }
}

- (void)stopTakeVideo {
    if (![self.videoOutput isRecording]) {
        return;
    }
    else {
        [self.videoOutput stopRecording];
    }
}

- (void)editAction {
    if (!self.saveVideoUrl) {
        ImageEditViewController *editVC = [[ImageEditViewController alloc] initWithImage:[self.previewImageView.image fixOrientation] delegate:self];
        [self presentViewController:editVC animated:NO completion:nil];
    }
    else {
        WEAK(self, weakSelf);
        VideoEditViewController *videoVC = [[VideoEditViewController alloc] initWithPath:self.saveVideoUrl.absoluteString asset:self.asset];
        videoVC.completeBlock = ^(NSURL *fileUrl) {
            [[NSFileManager defaultManager] removeItemAtURL:self.saveVideoUrl error:nil];
            weakSelf.saveVideoUrl = fileUrl;
            weakSelf.asset = [AVAsset assetWithURL:fileUrl];
            [weakSelf.asset tracksWithMediaType:AVMediaTypeVideo];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.videoPlayView removeFromSuperview];
                weakSelf.videoPlayView = nil;
                
                PreviewModel *model = [[PreviewModel alloc] initWithUrl:fileUrl.absoluteString image:nil tapView:nil thumbnailImage:nil type:PreviewTypeVideo];
                
                if (!self.videoPlayView) {
                    self.videoPlayView = [[VideoPlayView alloc] initWithFrame:self.previewLayer.bounds model:model type:VideoTypePreview];
                    self.videoPlayView.thumbnailImageView.frame = self.previewLayer.bounds;
                    self.videoPlayView.backgroundColor = [UIColor blackColor];
                    [self.view insertSubview:self.videoPlayView belowSubview:self.cameraView];
                }
            });
        };
        [self presentViewController:videoVC animated:NO completion:nil];
    }
}

#pragma mark - ImageEditDelegate
- (void)imageEditor:(ImageEditViewController *)editor didFinishEdittingWithImage:(UIImage *)image {
    self.previewImageView.image = image;
    [editor dismissViewControllerAnimated:NO completion:nil];
    

}

- (void)imageEditorDidCancel:(ImageEditViewController *)editor {

}

#pragma mark - AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)output
didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer
previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer
     resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
      bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings
                error:(nullable NSError *)error {
    
    self.cameraButton.hidden = YES;
    [self.captureSession stopRunning];
    
    NSData *imageData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    UIImage *originImage = [UIImage imageWithData:imageData];
    UIImage *fixImage = [self fixOrientation:originImage orientation:self.orientation];
//    UIImage *fixImage = [originImage fixOrientation];

    self.previewImageView.hidden = NO;
    self.previewImageView.image = fixImage;
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
//    DDLog(@"开始录制...");
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
//    DDLog(@"视频录制完成.");
    
    [self.captureSession stopRunning];
    
    self.saveVideoUrl = outputFileURL;
    self.asset = [AVAsset assetWithURL:outputFileURL];
    [self.asset tracksWithMediaType:AVMediaTypeVideo];
    
    PreviewModel *model = [[PreviewModel alloc] initWithUrl:outputFileURL.absoluteString image:nil tapView:nil thumbnailImage:nil type:PreviewTypeVideo];
    if (!self.videoPlayView) {
        self.videoPlayView = [[VideoPlayView alloc] initWithFrame:self.previewLayer.bounds model:model type:VideoTypePreview];
        self.videoPlayView.thumbnailImageView.frame = self.previewLayer.bounds;
        self.videoPlayView.backgroundColor = [UIColor blackColor];
        [self.view insertSubview:self.videoPlayView belowSubview:self.cameraView];
    }
    else {
        [self.videoPlayView play];
    }
}

- (NSString *)getVideoMergeFilePathString {
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingString:@"Video"];

    NSFileManager *manager = [NSFileManager defaultManager];

    // 判断文件夹是否存在 不存在创建
    BOOL exits = [manager fileExistsAtPath:tempPath isDirectory:nil];
    if (!exits) {
        // 创建文件夹
        [manager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    // 创建视频存放路径
    tempPath = [tempPath stringByAppendingPathComponent:@"myMovie.mov"];

    // 判断文件是否存在
    if ([manager fileExistsAtPath:tempPath isDirectory:nil]) {
        // 存在 删除之前的视频
        [manager removeItemAtPath:tempPath error:nil];
    }
    
    return tempPath;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.focusView.hidden = YES;
    self.isAnimateStop = YES;
}

- (UIImage *)fixOrientation:(UIImage *)image orientation:(AVCaptureVideoOrientation)orientation{
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));

    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (orientation) {
        case AVCaptureVideoOrientationLandscapeLeft:
            ctx = CGBitmapContextCreate(NULL, image.size.height, image.size.width,
                                        CGImageGetBitsPerComponent(image.CGImage), 0,
                                        CGImageGetColorSpace(image.CGImage),
                                        CGImageGetBitmapInfo(image.CGImage));
            if (self.isFrontCamera) {
                
            
            }
            else {
                transform = CGAffineTransformTranslate(transform, image.size.height, image.size.width);
                transform = CGAffineTransformRotate(transform, M_PI);
            }

            break;

        case AVCaptureVideoOrientationLandscapeRight:
            if (self.isFrontCamera) {
                ctx = CGBitmapContextCreate(NULL, image.size.height, image.size.width,
                                            CGImageGetBitsPerComponent(image.CGImage), 0,
                                            CGImageGetColorSpace(image.CGImage),
                                            CGImageGetBitmapInfo(image.CGImage));
                transform = CGAffineTransformTranslate(transform, image.size.height, image.size.width);
                transform = CGAffineTransformRotate(transform, M_PI);
            }
            else {
                ctx = CGBitmapContextCreate(NULL, image.size.height, image.size.width,
                                            CGImageGetBitsPerComponent(image.CGImage), 0,
                                            CGImageGetColorSpace(image.CGImage),
                                            CGImageGetBitmapInfo(image.CGImage));

            }
            break;

        case AVCaptureVideoOrientationPortraitUpsideDown:
            if (self.isFrontCamera) {

            }
            else {
                transform = CGAffineTransformTranslate(transform, image.size.width, 0);
                transform = CGAffineTransformRotate(transform, M_PI_2);
            }

            break;

        default:
            if (self.isFrontCamera) {

            }
            else {
                return image;
            }

            break;
    }
    
    switch (orientation) {
        case AVCaptureVideoOrientationPortraitUpsideDown:
            if (self.isFrontCamera) {
                transform = CGAffineTransformTranslate(transform, image.size.width, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
                
                transform = CGAffineTransformTranslate(transform, image.size.width, 0);
                transform = CGAffineTransformRotate(transform, M_PI_2);
            }
            
            break;
        case AVCaptureVideoOrientationPortrait:
            if (self.isFrontCamera) {
                transform = CGAffineTransformTranslate(transform, image.size.width, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
                
                transform = CGAffineTransformTranslate(transform, 0, image.size.height);
                transform = CGAffineTransformRotate(transform, -M_PI_2);
            }

            break;
        case AVCaptureVideoOrientationLandscapeRight:
        case AVCaptureVideoOrientationLandscapeLeft:
            if (self.isFrontCamera) {
                transform = CGAffineTransformTranslate(transform, image.size.height, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
            }
            break;

    }

    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.height, image.size.width), image.CGImage);
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);

    return img;
}

@end
