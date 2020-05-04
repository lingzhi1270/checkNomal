//
//  ModContactStyle1AccountCell.m
//  Pods
//
//  Created by 唐琦 on 2019/12/30.
//

#import "ModContactStyle1AccountCell.h"
#import <LibTheme/ThemeManager.h>

@interface ModContactStyle1AccountCell ()
@property (nonatomic, strong) UIImageView   *avatarView;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel       *detailLabel;
@end

@implementation ModContactStyle1AccountCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.avatarView = [[UIImageView alloc] init];
        self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
        self.avatarView.clipsToBounds = YES;
        [CONTENT_VIEW addSubview:self.avatarView];
        
        CALayer *layer = self.avatarView.layer;
        layer.cornerRadius = 8;
        layer.masksToBounds = YES;
        layer.borderColor = [UIColor lightGrayColor].CGColor;
        layer.borderWidth = .5;
        
        self.nameLabel = [UILabel new];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:15];
        [CONTENT_VIEW addSubview:self.nameLabel];
        
        self.detailLabel = [UILabel new];
        self.detailLabel.font = [UIFont systemFontOfSize:14];
        [CONTENT_VIEW addSubview:self.detailLabel];
        
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(16);
            make.top.equalTo(CONTENT_VIEW).offset(16);
            make.bottom.equalTo(CONTENT_VIEW).offset(-16);
            make.size.equalTo(@(CGSizeMake(68.f, 68.f)));
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarView.mas_right).offset(8);
            make.right.lessThanOrEqualTo(CONTENT_VIEW).offset(-16);
            make.bottom.equalTo(CONTENT_VIEW.mas_centerY);
        }];
        
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel);
            make.right.lessThanOrEqualTo(CONTENT_VIEW.mas_right).offset(-8-16);
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
