//
//  ProofCollectionItem.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/14.
//

#import "ProofCollectionItem.h"

@interface ProofCollectionItem()
///图片
@property (nonatomic, strong) UIImageView *iconImageView;
/** 删除按钮 */
@property (nonatomic, strong) UIButton *deleteButton;

/** 视频标志 */
@property (nonatomic, strong) UIImageView *videoImageView;

@end
@implementation ProofCollectionItem
- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
      self.backgroundColor = [UIColor whiteColor];
      
      self.iconImageView = [[UIImageView alloc] init];
      self.iconImageView.frame = self.bounds;
      self.iconImageView.clipsToBounds = YES;
      self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
      [self addSubview:self.iconImageView];

      self.deleteButton = [[UIButton alloc] init];
      self.deleteButton.hidden = YES;
      self.deleteButton.frame = CGRectMake(self.bounds.size.width - 12, 0, 12, 12);
      [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"deleteImage" bundleName:@"ModCommonCheckStyle1"] forState:UIControlStateNormal];
      [self.deleteButton addTarget:self action:@selector(clickDeleteButton) forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:self.deleteButton];
      
      self.videoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShowVideo" bundleName:@"ModCommonCheckStyle1"]];
      self.videoImageView.hidden = YES;
      self.videoImageView.frame = CGRectMake(self.bounds.size.width/4, self.bounds.size.width/4, self.bounds.size.width/2, self.bounds.size.width/2);
      [self addSubview:self.videoImageView];
   }
    return self;
}

#pragma mark - public methods

- (void)showIconWithUrlString: (NSString *)urlString image: (UIImage *)image
{
    if (urlString){
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:urlString]
                                        placeholderImage:nil
                                               completed:nil];
    }else if (image){
        self.iconImageView.image = image;
    }
}

- (void)deleteButtonWithImage: (UIImage *)deleteImage show: (BOOL)show
{
    if (deleteImage) {
        [self.deleteButton setBackgroundImage:deleteImage forState:UIControlStateNormal];
    }
    self.deleteButton.hidden = !show;
}

- (void)videoImage: (UIImage *)videoImage show: (BOOL)show
{
    if (videoImage) {
        self.videoImageView.image = videoImage;
    }
    self.videoImageView.hidden = !show;
}

- (void)clickDeleteButton {
    NSIndexPath *indexPath = [(UICollectionView *)self.superview indexPathForCell:self];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ClickCellDeleteButton:)]) {
        [self.delegate ClickCellDeleteButton:indexPath];
      }
}

@end
