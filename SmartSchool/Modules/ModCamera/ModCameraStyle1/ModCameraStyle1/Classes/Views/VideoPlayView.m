//
//  VideoPlayView.h
//  Conversation
//
//  Created by qlon 2019/4/16.
//

#import "VideoPlayView.h"
#import <AVFoundation/AVFoundation.h>

NSString * const ModCameraStyle1MediaPlayerTouchPlay  = @"MediaPlayerTouchPlay";
NSString * const ModCameraStyle1MediaPlayerTouchPause = @"MediaPlayerTouchPause";
NSString * const ModCameraStyle1MediaPlayerTouchClose = @"MediaPlayerTouchClose";

@interface VideoBaseBar : UIView

@end

@implementation VideoBaseBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    
    return self;
}

@end

@interface VideoTopBar : VideoBaseBar
@property (nonatomic, copy) NSString        *title;

@end

@implementation VideoTopBar

- (instancetype)initWithClose:(UIImage *)image title:(NSString *)title {
    if (self = [self init]) {
        UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
        if (image) {
            [close setImage:image forState:UIControlStateNormal];
            [close addTarget:self action:@selector(touchOnCloseButton) forControlEvents:UIControlEventTouchUpInside];
        }
        [self addSubview:close];
        
        [close mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(8);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.width.equalTo(close.mas_height);
        }];
        
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:18];
        label.textColor = [UIColor whiteColor];
        label.text = title;
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(close.mas_right).offset(8);
            make.right.lessThanOrEqualTo(self.mas_right).offset(-8);
            make.centerY.equalTo(self);
        }];
    }
    return self;
}

- (void)touchOnCloseButton {
    [[NSNotificationCenter defaultCenter] postNotificationName:ModCameraStyle1MediaPlayerTouchClose object:nil];
}

@end

@interface VideoStatusView : UIView
@property (nonatomic, assign) BOOL          playing;
@property (nonatomic, strong) UIButton      *playBtn;
@property (nonatomic, strong) UIView        *progressPlayed;
@property (nonatomic, strong) UIView        *progressTotal;
@property (nonatomic, strong) UILabel       *timeLabel;

@end

@implementation VideoStatusView

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
        
        self.progressTotal = [[UIView alloc] init];
        self.progressTotal.backgroundColor = [UIColor colorWithRGB:0x909090];
        [self addSubview:self.progressTotal];
        [self.progressTotal mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playBtn.mas_right).offset(8);
            make.centerY.equalTo(self);
            make.height.equalTo(@2);
        }];
        
        self.progressPlayed = [UIView new];
        self.progressPlayed.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.progressPlayed];
        [self.progressPlayed mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.progressTotal);
            make.top.equalTo(self.progressTotal);
            make.bottom.equalTo(self.progressTotal);
            make.width.equalTo(@0);
        }];
        
        self.timeLabel = [UILabel new];
        self.timeLabel.font = [UIFont systemFontOfSize:14];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.progressTotal.mas_right).offset(8);
            make.right.equalTo(self).offset(-8);
            make.width.equalTo(@48);
            make.centerY.equalTo(self);
        }];
    }
    
    return self;
}

- (void)touchPlayButton {
    if (self.playing) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ModCameraStyle1MediaPlayerTouchPause object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:ModCameraStyle1MediaPlayerTouchPlay object:nil];
    }
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    UIImage *image = [UIImage imageNamed:playing?@"ic_media_pause":@"ic_media_play"];
    [self.playBtn setImage:[image imageMaskedWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.playBtn setImage:[image imageMaskedWithColor:[UIColor grayColor]] forState:UIControlStateHighlighted];
}

