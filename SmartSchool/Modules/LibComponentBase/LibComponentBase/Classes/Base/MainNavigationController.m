//
//  MainNavigationController.m
//  Unilife
//
//  Created by 唐琦 on 2019/6/16.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "MainNavigationController.h"
//#import "ReactiveAppViewController.h"
#import "MainTabController.h"
#import "BaseViewController.h"

@interface MainNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation MainNavigationController

//- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
//    if (self = [super initWithNavigationBarClass:[AppNavigationBar class]
//                                    toolbarClass:[UIToolbar class]]) {
//        self.viewControllers = @[rootViewController];
//    }
//    
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.modalPresentationStyle = UIModalPresentationFullScreen;

    //实现右滑pop手势delegate
    __weak typeof (self) weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
    }
    
    self.delegate = self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //push的时候关闭右滑pop手势
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    if (self.childViewControllers.count == 1) {
        [(MainTabController *)[UIApplication sharedApplication].keyWindow.rootViewController hideTabbarView];
    }
    
    viewController.hidesBottomBarWhenPushed = YES;
//    viewController.navigationController.navigationBarHidden = YES;
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    self.topViewController.navigationController.navigationBarHidden = YES;
    
    return [super popViewControllerAnimated:animated];
}

//新控制器将要显示
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    BOOL isHiddenNavBar = ((MainTabController *)viewController.tabBarController).isHiddenNavBar;
    
    //只有个人中心首页需要隐藏导航栏
    if (isHiddenNavBar && self.viewControllers.count == 1) {
        ((BaseViewController *)viewController).topView.hidden = YES;
    }
    else {
        if ([viewController isKindOfClass:[BaseViewController class]]) {
            ((BaseViewController *)viewController).topView.hidden = NO;
        }
    }
}
//新控制器已经显示
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    //开启右滑pop手势
    NSArray *controllers = navigationController.viewControllers;
    if (controllers.count > 1) {
        if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
    else {
        if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
}

//默认所有页面支持右滑返回
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return true;
}

//获取侧滑返回手势
- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer {
    UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer = nil;
    if (self.view.gestureRecognizers.count > 0) {
        for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
            if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
                screenEdgePanGestureRecognizer = (UIScreenEdgePanGestureRecognizer *)recognizer;
                break;
            }
        }
    }
    
    return screenEdgePanGestureRecognizer;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
