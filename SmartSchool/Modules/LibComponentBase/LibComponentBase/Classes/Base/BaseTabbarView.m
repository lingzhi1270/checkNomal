//
//  BaseTabbarView.m
//  XNN
//
//  Created by tangqi on 2018/11/6.
//  Copyright © 2018 VIROYAL. All rights reserved.
//

#import "BaseTabbarView.h"
#import "VoiceHud.h"
#import <AVFoundation/AVFAudio.h>

@interface BaseTabbarModel ()
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *selectedImage;

@end

@implementation BaseTabbarModel

+ (instancetype)allocWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    return [[BaseTabbarModel alloc] initWithTitle:title image:image selectedImage:selectedImage];
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    if (self = [super init]) {
        self.titleStr = title;
        self.image = image;
        self.selectedImage = selectedImage;
    }
    
    return self;
}

@end

@interface BaseTabbarItem ()
@property (nonatomic, strong) VoiceHud      *hud;

@end

@implementation BaseTabbarItem

- (instancetype)init {
    if (self = [super init]) {
        self.hudBackgroundColor = [UIColor blackColor];
        self.hudTintColor = [UIColor whiteColor];
        
        self.iconImageView = [[UIImageView alloc] init];
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.iconImageView];
        
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.font = [UIFont systemFontOfSize:10];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textLabel];
        
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5.5);
            make.centerX.equalTo(self);
        }];
        
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-1);
            make.centerX.equalTo(self);
        }];
        
        self.rec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
        self.rec.minimumPressDuration = .0;
        self.rec.delegate = self;
        [self addGestureRecognizer:self.rec];
    }
    
    return self;
}

- (void)setModel:(BaseTabbarModel *)model {
    _model = model;
    
    self.textLabel.text = model.titleStr;
    self.iconImageView.image = model.image;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.textLabel.textColor = [UIColor colorWithRGB:0x4561B1];
        self.iconImageView.image = self.model.selectedImage;
    }else {
        self.textLabel.textColor = [UIColor whiteColor];
        self.iconImageView.image = self.model.image;
    }
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)rec {
    AVAudioSessionRecordPermission permission = [AVAudioSession sharedInstance].recordPermission;
    
    if (rec.state == UIGestureRecognizerStateBegan) {
        if (permission == AVAudioSessionRecordPermissionUndetermined) {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (granted) {
                    
                }
            }];
        }
        else if (permission == AVAudioSessionRecordPermissionDenied) {
            
        }
        else {
            self.state = BaseTabbarItemPushInside;
            [self.delegate baseTabbarItemTouchDown:self];
        }
    }
    else if (rec.state == UIGestureRecognizerStateEnded) {
        if (permission == AVAudioSessionRecordPermissionGranted) {
            CGPoint pt = [rec locationInView:self];
            BOOL inside = CGRectContainsPoint(self.bounds, pt);
            if (inside) {
                self.state = BaseTabbarItemNormal;
                [self.delegate baseTabbarItemTouchUpInside:self];
            }
            else {
                self.state = BaseTabbarItemNormal;
                [self.delegate baseTabbarItemTouchUpOutside:self];
            }
        }
    }
    else if (rec.state == UIGestureRecognizerStateChanged) {
        CGPoint pt = [rec locationInView:self];
        BOOL inside = CGRectContainsPoint(self.bounds, pt);
        
        self.state = inside ? BaseTabbarItemPushInside : BaseTabbarItemPushOutside;
    }
    else {
        self.state = BaseTabbarItemNormal;
        [self.delegate baseTabbarItemTouchUpOutside:self];
    }
}

- (void)setState:(BaseTabbarItemState)state {
    _state = state;
    switch (state) {
        case BaseTabbarItemPushInside: {
            if (!self.hud) {
                self.hud = [VoiceHud new];
                [[UIApplication sharedApplication].keyWindow addSubview:self.hud];
                [self.hud mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.center.equalTo([UIApplication sharedApplication].keyWindow);
                }];
                
                self.hud.backgroundColor = self.hudBackgroundColor;
                self.hud.tintColor = self.hudTintColor;
            }
            
            self.hud.title = @"持续识别中...";
        }
            break;
            
        case BaseTabbarItemPushOutside: {
            self.hud.title = @"手指松开，取消识别";
        }
            break;
            
        default: {
            if (self.hud) {
                [self.hud removeFromSuperview];
                self.hud = nil;
            }
        }
            break;
    }
}

- (void)setMeter:(CGFloat)meter {
    self.hud.meter = meter;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end

@interface BaseTabbarView ()
@property (nonatomic, strong) UIImageView    *bgImageView;
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) BaseTabbarItem *currentItem;

@end

@implementation BaseTabbarView

- (instancetype)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        self.buttonArray = [NSMutableArray new];
        
        self.bgImageView = [[UIImageView alloc] init];
        self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.bgImageView.clipsToBounds = YES;
        [self addSubview:self.bgImageView];
        
        [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        CGFloat margin = 4.f;
        CGFloat width = (SCREENWIDTH-margin*(array.count-1))/array.count;
                        
        for (BaseTabbarModel *model in array) {
            BaseTabbarItem *item = [[BaseTabbarItem alloc] init];
            item.model = model;
            [self addSubview:item];
            [self.buttonArray addObject:item];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonClick:)];
            [item addGestureRecognizer:tap];
            
            NSInteger index = [array indexOfObject:model];
            [item removeGestureRecognizer:item.rec];
            
            [item mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self);
                make.left.equalTo(self).offset(+(width+margin)*index);
                make.width.equalTo(@(width));
                make.height.equalTo(@kTabbarHeight);
            }];
            
            if (index == 0) {
                item.selected = YES;
                self.currentItem = item;
            }
        }
        
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.backgroundColor = [UIColor colorWithRGB:0xB8B8B8];
        [self addSubview:lineImageView];
        
        [lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.equalTo(@0.5);
        }];
    }
    
    return self;
}

- (void)configureBackgroundImage:(UIImage *)bgImage {
    self.bgImageView.image = bgImage;
}

- (void)buttonClick:(UITapGestureRecognizer *)rec {
    BaseTabbarItem *item = (BaseTabbarItem *)rec.view;
    if (item.selected) {
        return;
    }

    self.currentItem.selected = NO;
    item.selected = YES;
    self.currentItem = item;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabbarButtonClick:)]) {
        [self.delegate tabbarButtonClick:[self.buttonArray indexOfObject:item]];
    }
}

@end
