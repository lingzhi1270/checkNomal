//
//  CollectionViewSectionHeaderView.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/8.
//

#import "CollectionViewSectionHeaderView.h"
#import <LibTheme/ThemeManager.h>
@interface CollectionViewSectionHeaderView ()
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UIImageView   *imageView;
@property (nonatomic, strong) UILabel       *tailLabel;

@end

@implementation CollectionViewSectionHeaderView

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = THEME_CONTENT_SEPARATOR_COLOR;
        
        self.titleLabel = [UILabel new];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        self.titleLabel.textColor = [UIColor colorFromHex:0x4561B1];
        [self addSubview:self.titleLabel];
        
        self.tailLabel = [UILabel new];
        self.tailLabel.font = [UIFont systemFontOfSize:12];
        self.tailLabel.text = @"";
        self.tailLabel.textColor = [UIColor colorFromHex:0xA6A6A6];
        [self addSubview:self.tailLabel];
    
        UIView *bottomBackView = [UIView new];
        [self addSubview:bottomBackView];
        
        UIView *bottomLine = [UIView new];
        bottomLine.backgroundColor = [UIColor colorFromHex:0xDCDCDC];
        [self addSubview:bottomLine];
           
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.centerY.equalTo(self.mas_centerY).offset(-8);
        }];
        
        [self.tailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-20);
            make.centerY.equalTo(self.titleLabel.mas_centerY);
        }];
        
        [bottomBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom);
            make.left.right.bottom.equalTo(self);
        }];
        
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.left.equalTo(self.mas_left).offset(20);
                 make.right.equalTo(self.mas_right).offset(-20);
                 
            make.centerY.equalTo(bottomBackView.mas_centerY);
                 make.height.equalTo(@0.8);
            }];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

- (void)setTailContent:(NSString *)tailContent
{
    _tailContent = tailContent;
    self.tailLabel.text = tailContent;
}


- (void)touchMore {
    [self.delegate moreButtonTouchedOfHeaderView:self];
}

@end
