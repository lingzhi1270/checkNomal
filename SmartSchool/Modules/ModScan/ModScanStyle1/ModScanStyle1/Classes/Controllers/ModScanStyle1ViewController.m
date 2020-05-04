//
//  ModScanStyle1ViewController.m
//  Unilife
//
//  Created by 唐琦 on 2019/7/5.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ModScanStyle1ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <TZImagePickerController/TZImagePickerController.h>
#import "JSQSystemSoundPlayer.h"

@interface ModScanStyle1ViewController () < AVCaptureMetadataOutputObjectsDelegate >
@property (nonatomic, assign) CGFloat                       scanHeight;
@property (nonatomic, strong) UIView                        *downView;
@property (nonatomic, assign) BOOL                          isOpenCamera;   // 是否打开摄像头
@property (nonatomic, assign) CGFloat                       lineY;
@property (nonatomic, assign) BOOL                          flag;           // 闪关灯标志
@property (nonatomic, strong) UIView                        *readerView;    // 扫描视图
@property (nonatomic, strong) UIImageView                   *lineView;      // 扫描线条
@property (nonatomic, strong) UILabel                       *tipLabel;      // 提示信息

@property (nonatomic, strong) AVCaptureSession                *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer      *videoPreviewLayer;

@end

@implementation ModScanStyle1ViewController

- (AVCaptureSession *)captureSession {
    if(_captureSession == nil) {
        NSError * error;
        
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (!input) {
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
            }
            return nil;
        }
        
        // 创建会话
        _captureSession = [[AVCaptureSession alloc] init];
        // 添加输入流
        [_captureSession addInput:input];
        // 初始化输出流
        AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        // 添加输出流
        [_captureSession addOutput:captureMetadataOutput];
        // 创建dispatch queue.
        dispatch_queue_t dispatchQueue;
        dispatchQueue = dispatch_queue_create("scanQRQueue", NULL);
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
        // 设置元数据类型 AVMetadataObjectTypeQRCode
        [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    }
    
    return _captureSession;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [rightButton setTitle:@"相册" forState:UIControlStateNormal];
    [rightButton setTitleColor:MAIN_NAVI_TITLE_COLOR forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(scanFromLibrary) forControlEvents:UIControlEventTouchUpInside];
    [self addRightButton:rightButton];
    
    self.scanHeight = SCREENWIDTH-124;
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame:CGRectMake(0, KTopViewHeight, SCREENWIDTH, SCREENHEIGHT-KTopViewHeight)];
    [self.view.layer addSublayer:self.videoPreviewLayer];
    
    //内容视图
    self.readerView =[[UIView alloc] init];
    self.readerView.frame  =CGRectMake(0, KTopViewHeight, SCREENWIDTH, SCREENHEIGHT);
    self.readerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.readerView];
    
    UIImage *bgImage = [[UIImage imageNamed:@"img_sysbox" bundleName:@"ModScanStyle1"] resizableImageWithCapInsets:UIEdgeInsetsMake(100, 100, 100 , 100)];

    UIImageView * scanImageView = [[UIImageView alloc] init];
    scanImageView.frame =CGRectMake(62, 140, SCREENWIDTH-124, self.scanHeight);
    scanImageView.image = bgImage;
    [self.readerView addSubview:scanImageView];
    self.lineY = scanImageView.frame.origin.y+10;
    
    //顶部视图
    float upViewHeight = 140;

    UIView * upView = [[UIView alloc]init];
    upView.frame = CGRectMake(0,0,SCREENWIDTH, upViewHeight);
    upView.alpha = 0.4;
    upView.backgroundColor = [UIColor colorWithRGBA:0x000000BB];
    [self.readerView addSubview:upView];
    
    //左边视图
    UIView * leftView = [[UIView alloc] initWithFrame:CGRectMake(0, upView.frame.size.height, 62, SCREENHEIGHT-upView.frame.size.height)];
    leftView.alpha = 0.4;
    leftView.backgroundColor = [UIColor colorWithRGBA:0x000000BB];
    [self.readerView  addSubview:leftView];
    
    //右边视图
    UIView * rightView = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH-62, upView.frame.size.height,62,SCREENHEIGHT-upView.frame.size.height)];
    rightView.alpha = 0.4;
    rightView.backgroundColor = [UIColor colorWithRGBA:0x000000BB];
    [self.readerView addSubview:rightView];
    
    // 底部视图
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(62,upView.frame.size.height+self.scanHeight,SCREENWIDTH-124, SCREENHEIGHT-upView.frame.size.height-self.scanHeight)];
    downView.alpha = 0.4;
    downView.backgroundColor = [UIColor colorWithRGBA:0x000000BB];
    [self.readerView addSubview:downView];

    //开启闪关灯
