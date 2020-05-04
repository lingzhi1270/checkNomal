//
//  SpeechView.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/30.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "SpeechView.h"
#import "MarqueeView.h"
#import <ModTTSBase/TTSManager.h>

static int dismissTime = 0;

@interface SpeechView ()
@property (nonatomic, strong) MarqueeView *marqueeView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *expandButton;
@property (nonatomic, strong) NSTimer *dismissTimer;

@property (nonatomic, assign) BOOL dismiss;
@property (nonatomic, assign) CGFloat lastCenterY;
@property (nonatomic, assign) BOOL alreadyShow;
@property (nonatomic, assign) BOOL finishSpeak;

@end

@implementation SpeechView

- (instancetype)init {
    if (self = [super init]) {
        
        self.frame = CGRectMake(-15, SCREENHEIGHT-kSpeechViewHeight-15, kSpeechViewWidth, kSpeechViewHeight);
        self.layer.cornerRadius = 3;
        self.layer.masksToBounds = YES;
        self.alpha = 0.0;
        self.dismiss = NO;
        self.alreadyShow = NO;
        self.finishSpeak = NO;
        self.lastCenterY = self.center.y;
        
        // 添加拖动手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:pan];
        
        // 渐变层
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, kSpeechViewWidth, kSpeechViewHeight);
        gradient.colors = @[(id)[UIColor colorWithRGB:0x1F1F26].CGColor,(id)[UIColor colorWithRGB:0x6C737A].CGColor];
        gradient.startPoint = CGPointMake(0, 0.5);
        gradient.endPoint = CGPointMake(1, 0.5);
        [self.layer addSublayer:gradient];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        
        self.marqueeView = [[MarqueeView alloc] init];
        self.marqueeView.contentView = self.titleLabel;
        [self addSubview:self.marqueeView];
        
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.playButton setImage:[UIImage imageNamed:@"ic_tts_pause"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"ic_tts_pause" bundleName:@"ModTTSStyle1"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"ic_tts_play" bundleName:@"ModTTSStyle1"] forState:UIControlStateSelected];
        [self.playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playButton];

        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setImage:[UIImage imageNamed:@"ic_tts_close" bundleName:@"ModTTSStyle1"] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];
        
        self.expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.expandButton setImage:[UIImage imageNamed:@"ic_tts_expand" bundleName:@"ModTTSStyle1"] forState:UIControlStateNormal];
        [self.expandButton addTarget:self action:@selector(expandAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.expandButton];
        self.expandButton.hidden = YES;
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-10);
            make.size.equalTo(@(CGSizeMake(kSpeechViewButtonWidth, kSpeechViewButtonWidth)));
        }];
        
        [self.expandButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self);
            make.size.equalTo(@(CGSizeMake(kSpeechViewButtonWidth, kSpeechViewButtonWidth)));
        }];
        
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self.closeButton.mas_left);
            make.size.equalTo(@(CGSizeMake(kSpeechViewButtonWidth, kSpeechViewButtonWidth)));
        }];
        
        [self.marqueeView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self).offset(5);
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(10);
            make.right.equalTo(self.playButton.mas_left).offset(-10);
            make.width.equalTo(@(kSpeechViewMarqueeWidth));
            make.height.equalTo(@(30));
        }];
    }
    
    return self;
}

- (void)refreshPlayState {
    self.playButton.selected = NO;
}

- (void)changedContent {
    self.marqueeView.contentView = self.titleLabel;
    [self.marqueeView layoutSubviews];
}

- (void)speakFinish {
    self.finishSpeak = YES;
    self.playButton.selected = YES;
    [self stopTimer];
}

#pragma mark - ButtonClick
- (void)playAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    [self startTimer];
    
    // 重新说话
    if (self.finishSpeak) {
        self.finishSpeak = NO;
        [[TTSManager shareManager] speakAgain];
    }
    else {
        // 暂停说话
        if (sender.selected) {
            [[TTSManager shareManager] pauseSpeak];
        }
        // 继续说话
        else {
            [[TTSManager shareManager] continueSpeak];
        }
    }
    
}

- (void)closeAction {
    [[TTSManager shareManager] stopSpeak];
    [self closeAnimate];
    [self stopTimer];
}

- (void)expandAction {
    [self showAnimate];
}

