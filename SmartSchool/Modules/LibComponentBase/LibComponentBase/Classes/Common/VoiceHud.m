//
//  VoiceHud.m
//  Unilife
//
//  Created by 唐琦 on 2018/3/27.
//  Copyright © 2018年 南京远御网络科技有限公司. All rights reserved.
//

#import "VoiceHud.h"

static CGFloat maxMeter = 0;

@interface VoiceHud ()

@property (nonatomic, strong) UIImageView   *imageView;
@property (nonatomic, strong) UILabel       *labelView;

@property (nonatomic, copy)   NSArray       *images;
@property (nonatomic, strong) NSTimer       *timer;
@property (nonatomic, assign) NSInteger     volume;
@property (nonatomic, assign) NSInteger     current;

@end

@implementation VoiceHud

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        CALayer *layer = self.layer;
        layer.cornerRadius = 6;
        layer.masksToBounds = YES;
        
        self.imageView = [UIImageView new];
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(24);
            make.right.equalTo(self).offset(-24);
            make.top.equalTo(self).offset(16);
            make.width.equalTo(@88);
            make.height.equalTo(self.imageView.mas_width);
        }];
        
        self.labelView = [UILabel new];
        self.labelView.textColor = [UIColor whiteColor];
        self.labelView.textAlignment = NSTextAlignmentCenter;
        self.labelView.font = [UIFont systemFontOfSize:12];
        self.labelView.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.labelView];
        [self.labelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.imageView);
            make.width.lessThanOrEqualTo(self.imageView).offset(32);
            make.top.equalTo(self.imageView.mas_bottom).offset(8);
            make.bottom.equalTo(self).offset(-16);
        }];
        
        [self setImagesWithTintColor:[UIColor whiteColor]];
    }
    
    return self;
}

- (void)setImagesWithTintColor:(UIColor *)color {
    NSInteger i = 1;
    NSMutableArray *arr = [NSMutableArray new];
    while (YES) {
        NSString *string = [NSString stringWithFormat:@"icon_speaking_volume_%ld", (long)i];
        UIImage *image = [[UIImage imageNamed:string] imageMaskedWithColor:color];
        if (image) {
            [arr addObject:image];
            i++;
        }
        else {
            break;
        }
    }
    
    self.images = arr.copy;
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = [_tintColor copy];
    
    [self setImagesWithTintColor:tintColor];
    self.imageView.image = self.images.firstObject;
    
    self.labelView.textColor = tintColor;
}

- (void)setTitle:(NSString *)title {
    self.labelView.text = title;
}

- (void)setMeter:(CGFloat)meter {
    maxMeter = MAX(maxMeter, meter);
    NSInteger volume = self.images.count * meter / maxMeter;
    volume = MIN(volume, self.images.count);
    
    [self setVolume:volume];
}

- (void)setVolume:(NSInteger)volume {
    _volume = volume;
    
    if (volume > self.current) {
        // 音量增大
        if (self.current == 0) {
            [self startVolumeTimer];
        }
        
        self.current++;
    }
    else if (self.current > 0) {
        self.current--;
    }
    else {
        [self stopVolumeTimer];
    }
}

- (void)startVolumeTimer {
    [self stopVolumeTimer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.2
                                                  target:self
                                                selector:@selector(timerFire:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopVolumeTimer {
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    
    self.timer = nil;
}

- (void)timerFire:(NSTimer *)timer {
    if (self.current >= 0 && self.current < self.images.count) {
        self.imageView.image = self.images[self.current];
    }
}

@end
