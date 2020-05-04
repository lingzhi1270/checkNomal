//
//  ContactCell.m
//  Unilife
//
//  Created by zhangliyong on 2019/10/9.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ContactCell.h"
#import <ModContactBase/ContactManager.h>

@interface ContactCell ()

@property (nonatomic, strong) UIImageView   *iconView;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel       *statusLabel;

@end

@implementation ContactCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.iconView = [[UIImageView alloc] init];
        [CONTENT_VIEW addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(16);
            make.top.equalTo(CONTENT_VIEW).offset(8);
            make.bottom.equalTo(CONTENT_VIEW).offset(-8);
            make.width.equalTo(self.iconView.mas_height);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:17];
        self.nameLabel.textColor = [UIColor blackColor];
        [CONTENT_VIEW addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(16);
            make.centerY.equalTo(CONTENT_VIEW);
        }];
        
        self.statusLabel = [[UILabel alloc] init];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        [CONTENT_VIEW addSubview:self.statusLabel];
        [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_right).offset(8);
            make.right.equalTo(CONTENT_VIEW).offset(-16);
            make.centerY.equalTo(CONTENT_VIEW);
        }];
    }
    
    return self;
}

- (void)setContact:(ContactData *)contact {
    _contact = contact;
    
    [self.iconView setImageWithURL:[NSURL URLWithString:contact.avatarUrl]
                           options:YYWebImageOptionProgressiveBlur];
    if (contact.section == 3) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.nameLabel.attributedText = [NSAttributedString attributedStringWithStrings:contact.title?:@"", [UIFont systemFontOfSize:17], [UIColor blackColor], nil];
        self.statusLabel.attributedText = nil;
    }
    else {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.nameLabel.text = contact.title;
        
        ContactStatusData *data = [[ContactManager shareManager] statusWithUid:contact.status];
        NSString *string = [NSString stringWithFormat:@"[%@]", data.title?:@"未知"];
        self.statusLabel.attributedText = [NSAttributedString attributedStringWithStrings:string, [UIFont systemFontOfSize:13], data.color, nil];
        [self.statusLabel sizeToFit];
    }
    
    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetMinX(self.nameLabel.frame), 0, 0);
}

@end
