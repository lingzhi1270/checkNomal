//
//  UserCenterStyle1SectionHeaderView.m
//  Unilife
//
//  Created by 唐琦 on 2019/6/29.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "UserCenterStyle1SectionHeaderView.h"
#import <LibTheme/ThemeManager.h>

@interface UserCenterStyle1SectionHeaderView ()

@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UIImageView   *imageView;

@property (nonatomic, strong) UIView        *moreView;

@end

@implementation UserCenterStyle1SectionHeaderView

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRGB:0xAEAEAE];
        
        self.imageView = [UIImageView new];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(8);
            make.top.equalTo(self).offset(8);
            make.bottom.equalTo(self).offset(-8);
        }];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = THEME_TEXT_PRIMARY_COLOR;
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imageView.mas_right).offset(8);
            make.centerY.equalTo(self);
            make.right.lessThanOrEqualTo(self);
        }];
        
        self.moreView = [UIView new];
        [self addSubview:self.moreView];
        [self.moreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-16);
        }];
        
        UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        moreBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
        [moreBtn addTarget:self
                    action:@selector(touchMore)
          forControlEvents:UIControlEventTouchUpInside];
        
        [moreBtn setTitleColor:THEME_TEXT_PRIMARY_COLOR forState:UIControlStateNormal];
        [self.moreView addSubview:moreBtn];
        [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.moreView);
            make.bottom.equalTo(self.moreView);
            make.left.equalTo(self.moreView);
        }];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_indicator_right"]];
        [self.moreView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(moreBtn.mas_right).offset(4);
            make.right.equalTo(self.moreView);
            make.centerY.equalTo(moreBtn);
        }];
    }
    
    return self;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

- (void)setMore:(BOOL)more {
    self.moreView.hidden = !more;
}

- (void)touchMore {
    [self.delegate moreButtonTouchedOfHeaderView:self];
}

@end
