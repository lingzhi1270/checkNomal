//
//  BaseViewController.h
//  Unilife
//
//  Created by 唐琦 on 2018/12/10.
//  Copyright © 2018 南京远御网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KTopViewBackButtonTag       10001
#define KTopViewRightButtonTag      10002
#define KTopViewLeftButtonTag       10003

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController
@property (nonatomic, assign)   BOOL               landScape;
@property (nonatomic, readonly) UIView             *safeArea;
@property (nonatomic, strong)   UIView             *topView;
@property (nonatomic, strong)   UIImageView         *lineView;

// if you fill title with nil that represent no navigationBar will be created
- (instancetype)initWithTitle:(nullable NSString *)title
                    rightItem:(nullable UIButton *)rightButton;

- (void)constraintsNeedUpdate;

- (void)hiddenBackButton;

- (void)showBackButton;
// webview may need later methods

- (void)updateNaviBarWithTitle:(NSString *)title;

- (void)addLeftButton:(UIButton *)leftButton;

- (void)addRightButton:(UIButton *)rightButton;

- (void)closeView;

- (void)rightButtonAction;

@end

NS_ASSUME_NONNULL_END
