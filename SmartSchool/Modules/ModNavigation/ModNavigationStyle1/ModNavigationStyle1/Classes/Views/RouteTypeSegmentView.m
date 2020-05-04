//
//  RouteTypeSegmentView.m
//  Module_demo
//
//  Created by 唐琦 on 2019/9/4.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "RouteTypeSegmentView.h"

@interface RouteTypeCell : UICollectionViewCell
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation RouteTypeCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.bgView = [[UIView alloc] init];
        self.bgView.layer.cornerRadius = 25/2;
        self.bgView.layer.masksToBounds = YES;
        [self addSubview:self.bgView];
        
        self.titleLabel = [[UILabel alloc] init];
        [self addSubview:self.titleLabel];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(15);
            make.centerX.equalTo(self);
            make.width.equalTo(@(75.f));
            make.height.equalTo(@(25.f));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.bgView);
        }];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title isSelected:(BOOL)selected{
    self.titleLabel.text = title;
    
    if (selected) {
        self.bgView.backgroundColor = [UIColor colorWithRGB:0x4287FF];
        self.titleLabel.textColor = [UIColor whiteColor];
    }
    else {
        self.bgView.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor colorWithRGB:0x757575];
    }
}

@end

@interface RouteTypeSegmentView () < UICollectionViewDataSource, UICollectionViewDelegateFlowLayout >
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation RouteTypeSegmentView

- (instancetype)init {
    if (self = [super init]) {
        self.currentIndex = 0;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[RouteTypeCell class] forCellWithReuseIdentifier:NSStringFromClass(RouteTypeCell.class)];
        [self addSubview:self.collectionView];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    return self;
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(RouteTypeCell.class)
                                                     forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    
    return CGSizeMake(width/3, 50);
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(RouteTypeCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [cell setTitle:@[@"驾车", @"骑行", @"步行"][indexPath.item]
        isSelected:indexPath.item == self.currentIndex];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    self.currentIndex = indexPath.item;
    
    [self.collectionView reloadData];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedTypeWithIndex:)]) {
        [self.delegate didSelectedTypeWithIndex:indexPath.item];
    }
}

@end
