//
//  SpeechView.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/30.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
// 按钮宽高
#define kSpeechViewButtonWidth      35.f
// 滚动视图宽度
#define kSpeechViewMarqueeWidth     SCREENWIDTH*360/750
// 整体宽度
#define kSpeechViewWidth            (10*3+kSpeechViewMarqueeWidth+kSpeechViewButtonWidth*2)
// 整体高度
#define kSpeechViewHeight           48.f

NS_ASSUME_NONNULL_BEGIN

@interface SpeechView : UIView
@property (nonatomic, strong) UILabel *titleLabel;

- (void)showAnimateWithTitle:(NSString *)title;
- (void)speakFinish;

- (void)refreshPlayState;

@end

NS_ASSUME_NONNULL_END
