//
//  ModPlayerStyle1ViewController.m
//  Unilife
//
//  Created by 唐琦 on 2019/12/24.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ModPlayerStyle1ViewController.h"

NSString * const ModPlayerStyle1MediaPlayerTouchPlay = @"MediaPlayerTouchPlay";
NSString * const ModPlayerStyle1MediaPlayerTouchPause = @"MediaPlayerTouchPause";
NSString * const ModPlayerStyle1MediaPlayerTouchClose = @"MediaPlayerTouchClose";

@interface ModPlayerStyle1VideoBaseBar : UIView
@end

@implementation ModPlayerStyle1VideoBaseBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    
    return self;
}

@end

@interface ModPlayerStyle1VideoTopBar : ModPlayerStyle1VideoBaseBar
@property (nonatomic, copy) NSString  *title;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ModPlayerStyle1VideoTopBar

- (instancetype)initWithClose:(UIImage *)image {
    if (self = [super init]) {
        UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
        if (image) {
            [close setImage:image forState:UIControlStateNormal];
            [close addTarget:self action:@selector(touchOnCloseButton) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self addSubview:close];
        
        
        self.titleLabel = [UILabel new];
        self.titleLabel.font = [UIFont systemFontOfSize:18];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        
        [close mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(8);
            make.top.bottom.equalTo(self);
            make.size.equalTo(@(CGSizeMake(44.f, 44.f)));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(close.mas_right).offset(8);
            make.right.lessThanOrEqualTo(self).offset(-(44+8));
            make.centerY.equalTo(close);
        }];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

- (void)touchOnCloseButton {
    [[NSNotificationCenter defaultCenter] postNotificationName:ModPlayerStyle1MediaPlayerTouchClose object:nil];
}

@end

@interface ModPlayerStyle1VideoBottomBar : UIView
@property (nonatomic, assign) BOOL          play;
@property (nonatomic, strong) UIButton      *playBtn;
@property (nonatomic, strong) UISlider      *sliderView;
@property (nonatomic, strong) UILabel       *timeLabel;

@end

@implementation ModPlayerStyle1VideoBottomBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        
        self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playBtn addTarget:self action:@selector(touchPlayButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playBtn];
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(16);
            make.height.equalTo(@16);
            make.width.equalTo(self.playBtn.mas_height);
            make.centerY.equalTo(self);
        }];
        
        self.sliderView = [[UISlider alloc] init];
        [self addSubview:self.sliderView];
        
        [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playBtn.mas_right).offset(8);
            make.centerY.equalTo(self);
            make.height.equalTo(@30);
        }];
        
        self.timeLabel = [UILabel new];
        self.timeLabel.font = [UIFont systemFontOfSize:14];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.sliderView.mas_right).offset(8);
            make.right.equalTo(self).offset(-8);
            make.width.equalTo(@48);
            make.centerY.equalTo(self);
        }];
    }
    
    return self;
}

- (void)touchPlayButton {
    if (self.play) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ModPlayerStyle1MediaPlayerTouchPause object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:ModPlayerStyle1MediaPlayerTouchPlay object:nil];
    }
}

