//
//  UserCenterStyle1SectionHeaderView.h
//  Unilife
//
//  Created by 唐琦 on 2019/6/29.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

@class UserCenterStyle1SectionHeaderView;

@protocol UserCenterStyle1SectionHeaderViewDelegate <NSObject>

- (void)moreButtonTouchedOfHeaderView:(UserCenterStyle1SectionHeaderView *)headerView;

@end

@interface UserCenterStyle1SectionHeaderView : UICollectionReusableView

@property (nonatomic, weak) id<UserCenterStyle1SectionHeaderViewDelegate>     delegate;

@property (nonatomic, copy)   NSString      *title;
@property (nonatomic, copy)   UIImage       *image;
@property (nonatomic, assign) BOOL          more;

+ (NSString *)reuseIdentifier;

@end
