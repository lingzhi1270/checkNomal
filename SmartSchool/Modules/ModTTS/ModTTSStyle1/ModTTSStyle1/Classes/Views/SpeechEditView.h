//
//  SpeechEditView.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/27.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SpeechEditViewBlock)(NSString *text, float rate, float pitch, float volume);

@interface SpeechEditView : UIView
@property (nonatomic, copy) SpeechEditViewBlock block;

- (void)showView;

@end

NS_ASSUME_NONNULL_END
