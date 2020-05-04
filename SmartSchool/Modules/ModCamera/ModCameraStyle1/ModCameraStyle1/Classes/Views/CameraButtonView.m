//
//  CameraButtonView.m
//  Conversation
//
//  Created by qlon 2019/4/24.
//

#import "CameraButtonView.h"

#define kButtonNormalWidth      75.f
#define kButtonExpandWidth      120.f
#define kCenterViewNormalWidth  40.f
#define kCenterViewExpandWidth  55.f

@interface CameraArcView : UIView
@property (nonatomic, assign) float progress;
- (void)loadProgrss:(float)progress;
@end

@implementation CameraArcView

- (void)loadProgrss:(float)progress {
    self.progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, MAIN_COLOR.CGColor);
    CGContextSetLineWidth(context, 3.0);
    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, kButtonExpandWidth/2-1.5, -M_PI_2, -M_PI_2+M_PI*2*self.progress, 0);
    CGContextDrawPath(context, kCGPathStroke);
}

@end

@interface CameraButtonView ()
@property (nonatomic, strong) UIButton      *closeButton;
@property (nonatomic, strong) UIButton      *cameraButton;
@property (nonatomic, strong) UIButton      *cancelButton;
@property (nonatomic, strong) UIButton      *editButton;
@property (nonatomic, strong) UIButton      *sendButton;
@property (nonatomic, strong) UIImageView   *cameraCenterImageView;
@property (nonatomic, strong) CameraArcView *arcView;

@property (nonatomic, strong) NSDate        *touchDownDate;
@property (nonatomic, strong) NSTimer       *touchDownTimer;
@property (nonatomic, assign) BOOL          isTakeVideo;

@end

@implementation CameraButtonView

- (instancetype)init {
    if (self = [super init]) {
        self.isTakeVideo = NO;
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setImage:[UIImage imageNamed:@"ic_camera_close" bundleName:@"ModCameraStyle1"] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];
        
        self.cancelButton = [UIButton buttonWithTitleColor:nil
                                           backgroundColor:[UIColor colorAlphaFromHex:0xFFFFFFAA]
                                               cornerRadii:CGSizeMake(kButtonNormalWidth/2, kButtonNormalWidth/2)];
        [self.cancelButton setImage:[UIImage imageNamed:@"ic_camera_cancel" bundleName:@"ModCameraStyle1"] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cancelButton];
        self.cancelButton.hidden = YES;
        
        self.editButton = [UIButton buttonWithTitleColor:nil
                                           backgroundColor:[UIColor colorAlphaFromHex:0xFFFFFFAA]
                                               cornerRadii:CGSizeMake(kButtonNormalWidth/2, kButtonNormalWidth/2)];
        [self.editButton setImage:[UIImage imageNamed:@"ic_camera_edit" bundleName:@"ModCameraStyle1"] forState:UIControlStateNormal];
        [self.editButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.editButton];
        self.editButton.hidden = YES;
        
        self.sendButton = [UIButton buttonWithTitleColor:nil
                                         backgroundColor:[UIColor whiteColor]
                                             cornerRadii:CGSizeMake(kButtonNormalWidth/2, kButtonNormalWidth/2)];
        [self.sendButton setImage:[UIImage imageNamed:@"ic_camera_send" bundleName:@"ModCameraStyle1"] forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.sendButton];
        self.sendButton.hidden = YES;

        UIImage *image = [[UIImage imageWithColor:[UIColor colorAlphaFromHex:0xFFFFFFCC]
                                             size:CGSizeMake(kButtonNormalWidth, kButtonNormalWidth)
                                byRoundingCorners:UIRectCornerAllCorners
                                      cornerRadii:CGSizeMake(kButtonNormalWidth/2, kButtonNormalWidth/2)]
                          stretchableImageWithLeftCapWidth:kButtonNormalWidth/2
                          topCapHeight:kButtonNormalWidth/2];
        self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cameraButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.cameraButton addTarget:self action:@selector(cameraButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self.cameraButton addTarget:self action:@selector(cameraButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.cameraButton addTarget:self action:@selector(cameraButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [self.cameraButton addTarget:self action:@selector(cameraButtonTouch:) forControlEvents:UIControlEventAllTouchEvents];
        [self addSubview:self.cameraButton];
        
        self.cameraCenterImageView = [[UIImageView alloc] init];
        self.cameraCenterImageView.backgroundColor = [UIColor whiteColor];
        self.cameraCenterImageView.layer.cornerRadius = kCenterViewExpandWidth/2;
        [self.cameraButton addSubview:self.cameraCenterImageView];
        
        self.arcView = [[CameraArcView alloc] init];
        self.arcView.backgroundColor = [UIColor clearColor];
        self.arcView.userInteractionEnabled = NO;
        [self.cameraButton addSubview:self.arcView];
        
        [self.cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.equalTo(@(CGSizeMake(kButtonNormalWidth, kButtonNormalWidth)));
        }];
        
        [self.cameraCenterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.cameraButton);
            make.size.equalTo(@(CGSizeMake(kCenterViewExpandWidth, kCenterViewExpandWidth)));
        }];
        
        [self.arcView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.cameraButton);
            make.size.equalTo(@(CGSizeMake(kButtonExpandWidth, kButtonExpandWidth)));
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.centerY.equalTo(self);
            make.size.equalTo(@(CGSizeMake(kButtonNormalWidth, kButtonNormalWidth)));
        }];
        
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.equalTo(@(CGSizeMake(kButtonNormalWidth, kButtonNormalWidth)));
        }];
        
        [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.equalTo(@(CGSizeMake(kButtonNormalWidth, kButtonNormalWidth)));
        }];
        
        [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.equalTo(@(CGSizeMake(kButtonNormalWidth, kButtonNormalWidth)));
        }];
    }
    
    return self;
}

