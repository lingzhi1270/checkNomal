//
//  EditorColorPan.m
//  Conversation
//
//  Created by 唐琦 on 2019/5/29.
//

#import "EditorColorPan.h"
#import "ColorfullButton.h"

NSString * const kColorPanNotificaiton = @"kColorPanNotificaiton";

@interface EditorColorPan ()
@property (nonatomic, strong) UIColor *currentColor;
@property (nonatomic, strong) NSMutableArray<ColorfullButton *> *colorButtons;

@property (nonatomic, strong) ColorfullButton *redButton;
@property (nonatomic, strong) ColorfullButton *orangeButton;
@property (nonatomic, strong) ColorfullButton *yellowButton;
@property (nonatomic, strong) ColorfullButton *greenButton;
@property (nonatomic, strong) ColorfullButton *blueButton;
@property (nonatomic, strong) ColorfullButton *pinkButton;
@property (nonatomic, strong) ColorfullButton *whiteButton;

@end

@implementation EditorColorPan

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.currentColor = [UIColor redColor];
        self.colorButtons = [NSMutableArray arrayWithCapacity:0];
        
        NSArray *colorArray = @[[UIColor colorWithRGB:0xFF2600],
                                [UIColor colorWithRGB:0xFF9300],
                                [UIColor colorWithRGB:0xFFFB00],
                                [UIColor colorWithRGB:0x00F900],
                                [UIColor colorWithRGB:0x16A2FF],
                                [UIColor colorWithRGB:0xFE497C],
                                [UIColor colorWithRGB:0xFFFFFF]];
        
        for (int i = 0; i < 7; i++) {
            ColorfullButton *button = [[ColorfullButton alloc] initWithFrame:CGRectMake(0, 30*i, 30, 30)];
            button.radius = 9;
            button.color = colorArray[i];
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            [self.colorButtons addObject:button];
            
            if (i == 0) {
                [button sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    return self;
}

- (void)buttonAction:(ColorfullButton *)sender {
    for (ColorfullButton *button in self.colorButtons) {
        if (button == sender) {
            button.isUse = YES;
            self.currentColor = sender.color;
            [[NSNotificationCenter defaultCenter] postNotificationName:kColorPanNotificaiton object:self.currentColor];
        }
        else {
            button.isUse = NO;
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSLog(@"point: %@", NSStringFromCGPoint([touch locationInView:self]));
    NSLog(@"view=%@", touch.view);
    CGPoint touchPoint = [touch locationInView:self];
    for (ColorfullButton *button in _colorButtons) {
        CGRect rect = [button convertRect:button.bounds toView:self];
        if (CGRectContainsPoint(rect, touchPoint) && button.isUse == NO) {
            [self buttonAction:button];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    //NSLog(@"move->point: %@", NSStringFromCGPoint([touch locationInView:self]));
    CGPoint touchPoint = [touch locationInView:self];
    
    for (ColorfullButton *button in _colorButtons) {
        CGRect rect = [button convertRect:button.bounds toView:self];
        if (CGRectContainsPoint(rect, touchPoint) && button.isUse == NO) {
            [self buttonAction:button];
        }
    }
}

@end
