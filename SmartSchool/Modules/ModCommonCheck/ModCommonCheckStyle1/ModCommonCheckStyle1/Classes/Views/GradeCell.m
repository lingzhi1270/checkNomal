//
//  GradeCell.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/13.
//

#import "GradeCell.h"

@interface GradeCell()

@property (nonatomic ,strong)UIImageView *headImageView;

@property (nonatomic ,strong)UIButton *deductionButton;

@end

@implementation GradeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.headImageView = [[UIImageView alloc] init];
        self.headImageView.image = [UIImage imageNamed:@"typeTipIMGView" bundleName:@"ModCommonCheckStyle1"];
        self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
        [CONTENT_VIEW addSubview:self.headImageView];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.text = @"";
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        self.titleLabel.textColor = [UIColor colorFromHex:0x343434];
        [CONTENT_VIEW addSubview:self.titleLabel];
        
        self.deductionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.deductionButton setTitle:@"-" forState:UIControlStateNormal];
        [self.deductionButton setFont:[UIFont systemFontOfSize:16]];
        [self.deductionButton setBackgroundColor:[UIColor whiteColor]];
        [self.deductionButton setTitleColor:[UIColor colorAlphaFromHex:0x343434] forState:UIControlStateNormal];
        self.deductionButton.layer.borderWidth = 0.6;
        self.deductionButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.deductionButton.layer.cornerRadius = 2;
        self.deductionButton.layer.masksToBounds = YES;
        [self.deductionButton addTarget:self action:@selector(deductionButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [CONTENT_VIEW addSubview:self.deductionButton];
        
        self.gradeLabel = [UILabel new];
        self.gradeLabel.text = @"";
        self.gradeLabel.textAlignment = NSTextAlignmentCenter;
        self.gradeLabel.font = [UIFont systemFontOfSize:12];
        self.gradeLabel.textColor = [UIColor colorFromHex:0x343434];
        self.gradeLabel.layer.borderWidth = 0.6;
        self.gradeLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [CONTENT_VIEW addSubview:self.gradeLabel];
        
        self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.addButton setTitle:@"+" forState:UIControlStateNormal];
        [self.addButton setFont:[UIFont systemFontOfSize:16]];
        [self.addButton setBackgroundColor:[UIColor whiteColor]];
        [self.addButton setTitleColor:[UIColor colorAlphaFromHex:0x343434] forState:UIControlStateNormal];
        self.addButton.layer.borderWidth = 0.6;
        self.addButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.addButton.layer.cornerRadius = 2;
        self.addButton.layer.masksToBounds = YES;
        [self.addButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [CONTENT_VIEW addSubview:self.addButton];
        
        UIView *bottomLine = [UIView new];
        bottomLine.backgroundColor = [UIColor colorFromHex:0xDCDCDC];
        [CONTENT_VIEW addSubview:bottomLine];
        
        [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                   make.left.equalTo(CONTENT_VIEW.mas_left).offset(20);
                   make.centerY.equalTo(CONTENT_VIEW);
                   make.width.equalTo(@(18));
                   make.height.equalTo(@(18));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
              make.left.equalTo(self.headImageView.mas_right).offset(10);
              make.centerY.equalTo(self.headImageView);
              make.width.equalTo(@140);
              make.height.equalTo(@30);
        }];
        
        
        [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(CONTENT_VIEW.mas_right).offset(-20);
            make.centerY.equalTo(self.headImageView);
            make.width.height.equalTo(@26);
        
        }];
        
        [self.gradeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(CONTENT_VIEW.mas_right).offset(-46);
            make.centerY.equalTo(self.addButton);
            make.width.equalTo(@50);
            make.height.equalTo(@26);
        }];
        
        [self.deductionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.gradeLabel.mas_left);
            make.centerY.equalTo(self.addButton);
            make.width.height.equalTo(@26);
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

- (void)deductionButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickDeductionButton:)]) {
        [self.delegate clickDeductionButton:[(UITableView *)self.superview indexPathForCell:self]];
    }
}

- (void)addButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickAddButton:)]) {
           [self.delegate clickAddButton:[(UITableView *)self.superview indexPathForCell:self]];
       }
}
@end