//    UIButton *torchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//
//    [torchBtn setImage:[UIImage imageNamed:@"sweepself.lineYiconself.lineYlamp"] forState:UIControlStateNormal];
//    [torchBtn setImage:[UIImage imageNamed:@"sweepself.lineYiconself.lineYlamp"] forState:UIControlStateHighlighted];
//    [torchBtn addTarget:self action:@selector(choseTorchMode:) forControlEvents:UIControlEventTouchUpInside];
//    [self addRightButton:torchBtn];

    //扫描红色线
    UIImageView  * tmpLineView = [[UIImageView alloc] initWithFrame:CGRectMake(62, self.lineY, SCREENWIDTH-124, 4)];
    self.lineView = tmpLineView;
    UIImage *lineImage = [[UIImage imageNamed:@"img_sysline" bundleName:@"ModScanStyle1"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 100, 2 , 100)];
    
    self.lineView.image = lineImage;
    [self.readerView addSubview:self.lineView];
    self.lineView.hidden = YES;
    
    
    //提示信息
    UILabel * tmpTipLabel = [[UILabel alloc] init];
    self.tipLabel = tmpTipLabel;
    self.tipLabel.text = @"将二维码放在方框内,即可自动扫描";
    self.tipLabel.textColor =[UIColor whiteColor];
    self.tipLabel.font = [UIFont systemFontOfSize:16];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.readerView  addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(scanImageView.mas_bottom).offset(30);
        make.left.equalTo(self.readerView.mas_left).offset(40);
        make.right.equalTo(self.readerView.mas_right).offset(-40);
        make.centerX.equalTo(self.readerView.mas_centerX);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [self startReading];
                [self startScan];
            }
            else {
                [self showAuthFailed];
            }
        });
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopReading];
}

- (void)startScan{
    self.lineView.hidden = NO;
    //动画
    [UIView animateWithDuration:3.0f
                          delay:0.0f
                        options:UIViewAnimationOptionRepeat
                     animations:^{
                         self.lineView.frame = CGRectMake(62, self.lineY+self.scanHeight-30, SCREENWIDTH-124, 4);
                     }
                     completion:^(BOOL finished) {

                     }];
}

- (void)closeView {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self.delegate scanCanceled];
                             }];
}

- (void)scanFromLibrary {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.showSelectedIndex = YES;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        UIImage *image = photos.firstObject;
        
        NSString *qr = [image QR];
        if (qr.length) {
            [self qrCodeFound:qr];
        }
        else {
            [YuAlertViewController showAlertWithTitle:nil
                                              message:@"没有找到二维码"
                                       viewController:self
                                              okTitle:YUCLOUD_STRING_OK
                                             okAction:nil
                                          cancelTitle:nil
                                         cancelAction:nil
                                           completion:nil];
        }
    }];
}

- (void)showAuthFailed {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    view.alpha = 0;
    
    UILabel *label = [UILabel new];
    label.numberOfLines = 3;
    label.textColor = [UIColor grayColor];
    label.text = @"请在 iPhone 的“设置-隐私-相机”选项中，允许本应用访问你的相机。";
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(16);
        make.right.equalTo(view).offset(-16);
        make.centerY.equalTo(view);
    }];
    
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:.3
                     animations:^{
                         view.alpha = 1;
                     }
                     completion:nil];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *result;
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            result = metadataObj.stringValue;
        }
        else {
//            DDLog(@"不是二维码");
        }
        
        [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:result waitUntilDone:YES];
    }
}

- (void)startReading {
    [self.captureSession startRunning];
}

- (void)stopReading {
    [self.captureSession stopRunning];
}

- (void)reportScanResult:(NSString *)result {
    [self stopReading];
    
    [self qrCodeFound:result];
}

- (void)playFoundTone {
    [[JSQSystemSoundPlayer sharedPlayer] playSoundWithFilename:@"qrcode_found" fileExtension:kJSQSystemSoundTypeWAV];
}

- (void)qrCodeFound:(NSString *)result {
    [self playFoundTone];
    
    [self.delegate scanCodeFound:result];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
