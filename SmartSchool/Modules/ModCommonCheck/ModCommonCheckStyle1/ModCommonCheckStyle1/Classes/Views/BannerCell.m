//
//  BannerCell.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/8.
//

#import "BannerCell.h"

@interface BannerCell()
@property (nonatomic, strong) UIImageView       *imageView;

@end

@implementation BannerCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor whiteColor];

    self.imageView = [UIImageView new];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.layer.cornerRadius = 6;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.image = [UIImage imageNamed:@"CommonCheck_TopImage" bundleName:@"ModCommonCheckStyle1"];
    
    [CONTENT_VIEW addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(CONTENT_VIEW.mas_left).offset(20);
        make.top.equalTo(CONTENT_VIEW.mas_top).offset(10);
        make.right.equalTo(CONTENT_VIEW.mas_right).offset(-20);
        make.bottom.equalTo(CONTENT_VIEW.mas_bottom);
    }];
    }
    return self;
}

@end
