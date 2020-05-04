//
//  VoiceStatusView.h
//  Conversation
//
//  Created by 唐琦 on 2019/7/12.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoiceStatusView : UIView

- (void)updateVolumne:(float)volumne;
- (void)showCancelTip;
- (void)hideCancelTip;

@end

NS_ASSUME_NONNULL_END