#pragma mark - 定时器
- (void)startTimer {
    [self stopTimer];
    // 显示4秒后自动缩小到屏幕左侧
    self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          block:^(NSTimer * _Nonnull timer) {
//                                                              DDLog(@"倒计时中 %d...", 4-dismissTime);
                                                              dismissTime++;
                                                              if (dismissTime > 4) {
                                                                  [self dismissAnimate];
                                                                  [timer invalidate];
                                                                  timer = nil;
                                                                  dismissTime = 0;
                                                              }
                                                          }
                                                        repeats:YES];
}

- (void)stopTimer {
    if ([self.dismissTimer isValid]) {
        [self.dismissTimer invalidate];
        self.dismissTimer = nil;
        dismissTime = 0;
    }
}

#pragma mark - 进场和出场动画
- (void)showAnimate {
    if (self.alreadyShow) {
        [self changedContent];
    }
    
    if (self.dismiss) {
        self.dismiss = NO;
        
        self.expandButton.hidden = YES;
        self.closeButton.alpha = 1.0;
        self.closeButton.hidden = NO;
        [UIView animateWithDuration:0.7
                              delay:0.0
             usingSpringWithDamping:0.6
              initialSpringVelocity:1.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                            self.alpha = 1.0;
                            self.frame = CGRectMake(15, self.frame.origin.y, kSpeechViewWidth, kSpeechViewHeight);
                         }
                         completion:^(BOOL finished) {
                            [self startTimer];
                            self.alreadyShow = YES;
                         }];
    }
    else {
        self.alpha = 0.0;
        [UIView animateWithDuration:0.3
                         animations:^{
                            self.alpha = 1.0;
                            self.frame = CGRectMake(15, self.frame.origin.y, kSpeechViewWidth, kSpeechViewHeight);
                         }
                         completion:^(BOOL finished) {
                            [self startTimer];
                            self.alreadyShow = YES;
                         }];
    }
    
    
}

- (void)dismissAnimate {
    self.dismiss = YES;
    
    self.closeButton.alpha = 1.0;
    self.expandButton.hidden = NO;
    self.expandButton.alpha = 0.0;
    
    [UIView animateWithDuration:0.7
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.closeButton.alpha = 0.0;
                         self.expandButton.alpha = 1.0;
                         self.frame = CGRectMake(-(kSpeechViewWidth-kSpeechViewButtonWidth), self.frame.origin.y, kSpeechViewWidth, kSpeechViewHeight);
                     } completion:^(BOOL finished) {
                         self.closeButton.hidden = YES;
                     }];
}

- (void)closeAnimate {
    self.alpha = 1.0;

    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
        self.frame = CGRectMake(-15, self.frame.origin.y, kSpeechViewWidth, kSpeechViewHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 拖动手势
- (void)panAction:(UIPanGestureRecognizer *)recognizer {
    static BOOL shouldPause = NO;
    if (!self.dismiss && [self.dismissTimer isValid]) {
//        DDLog(@"手势开始，删除定时器");
        [self stopTimer];
        shouldPause = YES;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"小窗口拖动开始");
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        // 左滑收起控件
        if (translation.x < 0 &&
            translation.y == 0 &&
            self.lastCenterY > recognizer.view.center.y - 2 &&
            self.lastCenterY < recognizer.view.center.y + 2) {
//            DDLog(@"手势左滑收起控件，不重启定时器");
            shouldPause = NO;
            [self dismissAnimate];
        }
        else {
            CGFloat endCenterY = recognizer.view.center.y + translation.y;
//            DDLog(@"%f", endCenterY+kSpeechViewHeight/2);
            if (endCenterY-kSpeechViewHeight/2 < KStatusBarHeight) {
                endCenterY = KStatusBarHeight+kSpeechViewHeight/2;
            }
            
            if (endCenterY+kSpeechViewHeight/2 > SCREENHEIGHT-15) {
                endCenterY = SCREENHEIGHT-15-kSpeechViewHeight/2;
            }
            
            recognizer.view.center = CGPointMake(recognizer.view.center.x, endCenterY);
            [recognizer setTranslation:CGPointZero inView:self];
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        self.lastCenterY = recognizer.view.center.y;
        
        if (shouldPause) {
//            DDLog(@"手势结束，重启定时器");
            shouldPause = NO;
            [self startTimer];
        }
    }
}

@end
