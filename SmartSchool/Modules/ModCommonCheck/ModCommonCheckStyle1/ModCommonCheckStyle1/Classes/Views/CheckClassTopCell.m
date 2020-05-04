//
//  CheckClassTopCell.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/10.
//

#import "CheckClassTopCell.h"
#import <ModLoginBase/AccountManager.h>
@interface CheckClassTopCell()
@property (nonatomic, strong) UIImageView       *imageView;
@property (nonatomic, strong) UILabel           *cheackAdminLabel;
@property (nonatomic, strong) UILabel           *cheackTimeLabel;
@property (nonatomic, strong) UILabel           *cheackTailLabel;

@property (nonatomic, strong) UILabel           *cheackTipLabel;
@end
@implementation CheckClassTopCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor whiteColor];

    self.imageView = [UIImageView new];
    self.imageView.image = [UIImage imageNamed:@"checkClassTopImage" bundleName:@"ModCommonCheckStyle1"];
    self.imageView.layer.cornerRadius = 6;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
 
    [self addSubview:self.imageView];

    self.cheackAdminLabel = [UILabel new];
    self.cheackAdminLabel.textAlignment = NSTextAlignmentLeft;
    self.cheackAdminLabel.font = [UIFont systemFontOfSize:14];
    self.cheackAdminLabel.textColor = [UIColor whiteColor];
    self.cheackAdminLabel.text = [NSString stringWithFormat:@"检查人:%@",ACCOUNT_NAME];
    [self.imageView addSubview:self.cheackAdminLabel];
        
    self.cheackTimeLabel = [UILabel new];
    self.cheackTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.cheackTimeLabel.font = [UIFont systemFontOfSize:11];
    self.cheackTimeLabel.textColor = [UIColor whiteColor];
    self.cheackTimeLabel.text = [NSUserDefaults schoolCalendar];
    [self.imageView addSubview:self.cheackTimeLabel];
        
    self.cheackTailLabel = [UILabel new];
    self.cheackTailLabel.textAlignment = NSTextAlignmentRight;
    self.cheackTailLabel.font = [UIFont systemFontOfSize:11];
    self.cheackTailLabel.textColor = [UIColor whiteColor];
    self.cheackTailLabel.text = @"人工登记";
    [self.imageView addSubview:self.cheackTailLabel];
        
        
    self.cheackTipLabel = [UILabel new];
    self.cheackTipLabel.textAlignment = NSTextAlignmentCenter;
    self.cheackTipLabel.font = [UIFont systemFontOfSize:15];
    self.cheackTipLabel.textColor = [UIColor colorFromHex:0x343434];
    self.cheackTipLabel.text = @"请选择所在年级";
    [self addSubview:self.cheackTipLabel];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(20);
        make.left.equalTo(self.mas_left).offset(20);
        make.right.equalTo(self.mas_right).offset(-20);
        make.height.equalTo(@80);
    }];
        
    [self.cheackAdminLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView.mas_left).offset(30);
        make.centerY.equalTo(self.imageView.mas_centerY).offset(-15);
    }];
        
    [self.cheackTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.equalTo(self.imageView.mas_left).offset(30);
       make.centerY.equalTo(self.imageView.mas_centerY).offset(18);
    }];
        
    [self.cheackTailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.imageView.mas_right).offset(-15);
        make.centerY.equalTo(self.imageView);
    }];
    
    [self.cheackTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).offset(35);
        make.left.right.bottom.equalTo(self);
    }];
    }
    return self;
}

@end
