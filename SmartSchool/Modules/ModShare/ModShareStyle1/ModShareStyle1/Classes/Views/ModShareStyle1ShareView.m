//
//  ModShareStyle1ShareView.m
//  Dreamedu
//
//  Created by 唐琦 on 2019/3/15.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ModShareStyle1ShareView.h"
#import <LibDataModel/ShareModel.h>
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>

@interface ModShareStyle1ShareCell : UICollectionViewCell

+ (NSString *)reuseIdentifier;

@property (nonatomic, strong) UIImageView       *imageView;
@property (nonatomic, strong) UILabel           *titleLabel;

@property (nonatomic, strong) ShareTarget       *target;

@end

@implementation ModShareStyle1ShareCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = [UIColor grayColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-8);
            make.height.equalTo(@24);
        }];
        
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_share_qq"]];
        self.imageView.backgroundColor = [UIColor whiteColor];
        self.imageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(8);
            make.bottom.equalTo(self.titleLabel.mas_top).offset(-8);
            make.width.equalTo(self.imageView.mas_height);
            make.centerX.equalTo(self.contentView);
        }];
        
        CALayer *layer = self.imageView.layer;
        layer.cornerRadius = 8;
        layer.masksToBounds = YES;
    }
    
    return self;
}

- (void)setTarget:(ShareTarget *)target {
    _target = target;
    
    self.imageView.image = target.image;
    self.titleLabel.text = target.title;
}

@end

#pragma mark - ModShareStyle1ShareView
@interface ModShareStyle1ShareView () < UICollectionViewDataSource, UICollectionViewDelegateFlowLayout >
@property (nonatomic, strong) UIView                *contentView;
@property (nonatomic, strong) UIView                *backgroundView;
@property (nonatomic, strong) NSMutableArray        *shareTargets;
@property (nonatomic, strong) NSMutableArray        *extraTargets;

@property (nonatomic, strong) ShareObject           *object;

@property (nonatomic, strong) UICollectionView      *collectionViewMain;
@property (nonatomic, strong) UICollectionView      *collectionViewExtra;
@property (nonatomic, strong) UIButton              *btnCancel;

@end

@implementation ModShareStyle1ShareView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.shareTargets = [NSMutableArray arrayWithCapacity:0];
        self.extraTargets = [NSMutableArray arrayWithCapacity:0];
    }
    
    return self;
}

