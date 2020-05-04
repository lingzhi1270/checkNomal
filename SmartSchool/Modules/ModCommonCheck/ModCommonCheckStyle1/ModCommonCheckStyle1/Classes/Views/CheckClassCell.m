//
//  CheckClassCell.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/10.
//

#import "CheckClassCell.h"

@interface CheckClassCell()
@property (nonatomic, strong)UILabel *calssNameLabel;

@end

@implementation CheckClassCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor clearColor];
    self.calssNameLabel = [UILabel new];
    self.calssNameLabel.textColor = [UIColor colorFromHex:0x4D7BFD];
    self.calssNameLabel.textAlignment = NSTextAlignmentCenter;
    self.calssNameLabel.font = [UIFont systemFontOfSize:12];
    self.calssNameLabel.layer.borderWidth = 0.8;
    self.calssNameLabel.layer.borderColor = [UIColor colorFromHex:0x4D7BFD].CGColor;
    self.calssNameLabel.layer.cornerRadius = 4;
    self.calssNameLabel.layer.masksToBounds = YES;
    [self addSubview:self.calssNameLabel];
    [self.calssNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    }
    return self;
}

- (void)setClassNameTitle:(NSString *)classNameTitle
{
    _classNameTitle = classNameTitle;
    self.calssNameLabel.text = classNameTitle;
}
@end
