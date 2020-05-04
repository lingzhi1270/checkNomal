//
//  ScratchCardView.m
//  RGBTool
//
//  Created by admin on 23/08/2017.
//  Copyright © 2017 gcg. All rights reserved.
//

#import "XScratchView.h"
#import "ViroyalTools/VICocoaTools.h"

@interface XScratchView ()

/**  */
@property (nonatomic, strong) UIImageView *surfaceImageView;
/** <##> */
@property (nonatomic, strong) CALayer *imageLayer;
/**  */
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
/** 手指的涂抹路径 */
@property (nonatomic, assign) CGMutablePathRef path;

@end

@implementation XScratchView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat topMargin = [UIScreen resolution] > UIDeviceResolution_iPhoneRetina6p ? 44 : 0;
        
        self.surfaceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-KBottomSafeHeight-topMargin)];
        self.surfaceImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.surfaceImageView.clipsToBounds = YES;
        [self addSubview:self.surfaceImageView];
        
        self.imageLayer = [CALayer layer];
        self.imageLayer.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-KBottomSafeHeight-topMargin);
        [self.layer addSublayer:self.imageLayer];
        
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-KBottomSafeHeight-topMargin);
        self.shapeLayer.lineCap = kCALineCapRound;
        self.shapeLayer.lineJoin = kCALineJoinRound;
        self.shapeLayer.lineWidth = 20;
        self.shapeLayer.strokeColor = [UIColor blueColor].CGColor;
        self.shapeLayer.fillColor = nil;//此处必须设为nil，否则后边添加addLine的时候会自动填充

        self.imageLayer.mask = self.shapeLayer;
        self.path = CGPathCreateMutable();
    }
    return self;
}

- (void)changeRectWithFrame:(CGRect)rect {
    self.frame = rect;
    self.surfaceImageView.frame = self.bounds;
    self.imageLayer.frame = self.bounds;
    self.shapeLayer.frame = self.bounds;
}

- (void)setMosaicImage:(UIImage *)mosaicImage{
    _mosaicImage = mosaicImage;
    self.imageLayer.contents = (id)mosaicImage.CGImage;
}

- (void)setSurfaceImage:(UIImage *)surfaceImage{
    _surfaceImage = surfaceImage;
    self.surfaceImageView.image = surfaceImage;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPathMoveToPoint(self.path, nil, point.x, point.y);
    self.shapeLayer.path = self.path;
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPathAddLineToPoint(self.path, nil, point.x, point.y);
    self.shapeLayer.path = self.path;
    
    self.XScratchViewDidMove(YES);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
}

- (void)recover{
    CGPathRelease(self.path);
    self.path = CGPathCreateMutable();
    self.shapeLayer.path = nil;
}

- (void)dealloc{
    if (self.path) {
        CGPathRelease(self.path);
    }
}


@end
