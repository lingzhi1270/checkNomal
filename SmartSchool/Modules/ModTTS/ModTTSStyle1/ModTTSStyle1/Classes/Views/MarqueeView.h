//
//  MarqueeView.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/30.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    MarqueeTypeLeft,
    MarqueeTypeRight,
    MarqueeTypeReverse,
} MarqueeType;

@protocol MarqueeViewCopyable <NSObject>

- (UIView *)copyMarqueeView;

@end

@interface MarqueeView : UIView
@property (nonatomic, assign) MarqueeType marqueeType;
@property (nonatomic, assign) CGFloat contentMargin;    // 两个视图之间的间隔
@property (nonatomic, assign) int frameInterval;        // 多少帧回调一次，一帧时间1/60秒
@property (nonatomic, assign) CGFloat pointsPerFrame;   // 每次回调移动多少点
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) id<MarqueeViewCopyable> delegate;

- (void)continueMarquee;
- (void)stopMarquee;

@end

NS_ASSUME_NONNULL_END
