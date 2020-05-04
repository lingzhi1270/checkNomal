//
//  CheckCenterCell.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/8.
//

#import "CheckCenterCell.h"

@interface CheckCenterCell()
@property (nonatomic, strong) UIImageView       *imageView;
@property (nonatomic, strong) UILabel           *teacherNameLabel;
@property (nonatomic, strong) UIButton          *checkResultButton;
@end

@implementation CheckCenterCell
- (instancetype)initWithFrame:(CGRect)frame {
   if (self = [super initWithFrame:frame]) {
       self.backgroundColor = [UIColor whiteColor];
       self.imageView = [UIImageView new];
       self.imageView.layer.cornerRadius = 6;
       self.imageView.layer.masksToBounds = YES;
       self.imageView.userInteractionEnabled = YES;
       self.imageView.image = [UIImage imageNamed:@"checkCenterBgImage" bundleName:@"ModCommonCheckStyle1"];
       self.imageView.contentMode = UIViewContentModeScaleAspectFill;
       self.imageView.layer.masksToBounds = YES;
       [CONTENT_VIEW addSubview:self.imageView];
       
    
       self.teacherNameLabel = [UILabel new];
       self.teacherNameLabel.textAlignment = NSTextAlignmentRight;
       self.teacherNameLabel.font = [UIFont systemFontOfSize:13];
       self.teacherNameLabel.textColor = [UIColor whiteColor];
       [self.imageView addSubview:self.teacherNameLabel];
       
       self.checkResultButton = [UIButton buttonWithType:UIButtonTypeCustom];
       self.checkResultButton.backgroundColor = [UIColor whiteColor];
       self.checkResultButton.layer.cornerRadius = 6;
       self.checkResultButton.layer.masksToBounds = YES;
       [self.checkResultButton setTitle:@"  查看检查结果  " forState:UIControlStateNormal];
       [self.checkResultButton setFont:[UIFont systemFontOfSize:13]];
       [self.checkResultButton setTitleColor:  [UIColor colorFromHex:0x4561B1] forState:UIControlStateNormal];
       [self.checkResultButton addTarget:self action:@selector(checkResultButtonAction) forControlEvents:UIControlEventTouchUpInside];
       [self.imageView addSubview:self.checkResultButton];
    
       [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(CONTENT_VIEW.mas_left).offset(20);
           make.right.equalTo(CONTENT_VIEW.mas_right).offset(-20);
           make.top.equalTo(CONTENT_VIEW.mas_top).offset(18);
           make.bottom.equalTo(CONTENT_VIEW.mas_bottom).offset(-18);
           
       }];
       
       [self.teacherNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           make.centerY.equalTo(self.imageView);
           make.right.equalTo(self.imageView.mas_centerX);
       }];
       
       [self.checkResultButton mas_makeConstraints:^(MASConstraintMaker *make) {
           make.centerY.equalTo(self.imageView);
           make.left.equalTo(self.imageView.mas_centerX).offset(15);
       }];
    
  }
    return self;
}
        
- (void)checkResultButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(checkResultButtonClick)]) {
        [self.delegate checkResultButtonClick];
    }
}

- (void)setTeacherName:(NSString *)teacherName
{
    _teacherName = teacherName;
    self.teacherNameLabel.text = teacherName;
}
@end
