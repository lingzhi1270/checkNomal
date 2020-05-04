//
//  CommonCheckResultCell.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/9.
//

#import "CommonCheckResultCell.h"

@interface CommonCheckResultCell()
@property (nonatomic, strong)UIImageView        *iconImageView;

@property (nonatomic, strong)UILabel            *tailTipLabel;

@property (nonatomic, strong)UIImageView        *tailImageView;
@end

@implementation CommonCheckResultCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
          self.backgroundColor = [UIColor clearColor];
          self.selectionStyle = UITableViewCellSelectionStyleNone;
          self.iconImageView = [[UIImageView alloc] init];
          self.iconImageView.image = [UIImage imageNamed:@"typeTipIMGView" bundleName:@"ModCommonCheckStyle1"];
          self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
          [CONTENT_VIEW addSubview:self.iconImageView];
              
          self.contentLabel = [UILabel new];
          self.contentLabel.text = @"";
          self.contentLabel.font = [UIFont systemFontOfSize:12];
          self.contentLabel.textColor = [UIColor colorFromHex:0x343434];
          [CONTENT_VIEW addSubview:self.contentLabel];
              
          self.tailTipLabel = [UILabel new];
          self.tailTipLabel.text = @"查看分数";
          self.tailTipLabel.textAlignment = NSTextAlignmentRight;
          self.tailTipLabel.font = [UIFont systemFontOfSize:11];
          self.tailTipLabel.textColor = [UIColor colorFromHex:0xA6A6A6];
          [CONTENT_VIEW addSubview:self.tailTipLabel];
              
          self.tailImageView = [[UIImageView alloc] init];
          self.tailImageView.image = [UIImage imageNamed:@"tailIMGView" bundleName:@"ModCommonCheckStyle1"];
          [CONTENT_VIEW addSubview:self.tailImageView];
              
          UIView *bottomLine = [UIView new];
          bottomLine.backgroundColor = [UIColor colorFromHex:0xDCDCDC];
          [CONTENT_VIEW addSubview:bottomLine];
              
          [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
              make.left.equalTo(CONTENT_VIEW.mas_left).offset(20);
              make.centerY.equalTo(CONTENT_VIEW);
              make.width.equalTo(@(18));
              make.height.equalTo(@(18));
              
          }];
              
          [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
              make.left.equalTo(self.iconImageView.mas_right).offset(10);
              make.centerY.equalTo(self.iconImageView);
              make.width.equalTo(@140);
              make.height.equalTo(@30);
          }];
              
          [self.tailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
              make.right.equalTo(CONTENT_VIEW.mas_right).offset(-15);
              make.centerY.equalTo(self.iconImageView);
              make.width.height.equalTo(@9);
          }];
              
          [self.tailTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
              make.right.equalTo(self.tailImageView.mas_left).offset(-10);
              make.centerY.equalTo(self.iconImageView);
              make.width.equalTo(@80);
              make.height.equalTo(@30);
          }];

          [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
                   make.left.equalTo(CONTENT_VIEW.mas_left).offset(20);
                   make.right.equalTo(CONTENT_VIEW);
                   make.bottom.equalTo(CONTENT_VIEW.mas_bottom).offset(-0.8);
                   make.height.equalTo(@0.8);
          }];
          }
          return self;
}

@end
