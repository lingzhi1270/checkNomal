//
//  CheckClassCollectionViewSectionHeaderView.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/13.
//

#import "CheckClassCollectionViewSectionHeaderView.h"
#import <LibTheme/ThemeManager.h>

@interface CheckClassCollectionViewSectionHeaderView()
@property (nonatomic, strong) UILabel       *titleLabel;

@end
@implementation CheckClassCollectionViewSectionHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
   if (self = [super initWithFrame:frame]) {
    self.backgroundColor = THEME_CONTENT_SEPARATOR_COLOR;
    
    self.titleLabel = [UILabel new];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.textColor = [UIColor colorFromHex:0x909090];
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(20);
                make.centerY.equalTo(self.mas_centerY);
    }];
   }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}
@end
