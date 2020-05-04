//
//  MainTabController.h
//  Unilife
//
//  Created by 唐琦 on 2019/6/13.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTabController : UITabBarController
@property (nonatomic, assign) BOOL isHiddenNavBar;
@property (nonatomic, strong) UIImage *backgroundImage;

- (instancetype)initWithItems:(NSArray *)items
                  controllers:(NSArray *)controllers;

- (void)showTabbarView;
- (void)hideTabbarView;

@end
