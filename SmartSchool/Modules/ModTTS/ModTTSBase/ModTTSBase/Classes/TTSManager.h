//
//  TTSManager.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/27.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/BaseManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTSManager : BaseManager

- (void)speakWithTitle:(NSString *)title content:(NSString *)content;
// 暂停说话
- (void)pauseSpeak;
// 继续说话
- (void)continueSpeak;
// 停止说话
- (void)stopSpeak;
// 重新播放
- (void)speakAgain;

@end

NS_ASSUME_NONNULL_END
