//
//  TTSManager.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/27.
//  Copyright © 2019 唐琦. All rights reserved.
//

// 按钮宽高
#define kSpeechViewButtonWidth      35.f
// 滚动视图宽度
#define kSpeechViewMarqueeWidth     SCREENWIDTH*360/750
// 整体宽度
#define kSpeechViewWidth            (10*3+kSpeechViewMarqueeWidth+kSpeechViewButtonWidth*2)
// 整体高度
#define kSpeechViewHeight           48.f


#import "TTSManager.h"
#import <LibComponentBase/ConfigureHeader.h>
#import <AVKit/AVKit.h>

@interface TTSManager () <AVSpeechSynthesizerDelegate>
@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;
@property (nonatomic, strong) UIView *speechView;
@property (nonatomic, copy)   NSString *content;

@end

@implementation TTSManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static TTSManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[TTSManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
        self.speechSynthesizer.delegate = self;
    }
    
    return self;
}

- (void)speakWithTitle:(NSString *)title content:(NSString *)content {
    self.content = content;
    
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:content];
    utterance.voice = voice;

    [self stopSpeak];
    [self.speechSynthesizer speakUtterance:utterance];
    
    dispatch_async_on_main_queue(^{
        Class speechView = NSClassFromString(@"SpeechView");
        if (speechView) {
            if (!self.speechView || !self.speechView.superview) {
                self.speechView = [[speechView alloc] init];
                [[UIApplication sharedApplication].keyWindow addSubview:self.speechView];
            }
            
            if ([self.speechView respondsToSelector:@selector(showAnimate)]) {
                [self.speechView performSelector:@selector(showAnimate)];
            }
            
            if ([self.speechView valueForKey:@"titleLabel"]) {
                UILabel *titleLabel = [self.speechView valueForKey:@"titleLabel"];
                titleLabel.text = title;
            }
        }
    });
}

// 暂停说话
- (void)pauseSpeak {
    if ([self.speechSynthesizer isSpeaking]) {
        [self.speechSynthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

// 继续说话
- (void)continueSpeak {
    if ([self.speechSynthesizer isPaused]) {
        [self.speechSynthesizer continueSpeaking];
    }
}

// 停止说话
- (void)stopSpeak {
    // 正在说话或者处于暂停状态 都要停止
    if ([self.speechSynthesizer isSpeaking] ||
        [self.speechSynthesizer isPaused]) {
        [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

// 重新播放
- (void)speakAgain {
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:self.content];
    utterance.voice = voice;

    [self.speechSynthesizer speakUtterance:utterance];
}

#pragma mark - AVSpeechSynthesizerDelegate
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
//    DDLog(@"开始说话");
    
    if ([self.speechView respondsToSelector:@selector(refreshPlayState)]) {
        [self.speechView performSelector:@selector(refreshPlayState)];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance {
//    DDLog(@"暂停说话");
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance {
//    DDLog(@"继续说话");
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
//    DDLog(@"说话结束");
    
    if ([self.speechView respondsToSelector:@selector(speakFinish)]) {
        [self.speechView performSelector:@selector(speakFinish)];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
//    DDLog(@"取消说话");
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance {
    
}
@end
