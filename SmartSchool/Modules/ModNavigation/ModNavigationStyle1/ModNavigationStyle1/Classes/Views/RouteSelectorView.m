//
//  RouteSelectorView.m
//  Module_demo
//
//  Created by 唐琦 on 2019/9/3.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "RouteSelectorView.h"
#import "NavigationManager.h"
#import "NaviModel.h"

@interface RouteCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) AMapNaviRoute *route;

@end

@implementation RouteCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.tipLabel = [[UILabel alloc] init];
        [self addSubview:self.tipLabel];
        
        self.timeLabel = [[UILabel alloc] init];
        [self addSubview:self.timeLabel];
        
        self.infoLabel = [[UILabel alloc] init];
        [self addSubview:self.infoLabel];
        
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(8);
            make.left.equalTo(self).offset(30);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(30);
        }];
        
        [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(30);
            make.bottom.equalTo(self).offset(-10);
        }];
    }
    
    return self;
}

- (void)setRoute:(RouteInfo *)route {
    self.tipLabel.text = route.routeLabel.length ? route.routeLabel : @"默认路径";
    self.timeLabel.text = route.routeTime;
    
    if (route.naviType == NavigationTypeDrive) {
        self.infoLabel.text = [NSString stringWithFormat:@"%@ 🚦%@", route.routeLength, route.trafficLightCount];
    }
    else {
        self.infoLabel.text = [NSString stringWithFormat:@"%@ %@个路口", route.routeLength, route.routeSegmentCount];
    }
    
    if (route.selected) {
        self.tipLabel.font = [UIFont boldSystemFontOfSize:14];
        self.tipLabel.textColor = [UIColor colorWithRGB:0x4287FF];
        
        self.timeLabel.font = [UIFont boldSystemFontOfSize:18];
        self.timeLabel.textColor = [UIColor colorWithRGB:0x4287FF];
        
        self.infoLabel.font = [UIFont boldSystemFontOfSize:12];
        self.infoLabel.textColor = [UIColor colorWithRGB:0x4287FF];
    }
    else {
        self.tipLabel.font = [UIFont systemFontOfSize:14];
        self.tipLabel.textColor = [UIColor colorWithRGB:0x9C9C9C];
        
        self.timeLabel.font = [UIFont systemFontOfSize:18];
        self.timeLabel.textColor = [UIColor colorWithRGB:0x333333];
        
        self.infoLabel.font = [UIFont systemFontOfSize:12];
        self.infoLabel.textColor = [UIColor colorWithRGB:0x333333];
    }
}

@end

@interface RouteSelectorView () < UICollectionViewDataSource, UICollectionViewDelegateFlowLayout >
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation RouteSelectorView

- (instancetype)init {
    if (self = [super init]) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 2;
        layout.minimumInteritemSpacing = 0;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.collectionView.backgroundColor = [UIColor colorWithRGB:0xEDEDED];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[RouteCell class] forCellWithReuseIdentifier:[RouteCell reuseIdentifier]];
        [self addSubview:self.collectionView];
        
        UIButton *naviButton = [UIButton buttonWithType:UIButtonTypeCustom];
        naviButton.backgroundColor = [UIColor colorWithRGB:0x4287FF];
        naviButton.layer.cornerRadius = 35/2.0;
        naviButton.layer.masksToBounds = YES;
        [naviButton setTitle:@"开始导航" forState:UIControlStateNormal];
        [naviButton addTarget:self action:@selector(naviButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:naviButton];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.bottom.equalTo(self).offset(-60);
            make.height.equalTo(@80.f);
        }];
        
        [naviButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(40);
            make.right.equalTo(self).offset(-10);
            make.size.equalTo(@(CGSizeMake(110, 35)));
        }];
    }
    return self;
}

- (void)setData:(NSArray *)data {
    _data = data;
    [self.collectionView reloadData];
}

- (void)naviButtonClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectNavigation)]) {
        [self.delegate didSelectNavigation];
    }
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:[RouteCell reuseIdentifier]
                                                     forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    width = (width-(self.data.count-1)*1) / self.data.count;
    
    return CGSizeMake(width, 78);
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(RouteCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.route = self.data[indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
 
    for (RouteInfo *route in self.data) {
        if (indexPath.item == [self.data indexOfObject:route]) {
            route.selected = YES;
        }
        else {
            route.selected = NO;
        }
    }
    
    [self.collectionView reloadData];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedRouteWithRouteID:)]) {
        RouteInfo *route = self.data[indexPath.item];
        [self.delegate didSelectedRouteWithRouteID:route.routeID];
    }
}

@end
