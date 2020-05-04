//
//  ModLoginStyle1LoginPageView.m
//  Unilife
//
//  Created by 唐琦 on 2019/6/24.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ModLoginStyle1LoginPageView.h"

@implementation LoginStyle2PageItem

+ (instancetype)itemWithType:(LoginAccountType)type title:(NSString *)title {
    return [[LoginStyle2PageItem alloc] initWithType:type title:title];
}

- (instancetype)initWithType:(LoginAccountType)type title:(NSString *)title {
    if (self = [super init]) {
        self.type = type;
        self.title = title;
    }
    
    return self;
}

@end

@interface ModLoginStyle1LoginPageView ()
@property (nonatomic, assign) NSInteger                     selectedIndex;
@property (nonatomic, strong) NSMutableArray<UIButton *>    *btns;
@property (nonatomic, strong) UIView                        *lineView;
@property (nonatomic, strong) NSArray<LoginStyle2PageItem *>      *items;
@property (nonatomic, strong) UIImageView *bottomLineView;

@end

@implementation ModLoginStyle1LoginPageView

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray<LoginStyle2PageItem *> *)items {
    if (self = [super initWithFrame:frame]) {
        self.items = items;
        
        self.btns = [NSMutableArray array];
        _selectedIndex = -1;
        UIButton *pre = nil;
        for (LoginStyle2PageItem *item in items) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.layer.shadowColor = [UIColor lightGrayColor].CGColor;
            btn.layer.shadowOffset = CGSizeMake(0, 0);
            btn.layer.shadowOpacity = .8;
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            [btn addTarget:self action:@selector(touchOnItem:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:item.title forState:UIControlStateNormal];
            
            [self addSubview:btn];
            [self.btns addObject:btn];
            
            if (!pre) {
                //这是第一个
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self);
                    make.top.equalTo(self);
                    make.bottom.equalTo(self).offset(-4);
                }];
                
                pre = btn;
            }
            else {
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(pre.mas_right).offset(8);
                    make.width.equalTo(pre);
                    make.top.equalTo(pre);
                    make.bottom.equalTo(pre);
                }];
            }
            
            if (item == items.lastObject) {
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self);
                }];
            }
        }
        
        self.bottomLineView = [[UIImageView alloc] init];
        self.bottomLineView.backgroundColor = MAIN_COLOR;
        [self addSubview:self.bottomLineView];
        
        [self.bottomLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(pre);
            make.height.equalTo(@2);
        }];
    }
    
    return self;
}

- (void)setSelectedType:(LoginAccountType)selectedType {
    _selectedType = selectedType;
    
    for (int i = 0; i < self.items.count; i++) {
        LoginStyle2PageItem *item = self.items[i];
        if (item.type == selectedType) {
            [self setSelectedIndex:i];
            break;
        }
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    if (_selectedIndex == selectedIndex) {
        return;
    }
    
    _selectedIndex = selectedIndex;
    [self.delegate loginStyleSelected:self.items[selectedIndex].type];
    
    if (!self.lineView) {
        self.lineView = [UIView new];
        self.lineView.backgroundColor = self.tintColor;
        [self addSubview:self.lineView];
    }
    
    for (NSInteger index = 0; index < self.btns.count; index++) {
        UIButton *btn = self.btns[index];
        
        if (index == selectedIndex) {
            [btn setTitleColor:self.tintColor forState:UIControlStateNormal];
            [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(btn.titleLabel);
                make.right.equalTo(btn.titleLabel);
                make.centerY.equalTo(self.bottomLineView);
                make.height.equalTo(@4);
            }];
        }
        else {
            [btn setTitleColor:[UIColor colorWithRGB:0x333333] forState:UIControlStateNormal];
        }
    }
    
    if (animated) {
        [UIView animateWithDuration:.3
                         animations:^{
                             [self layoutIfNeeded];
                         }
                         completion:nil];
    }
}

- (void)touchOnItem:(UIButton *)sender {
    NSInteger index = [self.btns indexOfObject:sender];
    if (index != NSNotFound && index != self.selectedIndex) {
        [self setSelectedIndex:index animated:YES];
    }
}

@end