- (void)cameraButtonChangeToExpand {
    [UIView animateWithDuration:0.1 animations:^{
        UIImage *image = [[UIImage imageWithColor:[UIColor colorAlphaFromHex:0xFFFFFFCC]
                                             size:CGSizeMake(kButtonExpandWidth, kButtonExpandWidth)
                                byRoundingCorners:UIRectCornerAllCorners
                                      cornerRadii:CGSizeMake(kButtonExpandWidth/2, kButtonExpandWidth/2)] stretchableImageWithLeftCapWidth:kButtonExpandWidth/2 topCapHeight:kButtonExpandWidth/2];
        [self.cameraButton setBackgroundImage:image forState:UIControlStateNormal];
        self.cameraCenterImageView.layer.cornerRadius = kCenterViewNormalWidth/2;
        
        [UIView animateWithDuration:0.1 animations:^{
            [self.cameraButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.size.equalTo(@(CGSizeMake(kButtonExpandWidth, kButtonExpandWidth)));
            }];
        }];
        
        [self.cameraCenterImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.cameraButton);
            make.size.equalTo(@(CGSizeMake(kCenterViewNormalWidth, kCenterViewNormalWidth)));
        }];
        
        [self layoutIfNeeded];
    }];
}

- (void)cameraButtonChangeToNormal {
    UIImage *image = [[UIImage imageWithColor:[UIColor colorAlphaFromHex:0xFFFFFFCC]
                                         size:CGSizeMake(kButtonNormalWidth, kButtonNormalWidth)
                            byRoundingCorners:UIRectCornerAllCorners
                                  cornerRadii:CGSizeMake(kButtonNormalWidth/2, kButtonNormalWidth/2)] stretchableImageWithLeftCapWidth:kButtonNormalWidth/2 topCapHeight:kButtonNormalWidth/2];
    [self.cameraButton setBackgroundImage:image forState:UIControlStateNormal];
    self.cameraCenterImageView.layer.cornerRadius = kCenterViewExpandWidth/2;
    
    [self.cameraButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.equalTo(@(CGSizeMake(kButtonNormalWidth, kButtonNormalWidth)));
    }];
    
    [self.cameraCenterImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.cameraButton);
        make.size.equalTo(@(CGSizeMake(kCenterViewExpandWidth, kCenterViewExpandWidth)));
    }];
}