- (void)configureWithSuperview:(UIView *)superview
                        object:(ShareObject *)object
                  extraTargets:(NSArray *)extraTargets {
    
    [self.shareTargets removeAllObjects];
    [self.extraTargets removeAllObjects];
        
    self.object = object;    
    
    if ([WXApi isWXAppInstalled]) {
        [self.shareTargets addObjectsFromArray:@[[ShareTarget targetWithImage:[UIImage imageNamed:@"icon_share_wechat_friends"
                                                                                       bundleName:@"ModShareStyle1"]
                                                                        title:@"微信好友"
                                                                     activity:ShareToWechatFriends],
                                                 [ShareTarget targetWithImage:[UIImage imageNamed:@"icon_share_wechat_moments"
                                                                                       bundleName:@"ModShareStyle1"]
                                                                        title:@"朋友圈"
                                                                     activity:ShareToWechatMoments]]];
    }
    
    if ([QQApiInterface isQQInstalled]) {
        [self.shareTargets addObjectsFromArray:@[[ShareTarget targetWithImage:[UIImage imageNamed:@"icon_share_qq"
                                                                                       bundleName:@"ModShareStyle1"]
                                                                        title:@"QQ好友"
                                                                     activity:ShareToQQFriends],
                                                 [ShareTarget targetWithImage:[UIImage imageNamed:@"icon_share_qqzone"
                                                                                        bundleName:@"ModShareStyle1"]
                                                                         title:@"QQ空间"
                                                                      activity:ShareToQQZone]
                                                 ]];
    }
    
    if (!self.backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:superview.bounds];
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 0.f;
        [self.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground)]];
        [self addSubview:self.backgroundView];
    }
    
    if (!self.contentView) {
        self.contentView = [[UIView alloc] init];
        self.contentView.backgroundColor = [UIColor colorWithRGB:0xdedede];
        [self addSubview:self.contentView];
    }
    
    UIView *sepLine;
    if (self.shareTargets.count) {
        if (!self.collectionViewMain) {
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.minimumLineSpacing = 0;
            layout.minimumInteritemSpacing = 0;
            
            self.collectionViewMain = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                         collectionViewLayout:layout];
            self.collectionViewMain.backgroundColor = [UIColor clearColor];
            self.collectionViewMain.alwaysBounceHorizontal = YES;
            
            self.collectionViewMain.dataSource = self;
            self.collectionViewMain.delegate = self;
            
            [self.collectionViewMain registerClass:[ModShareStyle1ShareCell class]
                        forCellWithReuseIdentifier:[ModShareStyle1ShareCell reuseIdentifier]];
            
            [self.contentView addSubview:self.collectionViewMain];
            [self.collectionViewMain mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView.mas_left).offset(8);
                make.right.equalTo(self.contentView.mas_right).offset(-8);
                make.top.equalTo(self.contentView).offset(16);
                make.height.equalTo(@100);
            }];
        }
        
        sepLine = [[UIView alloc] init];
        sepLine.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:sepLine];
        [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(8);
            make.right.equalTo(self.contentView.mas_right).offset(-8);
            make.top.equalTo(self.collectionViewMain.mas_bottom).offset(8);
            make.height.equalTo(@.5);
        }];
    }
    else {
        sepLine = [[UIView alloc] init];
        sepLine.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:sepLine];
        [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(8);
            make.right.equalTo(self.contentView.mas_right).offset(-8);
            make.top.equalTo(self.contentView).offset(16);
            make.height.equalTo(@.5);
        }];
    }
    
    for (NSNumber *activityNumber in extraTargets) {
        ShareActivity activity = activityNumber.integerValue;
        ShareTarget *target = nil;
        
        if (activity == ShareSaveImage) {
            target = [ShareTarget targetWithImage:[UIImage imageNamed:@"icon_share_save" bundleName:@"ModShareStyle1"]
                                            title:@"保存到相册"
                                         activity:ShareSaveImage];
        }
        else if (activity == ShareCopyURL) {
            target = [ShareTarget targetWithImage:[UIImage imageNamed:@"share_copy_icon" bundleName:@"ModShareStyle1"]
                                            title:@"复制链接"
                                         activity:ShareSaveImage];
        }
        else if (activity == ShareFavourite) {
            NSString *action;
            //    if (favouriteid > 0) {
            //        action = @"取消收藏";
            //    }
            //    else {
                    action = @"收藏";
            //    }
            
            target = [ShareTarget targetWithImage:[UIImage imageNamed:@"icon_share_favourite" bundleName:@"ModShareStyle1"]
                                            title:action
                                         activity:ShareFavourite];
        }
        else if (activity == ShareEdit) {
            target = [ShareTarget targetWithImage:[UIImage imageNamed:@"share_copy_icon" bundleName:@"ModShareStyle1"]
                                            title:@"编辑"
                                         activity:ShareEdit];
        }
        else if (activity == ShareDelete) {
            target = [ShareTarget targetWithImage:[UIImage imageNamed:@"share_copy_icon" bundleName:@"ModShareStyle1"]
                                            title:@"删除"
                                         activity:ShareDelete];
        }
        
        [self.extraTargets addObject:target];
    }
    
    if (self.extraTargets) {
        if (!self.collectionViewExtra) {
            //extra collection view
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.minimumLineSpacing = 0;
            layout.minimumInteritemSpacing = 0;
            
            self.collectionViewExtra = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                          collectionViewLayout:layout];
            self.collectionViewExtra.backgroundColor = [UIColor clearColor];
            self.collectionViewExtra.alwaysBounceHorizontal = YES;
            
            self.collectionViewExtra.dataSource = self;
            self.collectionViewExtra.delegate = self;
            
            [self.collectionViewExtra registerClass:[ModShareStyle1ShareCell class]
                         forCellWithReuseIdentifier:[ModShareStyle1ShareCell reuseIdentifier]];
            
            [self.contentView addSubview:self.collectionViewExtra];
            [self.collectionViewExtra mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView.mas_left).offset(8);
                make.right.equalTo(self.contentView.mas_right).offset(-8);
                make.top.equalTo(sepLine.mas_bottom).offset(8);
                make.height.equalTo(@100);
            }];
        }
        
        sepLine = [[UIView alloc] init];
        sepLine.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:sepLine];
        [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(8);
            make.right.equalTo(self.contentView.mas_right).offset(-8);
            make.top.equalTo(self.collectionViewExtra.mas_bottom).offset(8);
            make.height.equalTo(@.5);
        }];
    }
    
    if (!self.btnCancel) {
        self.btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnCancel setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [self.btnCancel setTitle:YUCLOUD_STRING_CANCEL forState:UIControlStateNormal];
        [self.btnCancel addTarget:self action:@selector(touchCancel) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnCancel];
        
        [self.btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.top.equalTo(sepLine.mas_bottom);
            make.height.equalTo(@44);
            make.bottom.equalTo(self.contentView).offset(-KBottomSafeHeight);
        }];
    }

    CGRect rect = self.bounds;
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    rect.origin.y = CGRectGetHeight(rect);
    rect.size.height = size.height;
    rect.size.width = superview.width;
    self.contentView.frame = rect;
}

- (void)showView {
    CGRect rect = self.contentView.frame;

    [UIView animateWithDuration:.3
                          delay:0
         usingSpringWithDamping:.7
          initialSpringVelocity:.7
                        options:0
                     animations:^{
                         self.backgroundView.alpha = .3;
                         
                         CGFloat y = CGRectGetHeight(self.bounds) - rect.size.height;
                         self.contentView.frame = CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                     }];

}

- (void)dismissView {
    CGRect rect = self.contentView.frame;

    [UIView animateWithDuration:.3
                     animations:^{
                        self.backgroundView.alpha = .0;
        
                        CGFloat y = CGRectGetHeight(self.bounds);
                        self.contentView.frame = CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height);
    }
                        completion:^(BOOL finished) {
                            [self removeFromSuperview];
                        }];
}


- (void)touchCancel {
    [self dismissView];
}

- (void)tapBackground {
    [self dismissView];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.collectionViewMain) {
        return [self.shareTargets count];
    }
    else {
        return [self.extraTargets count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:[ModShareStyle1ShareCell reuseIdentifier]
                                                     forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *image = [UIImage imageNamed:@"icon_share_qq" bundleName:@"ModShareStyle1"];
    CGFloat height = CGRectGetHeight(collectionView.bounds);
    return CGSizeMake(image.size.width + 16, height);
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(ModShareStyle1ShareCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.collectionViewMain) {
        cell.target = self.shareTargets[indexPath.item];
    }
    else {
        cell.target = self.extraTargets[indexPath.item];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    ShareTarget *target;
    if (collectionView == self.collectionViewMain) {
        target = self.shareTargets[indexPath.item];
    }
    else {
        target = self.extraTargets[indexPath.item];
    }
    
    [[ShareManager shareManager] dealWithTarget:target
                                         object:self.object];
    
    [self dismissView];
}

@end
