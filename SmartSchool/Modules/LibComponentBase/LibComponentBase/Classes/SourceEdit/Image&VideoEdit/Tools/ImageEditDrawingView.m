//
//  ImageEditDrawingView.m
//  Conversation
//
//  Created by 唐琦 on 2019/5/28.
//

#import "ImageEditDrawingView.h"

@implementation ImageEditDrawingView

- (instancetype)init {
    if (self = [super init]) {
        self.isMosica = NO;
    }
    
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isMosica) {
        return YES;
    }
    
    unsigned char pixel[1] = {0};
    CGContextRef context = CGBitmapContextCreate(pixel,
                                                 1, 1, 8, 1, NULL,
                                                 kCGImageAlphaOnly);
    UIGraphicsPushContext(context);
    [self.image drawAtPoint:CGPointMake(-point.x, -point.y)];
    UIGraphicsPopContext();
    CGContextRelease(context);
    CGFloat alpha = pixel[0]/255.0f;
    BOOL transparent = alpha < 0.01f;
    
    return !transparent;
}

@end
