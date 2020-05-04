//
//  AccountCell.m
//  Unilife
//
//  Created by 唐琦 on 2019/6/21.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "AccountCell.h"
#import <LibTheme/ThemeManager.h>

@interface AccountView ()

@property (nonatomic, strong) UIImageView   *avatarView;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel       *detailLabel;

@end

@implementation AccountView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.avatarView = [[UIImageView alloc] init];
        
        [self addSubview:self.avatarView];
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.height.equalTo(@68);
            make.width.equalTo(self.avatarView.mas_height);
        }];
        
        CALayer *layer = self.avatarView.layer;
        layer.cornerRadius = 8;
        layer.masksToBounds = YES;
        layer.borderColor = [UIColor lightGrayColor].CGColor;
        layer.borderWidth = .5;
        
        self.nameLabel = [UILabel new];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:15];
        [self addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarView.mas_right).offset(8);
            make.right.lessThanOrEqualTo(self.mas_right);
            make.bottom.equalTo(self.mas_centerY);
        }];
        
        self.detailLabel = [UILabel new];
        self.detailLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.detailLabel];
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel);
            make.right.lessThanOrEqualTo(self.mas_right).offset(-8);
            make.top.equalTo(self.mas_centerY).offset(8);
        }];
    }
    
    return self;
}

- (void)setUser:(UserData *)user {
    UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:user.avatarUrl];
    if (image) {
        self.avatarView.image = image;
    }
    else {
        self.avatarView.image = [[UIImage imageNamed:@"ic_user_default_avatar"] imageMaskedWithColor:THEME_BUTTON_BACKGROUND_COLOR];
        if (user.avatarUrl.length) {
            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:user.avatarUrl]
                                                        options:0
                                                       progress:nil
                                                      completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                          [self.avatarView setImage:image fade:YES];
                                                      }];
        }
    }
    
    self.nameLabel.text = user?user.nickname:@"欢迎你";
    self.detailLabel.text = user?user.school:@"请轻触登录";
}

- (void)setPrimaryColor:(UIColor *)primaryColor color:(UIColor *)secondaryColor {
    self.nameLabel.textColor = primaryColor;
    self.detailLabel.textColor = secondaryColor;
}

@end

@interface AccountCell ()

@property (nonatomic, strong) AccountView   *accountView;

@end

@implementation AccountCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accountView = [[AccountView alloc] init];
        [CONTENT_VIEW addSubview:self.accountView];
        [self.accountView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(16);
            make.top.equalTo(CONTENT_VIEW).offset(16);
            make.right.equalTo(CONTENT_VIEW).offset(-16);
            make.bottom.equalTo(CONTENT_VIEW).offset(-16);
        }];
    }
    
    return self;
}

- (void)setUser:(UserData *)user {
    self.accountView.user = user;
}

- (void)setPrimaryColor:(UIColor *)primaryColor color:(UIColor *)secondaryColor {
    [self.accountView setPrimaryColor:primaryColor color:secondaryColor];
}

@end
