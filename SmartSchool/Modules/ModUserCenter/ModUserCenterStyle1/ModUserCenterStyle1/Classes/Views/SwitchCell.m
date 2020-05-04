//
//  SwitchCell.m
//  Unilife
//
//  Created by 唐琦 on 2019/8/18.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "SwitchCell.h"

@interface SwitchCell ()

@property (nonatomic, strong) UISwitch      *onoff;

@end

@implementation SwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.onoff = [[UISwitch alloc] init];
        [self.onoff addTarget:self
                       action:@selector(touchSwitchBtn:)
             forControlEvents:UIControlEventValueChanged];
        
        [CONTENT_VIEW addSubview:self.onoff];
        [self.onoff mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(CONTENT_VIEW).offset(-16);
            make.centerY.equalTo(CONTENT_VIEW);
        }];
    }
    
    return self;
}

- (void)setOn:(BOOL)on {
    self.onoff.on = on;
}

- (void)touchSwitchBtn:(UISwitch *)sender {
    [self.delegate switchCell:self switched:sender.on];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [CONTENT_VIEW bringSubviewToFront:self.onoff];
}

@end