- (void)setPlay:(BOOL)play {
    _play = play;
    
    UIImage *image = [UIImage imageNamed:play?@"ic_media_pause":@"ic_media_play" bundleName:@"ModPlayerStyle1"];
    [self.playBtn setImage:[image imageMaskedWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.playBtn setImage:[image imageMaskedWithColor:[UIColor grayColor]] forState:UIControlStateHighlighted];
}

- (void)setProgress:(CMTime)played total:(CMTime)total {
    if (total.value > 0) {
        NSInteger remain = (long)(total.value / total.timescale - played.value / played.timescale);
        
        self.timeLabel.text = [self clockTimeStringFromTimeInterval:remain];
        
        CGFloat percentage = ((CGFloat)played.value / played.timescale) / ((CGFloat)total.value / total.timescale);
        
        [self.sliderView setValue:percentage animated:YES];
        
//        [self.progressPlayed mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.progressTotal);
//            make.top.equalTo(self.progressTotal).offset(-1);
//            make.bottom.equalTo(self.progressTotal).offset(1);
//            make.width.equalTo(self.progressTotal).multipliedBy(percentage);
//        }];
        
        [UIView animateWithDuration:.1
                         animations:^{
                             [self layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

- (NSString *)clockTimeStringFromTimeInterval:(NSInteger)interval {
    NSInteger second = (NSInteger)interval % 60;
    NSInteger min = (NSInteger)interval / 60 % 60;
    NSInteger hour = (NSInteger)interval / (60 * 60);
    
    NSString *secondString = @(second).stringValue;
    NSString *minString = @(min).stringValue;
    NSString *hourString = @(hour).stringValue;
    
    if (second < 10) {
        secondString = [NSString stringWithFormat:@"0%@", @(second)];
    }
    if (min < 10) {
        minString = [NSString stringWithFormat:@"0%@", @(min)];
    }
    if (hour < 10) {
        hourString = [NSString stringWithFormat:@"0%@", @(hour)];
    }
    
    if (hour == 0) {
        return [NSString stringWithFormat:@"%@:%@", minString, secondString];
    }
    else {
        return [NSString stringWithFormat:@"%@:%@:%@", hourString, minString, secondString];
    }
}

@end

@interface ModPlayerStyle1ViewController ()
@property (nonatomic, copy)   NSString                      *mediaTitle;
@property (nonatomic, copy)   NSURL                         *mediaUrl;
@property (nonatomic, strong) AVPlayer                      *player;
@property (nonatomic, strong) AVPlayerLayer                 *playerLayer;
@property (nonatomic, strong) AVPlayerItem                  *playItem;
@property (nonatomic, strong) id                            timeObserver;

@property (atomic)            BOOL              barsHidden;
@property (nonatomic, strong) ModPlayerStyle1VideoTopBar       *topBar;
@property (nonatomic, strong) ModPlayerStyle1VideoBottomBar    *bottomBar;
@property (nonatomic, strong) NSTimer           *timer;

@end

@implementation ModPlayerStyle1ViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.topView.hidden = YES;
    
    UIView *maskView = [UIView new];
    [maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)]];
    [self.view addSubview:maskView];
    
    self.topBar = [[ModPlayerStyle1VideoTopBar alloc] initWithClose:[UIImage imageNamed:@"ic_app_back" bundleName:@"LibComponentBase"]];
    self.topBar.title = self.mediaTitle;
    [self.view addSubview:self.topBar];
    
    self.bottomBar = [ModPlayerStyle1VideoBottomBar new];
    self.bottomBar.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8];
    [self.bottomBar.sliderView addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.bottomBar];
    
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.safeArea);
    }];
    
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.safeArea);
        make.height.equalTo(@48);
    }];
    
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.safeArea);
        make.height.equalTo(@48);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ModPlayerStyle1MediaPlayerTouchClose:)
                                                 name:ModPlayerStyle1MediaPlayerTouchClose
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ModPlayerStyle1MediaPlayerTouchPause:)
                                                 name:ModPlayerStyle1MediaPlayerTouchPause
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ModPlayerStyle1MediaPlayerTouchPlay:)
                                                 name:ModPlayerStyle1MediaPlayerTouchPlay
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaPlayerItemDidPlayToEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [self setToolbarsHidden:NO animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CMTime interval = CMTimeMakeWithSeconds(.3, NSEC_PER_SEC);
    WEAK(self, wself);
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:nil
                                                             usingBlock:^(CMTime time) {
                                                                 [wself.bottomBar setProgress:time total:wself.playItem.duration];
                                                             }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.player removeTimeObserver:self.timeObserver];
}

- (void)playWithUrl:(NSString *)urlString title:(NSString *)title {
    self.mediaUrl = [NSURL URLWithString:urlString];
    self.mediaTitle = title;
    
    self.playItem = [AVPlayerItem playerItemWithURL:self.mediaUrl];
    self.player = [AVPlayer playerWithPlayerItem:self.playItem];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.frame = CGRectMake(0, KTopViewHeight, SCREENWIDTH, SCREENHEIGHT-KTopViewHeight);
    [self.view.layer addSublayer:self.playerLayer];
    
    [self play];
}

- (void)tapView {
    [self setToolbarsHidden:!self.barsHidden animated:YES];
}

- (void)sliderValueChanged:(UISlider *)slider {
    [self.player pause];
    
    CMTime time = CMTimeMake(self.playItem.duration.value*slider.value, self.playItem.duration.timescale);
    [self.player seekToTime:time
            toleranceBefore:CMTimeMake(1, 1000)
             toleranceAfter:CMTimeMake(1, 1000)];
    
    [self.player play];
}

- (void)play {
    [self.player play];
    
    self.bottomBar.play = YES;;
}

- (void)pause {
    [self.player pause];
    
    self.bottomBar.play = NO;
}

- (void)ModPlayerStyle1MediaPlayerTouchClose:(NSNotification *)noti {
    [self pause];
    
    [self closeViewController];
}

- (void)ModPlayerStyle1MediaPlayerTouchPause:(NSNotification *)noti {
    [self pause];
}

- (void)ModPlayerStyle1MediaPlayerTouchPlay:(NSNotification *)noti {
    [self play];
}

- (void)mediaPlayerItemDidPlayToEnd:(NSNotification *)noti {
    [self pause];
    
    [self closeViewController];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startDelayHideBars];
}

- (void)startDelayHideBars {
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3
                                                  target:self
                                                selector:@selector(delayHideTimerFire:)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)stopDelayHideBars {
    [self.timer invalidate];
}

- (void)delayHideTimerFire:(NSTimer *)timer {
    if (!self.barsHidden) {
        [self setToolbarsHidden:YES animated:YES];
    }
}

- (BOOL)prefersStatusBarHidden {
    return self.barsHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setBarsContraintsWhenHidden:(BOOL)hidden {
    [self.topBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        if (hidden) {
            make.bottom.equalTo(self.view.mas_top);
        }
        else {
            make.top.equalTo(self.view).offset(20);
        }
        
        make.height.equalTo(@48);
    }];
    
    [self.bottomBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        if (hidden) {
            make.top.equalTo(self.view.mas_bottom);
        }
        else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
        
        make.height.equalTo(@48);
    }];
}

- (void)setToolbarsHidden:(BOOL)hidden animated:(BOOL)animated {
    [self stopDelayHideBars];
    
    self.barsHidden = hidden;
    [self setBarsContraintsWhenHidden:hidden];
    
    if (hidden) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    [UIView animateWithDuration:.3
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self setNeedsStatusBarAppearanceUpdate];
                     }];
}

- (void)closeViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
