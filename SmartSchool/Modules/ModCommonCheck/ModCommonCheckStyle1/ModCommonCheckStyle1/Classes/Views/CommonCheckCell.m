//
//  CommonCheckCell.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/7.
//

#import "CommonCheckCell.h"

@interface CommonCheckCell()
@property (nonatomic, strong) UIImageView       *imageView;

@end
@implementation CommonCheckCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor clearColor];
    self.imageView = [UIImageView new];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.layer.cornerRadius = 6;
    self.imageView.layer.masksToBounds = YES;
    [CONTENT_VIEW addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(CONTENT_VIEW);
    }];
    }
    return self;
}

- (void)setCheckData:(CommonCheckData *)checkData
{
    _checkData = checkData;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:checkData.image_url]];
    
}
@end
