//
//  MarqueeView.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/30.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "MarqueeView.h"

@interface MarqueeView ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) CADisplayLink *marqueeDisplayLink;
@property (nonatomic, assign) BOOL isReversing;

@end

@implementation MarqueeView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview == nil) {
        [self stopMarquee];
    }
}

- (instancetype)init {
    if (self = [super init]) {
        self.marqueeType = MarqueeTypeLeft;
        self.contentMargin = 12.f;
        self.frameInterval = 1;
        self.pointsPerFrame = 0.5;
        
        [self initializeViews];
    }
    
    return self;
}

- (void)initializeViews {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.containerView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.contentView) {
        return;
    }
    
    UIView *validContentView = self.contentView;
    for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
    }

    //对于复杂的视图，需要自己重写contentView的sizeThatFits方法，返回正确的size
    [validContentView sizeToFit];
    [self.containerView addSubview:validContentView];
    
    if (self.marqueeType == MarqueeTypeReverse) {
        self.containerView.frame = CGRectMake(0, 0, validContentView.bounds.size.width, self.bounds.size.height);
    }
    else {
        self.containerView.frame = CGRectMake(0, 0, validContentView.bounds.size.width*2 + self.contentMargin, self.bounds.size.height);
    }
    
    // content内容超过显示宽度才需要滚动
    if (validContentView.bounds.size.width > self.bounds.size.width) {
        validContentView.frame = CGRectMake(0, 0, validContentView.bounds.size.width, self.bounds.size.height);
        if (self.marqueeType != MarqueeTypeReverse) {
            //骚操作：UIView是没有遵从拷贝协议的。可以通过UIView支持NSCoding协议，间接来复制一个视图
            UIView *otherContentView = [self copyMarqueeView:validContentView];
            otherContentView.frame = CGRectMake(validContentView.bounds.size.width + self.contentMargin, 0, validContentView.bounds.size.width, self.bounds.size.height);
            [self.containerView addSubview:otherContentView];
        }
        
        [self startMarquee];
    }
    else {
        validContentView.frame = CGRectMake(0, 0, validContentView.bounds.size.width, self.bounds.size.height);
        [self stopMarquee];
    }
}

- (UIView *)copyMarqueeView:(UIView *)view {
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:view];
    UIView *copyView = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    
    return copyView;
}

- (void)startMarquee {
    [self stopMarquee];
    
    if (self.marqueeType == MarqueeTypeRight) {
        CGRect frame = self.containerView.frame;
        frame.origin.x = self.bounds.size.width - frame.size.width;
        self.containerView.frame = frame;
    }
    
    self.marqueeDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(processMarquee)];
    self.marqueeDisplayLink.frameInterval = self.frameInterval;
    [self.marqueeDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopMarquee {
    [self.marqueeDisplayLink invalidate];
    self.marqueeDisplayLink = nil;
}

- (void)processMarquee {
    CGRect frame = self.containerView.frame;
    
    switch (self.marqueeType) {
        case MarqueeTypeLeft: {
            CGFloat targetX = -(self.contentView.bounds.size.width + self.contentMargin);
            if (frame.origin.x <= targetX) {
                frame.origin.x = 0;
                self.containerView.frame = frame;
            }
            else {
                frame.origin.x -= self.pointsPerFrame;
                if (frame.origin.x < targetX) {
                    frame.origin.x = targetX;
                }
                
                self.containerView.frame = frame;
            }
        }
            
            break;
        case MarqueeTypeRight: {
            CGFloat targetX = self.bounds.size.width - self.contentView.bounds.size.width;
            if (frame.origin.x >= targetX) {
                frame.origin.x = self.bounds.size.width - self.containerView.bounds.size.width;
                self.containerView.frame = frame;
            }
            else {
                frame.origin.x += self.pointsPerFrame;
                if (frame.origin.x > targetX) {
                    frame.origin.x = targetX;
                }
                self.containerView.frame = frame;
            }
        }
            
            break;
            
        case MarqueeTypeReverse: {
            if (self.isReversing) {
                CGFloat targetX = 0;
                if (frame.origin.x > targetX) {
                    frame.origin.x = 0;
                    self.containerView.frame = frame;
                    self.isReversing = NO;
                }
                else {
                    frame.origin.x += self.pointsPerFrame;
                    if (frame.origin.x > 0) {
                        frame.origin.x = 0;
                        self.isReversing = NO;
                    }
                    self.containerView.frame = frame;
                }
            }
            else {
                CGFloat targetX = self.bounds.size.width - self.containerView.bounds.size.width;
                if (frame.origin.x <= targetX) {
                    self.isReversing = YES;
                }
                else {
                    frame.origin.x -= self.pointsPerFrame;
                    if (frame.origin.x < targetX) {
                        frame.origin.x = targetX;
                        self.isReversing = YES;
                    }
                    self.containerView.frame = frame;
                }
            }
        }
            
            break;
        default:
            break;
    }
}

@end