- (void)setProgress:(CMTime)played total:(CMTime)total {
    if (total.value > 0) {
        NSInteger remain = (long)(total.value / total.timescale - played.value / played.timescale);
        self.timeLabel.text = [self clockTimeStringFromTimeInterval:remain];
        CGFloat percentage = ((CGFloat)played.value / played.timescale) / ((CGFloat)total.value / total.timescale);
        [self.progressPlayed mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.progressTotal);
            make.top.equalTo(self.progressTotal).offset(-1);
            make.bottom.equalTo(self.progressTotal).offset(1);
            make.width.equalTo(self.progressTotal).multipliedBy(percentage);
        }];
        [UIView animateWithDuration:.1
                         animations:^{
                             [self layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

- (NSString *)clockTimeStringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger second = (NSInteger)interval % 60;
    NSInteger min = (NSInteger)interval / 60 % 60;
    NSInteger hour = (NSInteger)interval / (60 * 60);
    
    if (hour == 0) {
        return [NSString stringWithFormat:@"%ld:%ld", (long)min, (long)second];
    }
    else {
        return [NSString stringWithFormat:@"%ld:%ld:%ld", (long)hour, (long)min, (long)second];
    }
}

@end

@interface VideoBottomBar : VideoBaseBar
@property (nonatomic, strong) VideoStatusView       *statusView;

@end

@implementation VideoBottomBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.statusView = [[VideoStatusView alloc] initWithFrame:CGRectMake(0, 0, 1, 38)];
        [self addSubview:self.statusView];
        
        [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    return self;
}

- (void)play {
    [self.statusView setPlaying:YES];
}

- (void)pause {
    [self.statusView setPlaying:NO];
}

- (void)setProgress:(CMTime)played total:(CMTime)total {
    [self.statusView setProgress:played total:total];
}

@end

@interface VideoPlayView ()
@property (nonatomic, copy)   NSURL                         *mediaUrl;
@property (nonatomic, copy)   NSString                      *mediaTitle;
@property (nonatomic, strong) AVPlayer                      *player;
@property (nonatomic, strong) AVPlayerItem                  *playItem;
@property (nonatomic, strong) AVPlayerLayer                 *playerLayer;
@property (nonatomic, strong) id                            timeObserver;
@property (atomic)            BOOL                          barsHidden;
@property (nonatomic, strong) UIButton                      *backBtn;
@property (nonatomic, strong) VideoTopBar                   *topBar;
@property (nonatomic, strong) VideoBottomBar                *bottomBar;
@property (nonatomic, strong) UIButton                      *playButton;
@property (nonatomic, strong) NSTimer                       *timer;

@property (nonatomic, strong) PreviewModel                  *model;
@property (nonatomic, assign) VideoType                     type;

@end

@implementation VideoPlayView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self pause];
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
//    DDLog(@"视频预览界面销毁");
}

- (instancetype)initWithFrame:(CGRect)frame model:(PreviewModel *)model type:(VideoType)type{
    if (self = [self initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ModCameraStyle1MediaPlayerTouchClose:)
                                                     name:ModCameraStyle1MediaPlayerTouchClose
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ModCameraStyle1MediaPlayerTouchPause:)
                                                     name:ModCameraStyle1MediaPlayerTouchPause
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ModCameraStyle1MediaPlayerTouchPlay:)
                                                     name:ModCameraStyle1MediaPlayerTouchPlay
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mediaPlayerItemDidPlayToEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
        
        self.type = type;
        self.model = model;
        self.mediaUrl = [NSURL URLWithString:model.url];
        
        self.playItem = [AVPlayerItem playerItemWithURL:self.mediaUrl];
        self.player = [AVPlayer playerWithPlayerItem:self.playItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.playerLayer.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
        
        self.thumbnailImageView = [[UIImageView alloc] initWithImage:model.thumbnailImage];
        self.thumbnailImageView.userInteractionEnabled = YES;
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.thumbnailImageView];
        
        self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.backBtn addTarget:self action:@selector(tapView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backBtn];
        
        self.topBar = [[VideoTopBar alloc] initWithClose:[UIImage imageNamed:@"ic_app_back" bundleName:@"LibComponentBase"] title:self.mediaTitle];
        [self addSubview:self.topBar];

        self.bottomBar = [VideoBottomBar new];
        [self addSubview:self.bottomBar];
        
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playButton setImage:[[UIImage imageNamed:@"ic_preview_play" bundleName:@"ModCameraStyle1"] imageMaskedWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"ic_preview_pause" bundleName:@"ModCameraStyle1"] forState:UIControlStateSelected];
        [self.playButton addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playButton];
        
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.thumbnailImageView);
        }];
        
        [self setToolbarsHidden:NO animated:NO];
        
        if (type == VideoTypeNormal) {
            self.backBtn.hidden = NO;
            self.topBar.hidden = NO;
            self.bottomBar.hidden = NO;
            
            [self startDelayHideBars];
        }
        else {
            self.backBtn.hidden = YES;
            self.topBar.hidden = YES;
            self.bottomBar.hidden = YES;
            
            [self play];
        }
    }
    
    return self;
}

