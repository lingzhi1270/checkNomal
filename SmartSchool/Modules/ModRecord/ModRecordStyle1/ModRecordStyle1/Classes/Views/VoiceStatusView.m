//
//  VoiceStatusView.m
//  Conversation
//
//  Created by 唐琦 on 2019/7/12.
//

#import "VoiceStatusView.h"

@interface VoiceStatusView ()
@property (nonatomic, strong) UIImageView *cancelImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation VoiceStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.cancelImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_voice_cancel"]];
        [self addSubview:self.cancelImageView];
        self.cancelImageView.hidden = YES;
        [self.cancelImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(-10);
            make.centerX.equalTo(self);
            make.width.height.equalTo(@70.f);
        }];
        
        UIImageView *voiceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_voice_logo"]];
        voiceImageView.tag = 10000;
        voiceImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:voiceImageView];
        
        [voiceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(-10);
            make.right.equalTo(self.mas_centerX).offset(10);
            make.width.height.equalTo(@50.f);
        }];
        
        
        CGFloat itemHeight = 3.f;
        CGFloat margin = 3.f;
        for (int i = 0; i < 8; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.tag = 10001+i;
            imageView.backgroundColor = [UIColor colorWithRGB:0x888888];
            [self addSubview:imageView];
            
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(voiceImageView).offset(-(itemHeight+margin)*i);
                make.left.equalTo(self.mas_centerX).offset(5);
                make.width.equalTo(@(30.f*i/8));
                make.height.equalTo(@(itemHeight));
            }];
        }
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = @"手指上滑，取消发送";
        self.titleLabel.textColor = [UIColor colorWithRGB:0x848484];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.layer.cornerRadius = 5;
        self.titleLabel.layer.masksToBounds = YES;
        [self addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(voiceImageView.mas_bottom).offset(15);
            make.left.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
        }];
    }
    
    return self;
}

- (void)updateVolumne:(float)volumne {
    for (UIView *view in self.subviews) {
        if (view.tag >= 10001) {
            float index = volumne * 8;
            
            if (view.tag-10001 <= index) {
                view.backgroundColor = [UIColor whiteColor];
            }
            else {
                view.backgroundColor = [UIColor colorWithRGB:0x888888];
            }
        }
    }
}

- (void)showCancelTip {
    self.titleLabel.backgroundColor = [UIColor colorWithRGB:0x96312F];
    
    self.cancelImageView.hidden = NO;
    for (UIView *view in self.subviews) {
        if (view.tag >= 10000) {
            view.hidden = YES;
        }
    }
}

- (void)hideCancelTip {
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    self.cancelImageView.hidden = YES;
    for (UIView *view in self.subviews) {
        if (view.tag >= 10000) {
            view.hidden = NO;
        }
    }
}

@end
