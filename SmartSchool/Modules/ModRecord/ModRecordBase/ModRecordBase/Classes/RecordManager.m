//
//  RecordManager.m
//  Module_demo
//
//  Created by 唐琦 on 2019/9/2.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "RecordManager.h"
#import "VoiceStatusView.h"
#import <AVFoundation/AVFoundation.h>

@interface RecordManager () <AVAudioRecorderDelegate>
@property (nonatomic, strong)   AVAudioSession          *session;
@property (nonatomic, strong)   AVAudioRecorder         *audioRecorder;
//@property (nonatomic, strong)   AVAudioPlayer           *audioPlayer;
@property (nonatomic, strong)   VoiceStatusView         *voiceStatusView;
@property (nonatomic, copy)     NSURL                   *audioFile;
@property (nonatomic, strong)   NSTimer                 *volumneTimer;

@end

@implementation RecordManager

+ (instancetype)shareManager {
    static RecordManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RecordManager alloc] init];
    });
    
    return instance;
}

#pragma mark - Lazy load
- (AVAudioSession *)session {
    if (!_session) {
        _session = [AVAudioSession sharedInstance];
    }
    
    return _session;
}

- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        //获取沙盒地址
        NSURL *url = [[UIApplication sharedApplication] cachesURL];
        
        NSString *filePath = [url path];
        filePath = [filePath stringByAppendingPathComponent:@"record.aac"];
        
        self.audioFile = [NSURL fileURLWithPath:filePath];
        
        NSDictionary *settings = @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                   AVSampleRateKey: @44100.00f,
                                   AVEncoderAudioQualityKey: @(AVAudioQualityHigh),
                                   AVNumberOfChannelsKey: @1,
                                   AVLinearPCMBitDepthKey: @8,
                                   AVLinearPCMIsNonInterleaved: @NO,
                                   AVLinearPCMIsFloatKey: @NO,
                                   AVLinearPCMIsBigEndianKey: @NO};
        
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.audioFile
                                                     settings:settings
                                                        error:nil];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        
        [_audioRecorder prepareToRecord];
    }
    
    [self.session setCategory:AVAudioSessionCategoryRecord error:nil];
    
    return _audioRecorder;
}

- (VoiceStatusView *)voiceStatusView {
    if (!_voiceStatusView) {
        _voiceStatusView = [[VoiceStatusView alloc] initWithFrame:CGRectZero];
        _voiceStatusView.backgroundColor = [UIColor colorWithRGBA:0x000000CC];
        _voiceStatusView.layer.cornerRadius = 5;
        _voiceStatusView.layer.masksToBounds = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:_voiceStatusView];
        [_voiceStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo([UIApplication sharedApplication].keyWindow);
            make.height.equalTo(_voiceStatusView.mas_width);
        }];
    }
    
    return _voiceStatusView;
}

#pragma mark - Methods
- (void)startVoiceRecord {
    [self finishVoiceRecord];
    
    [self.session setActive:YES error:nil];
    [self.audioRecorder record];
    
    if ([self.volumneTimer isValid]) {
        [self.volumneTimer invalidate];
        self.volumneTimer = nil;
    }
    WEAK(self, weakSelf);
    static float time = 0;
    self.volumneTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 block:^(NSTimer * _Nonnull timer) {
        [self.audioRecorder updateMeters];
        time += 0.05;
        
        float   level;                // The linear 0.0 .. 1.0 value we need.
        float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
        float   decibels    = [weakSelf.audioRecorder averagePowerForChannel:0];
        
        if (decibels < minDecibels) {
            level = 0.0f;
        }
        else if (decibels >= 0.0f) {
            level = 1.0f;
        }
        else {
            float  root            = 2.0f;
            float  minAmp          = powf(10.0f, 0.05f * minDecibels);
            float  inverseAmpRange = 1.0f / (1.0f - minAmp);
            float  amp             = powf(10.0f, 0.05f * decibels);
            float  adjAmp          = (amp - minAmp) * inverseAmpRange;
            
            level = powf(adjAmp, 1.0f / root);
        }
        
        [self.voiceStatusView updateVolumne:level];
//        DDLog(@"%.2f", time);
//        DDLog(@"%.2f", level);
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(recordVolumneChanged:)]) {
            [weakSelf.delegate recordVolumneChanged:level];
        }
        
        if (time > 5.0) {
            [timer invalidate];
            timer = nil;
            time = 0;
            [weakSelf finishVoiceRecord];
        }
    } repeats:YES];
}

- (void)finishVoiceRecord {
    if (_audioRecorder.recording) {
        [_audioRecorder stop];
    }
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    [self.voiceStatusView updateVolumne:0.0];
    [self.voiceStatusView removeFromSuperview];
    self.voiceStatusView = nil;
    
    if ([self.volumneTimer isValid]) {
        [self.volumneTimer invalidate];
        self.volumneTimer = nil;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordFailed:)]) {
        [self.delegate recordFailed:error];
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [self.voiceStatusView updateVolumne:0.0];
    [self.voiceStatusView removeFromSuperview];
    self.voiceStatusView = nil;
    
    if ([self.volumneTimer isValid]) {
        [self.volumneTimer invalidate];
        self.volumneTimer = nil;
    }
    
    if (self.delegate) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.audioFile.path]) {
            NSData *data = [NSData dataWithContentsOfFile:self.audioFile.path];
            
            if ([self.delegate respondsToSelector:@selector(recordFinish:)]) {
                [self.delegate recordFinish:data];
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(recordFailed:)]) {
                [self.delegate recordFailed:[NSError errorWithDomain:NSOSStatusErrorDomain
                                                                code:404
                                                            userInfo:@{NSLocalizedDescriptionKey:@"录音文件未找到"}]];
            }
        }
    }
    else {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.audioFile.path]) {
            [[NSFileManager defaultManager] removeItemAtPath:self.audioFile.path error:nil];
        }
    }
}

@end