- (void)tapView {
    [self setToolbarsHidden:!self.barsHidden animated:YES];
}

- (void)playButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self play];
    }
    else {
        [self pause];
    }
}

- (void)play {
    if (!self.playerLayer.superlayer) {
        [self.layer addSublayer:self.playerLayer];
        
        CMTime interval = CMTimeMakeWithSeconds(.3, NSEC_PER_SEC);
        WEAK(self, wself);
        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:nil
                                                                 usingBlock:^(CMTime time) {
                                                                     CMTime total = wself.playItem.duration;
                                                                     [wself.bottomBar setProgress:time total:total];
                                                                 }];
    }
    
    self.thumbnailImageView.hidden = YES;
    self.playButton.hidden = YES;
    [self bringSubviewToFront:self.playButton];

    [self.player play];
    [self.bottomBar play];
}

- (void)pause {
    [self.player pause];
    [self.bottomBar pause];
    self.playButton.selected = NO;
    self.playButton.hidden = NO;
}

- (void)replacePlayWithUrl:(NSURL *)url {
    [self.player pause];
    self.playItem = [AVPlayerItem playerItemWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:self.playItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    if (self.playerLayer.superlayer) {
        [self.playerLayer.superlayer removeFromSuperlayer];
    }

    [self play];
}

- (void)ModCameraStyle1MediaPlayerTouchClose:(NSNotification *)noti {
    self.thumbnailImageView.hidden = NO;
    self.playButton.hidden = NO;
    self.topBar.hidden = YES;
    self.bottomBar.hidden = YES;
    
    if (self.player) {
        [self.player removeTimeObserver:self.timeObserver];
        self.player = nil;
        self.playItem = nil;
        [self.playerLayer removeFromSuperlayer];
    }
}

- (void)ModCameraStyle1MediaPlayerTouchPause:(NSNotification *)noti {
    [self pause];
}

- (void)ModCameraStyle1MediaPlayerTouchPlay:(NSNotification *)noti {
    [self play];
}

- (void)mediaPlayerItemDidPlayToEnd:(NSNotification *)noti {
    [self pause];
    [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    if (self.type == VideoTypePreview) {
        [self play];
    }
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
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
}

- (void)delayHideTimerFire:(NSTimer *)timer {
    if (!self.barsHidden) {
        [self setToolbarsHidden:YES animated:YES];
    }
}

- (void)setBarsContraintsWhenHidden:(BOOL)hidden {
    [UIView animateWithDuration:0.2 animations:^{
        [self.topBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            if (hidden) {
                make.bottom.equalTo(self.mas_top);
            }
            else {
                make.top.equalTo(self).offset(20);
            }
            make.height.equalTo(@48);
        }];
        
        [self.bottomBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            if (hidden) {
                make.top.equalTo(self.mas_bottom);
            }
            else {
                make.bottom.equalTo(self.mas_bottom);
            }
            make.height.equalTo(@48);
        }];
        
        [self layoutIfNeeded];
    }];
}

- (void)setToolbarsHidden:(BOOL)hidden animated:(BOOL)animated {
    [self stopDelayHideBars];
    self.barsHidden = hidden;
    [self setBarsContraintsWhenHidden:hidden];
}

@end