- (void)closeButtonClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismiss)]) {
        [self.delegate dismiss];
    }
}

- (void)editButtonClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editAction)]) {
        [self.delegate editAction];
    }
}

- (void)cameraButtonTouch:(UIButton *)sender {
    sender.highlighted = NO;
}

- (void)cameraButtonTouchDown:(UIButton *)sender {
    self.touchDownDate = [NSDate new];

    self.touchDownTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:self.touchDownDate];
        
        // 长按超过0.5s后开始录视频
        if (interval >= 0.5) {
            [self cameraButtonChangeToExpand];
            
            // 代理在这期间只走一次
            if (!self.isTakeVideo) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(startTakeVideo)]) {
                    self.isTakeVideo = YES;
                    [self.delegate startTakeVideo];
                }
            }
            
            // 视频长度不超过15s
            if (interval <= 15.5) {
                [self.arcView loadProgrss:(interval-0.5)/10.f];
            }
            // 释放定时器
            else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(stopTakeVideo)]) {
                    self.isTakeVideo = NO;
                    [self.delegate stopTakeVideo];
                }
                
                [timer invalidate];
                timer = nil;
            }
        }
    }];
}

- (void)cameraButtonClick:(UIButton *)sender {
    [self.arcView loadProgrss:0.0];
    if ([self.touchDownTimer isValid]) {
        [self.touchDownTimer invalidate];
        self.touchDownTimer = nil;
    }
    
    [self cameraButtonChangeToNormal];
    self.cameraButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.cancelButton.hidden = NO;
    self.editButton.hidden = NO;
    self.sendButton.hidden = NO;
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.centerY.equalTo(self);
        }];
        
        [self.sendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.centerY.equalTo(self);
        }];
        
        [self layoutIfNeeded];
    }];

    NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:self.touchDownDate];
    // 间隔超过0.5秒，算长按
    if (interval > 0.5) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(stopTakeVideo)]) {
            self.isTakeVideo = NO;
            [self.delegate stopTakeVideo];
        }
    }else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(takePhoto)]) {
            [self.delegate takePhoto];
        }
    }
}

- (void)cameraButtonTouchUpOutside:(UIButton *)sender {
    [self.arcView loadProgrss:0.0];
    if ([self.touchDownTimer isValid]) {
        [self.touchDownTimer invalidate];
        self.touchDownTimer = nil;
    }
    
    [self cameraButtonChangeToNormal];
    self.cameraButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.cancelButton.hidden = NO;
    self.editButton.hidden = NO;
    self.sendButton.hidden = NO;
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.centerY.equalTo(self);
        }];
        
        [self.sendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.centerY.equalTo(self);
        }];
        
        [self layoutIfNeeded];
    }];
    
    NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:self.touchDownDate];
    // 间隔超过0.5秒，算长按
    if (interval > 0.5) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(stopTakeVideo)]) {
            self.isTakeVideo = NO;
            [self.delegate stopTakeVideo];
        }
    }else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(takePhoto)]) {
            [self.delegate takePhoto];
        }
    }
}

- (void)cancelButtonClick:(UIButton *)sender {
    self.cameraButton.hidden = NO;
    self.closeButton.hidden = NO;
    self.cancelButton.hidden = YES;
    self.editButton.hidden = YES;
    self.sendButton.hidden = YES;
    
    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self.sendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self layoutIfNeeded];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(removeData)]) {
        [self.delegate removeData];
    }
}

- (void)sendButtonClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendData)]) {
        [self.delegate sendData];
    }
}

@end
