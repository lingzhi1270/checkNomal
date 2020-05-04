//
//  AppDelegate.m
//  ModuleDemo
//
//  Created by 唐琦 on 2020/1/3.
//  Copyright © 2020 唐琦. All rights reserved.
//

#import "AppDelegate.h"
#import <ModWebViewStyle1/ModWebViewStyle1ViewController.h>
#import <ModAdvertisementBase/AdsManager.h>
#import <LibUpload/UploadManager.h>
#import <ModPayBase/PayManager.h>
#import <WXApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <AlipaySDK/AlipaySDK.h>

#import "ChooseSchoolViewController.h"
#import <ModContactStyle1/ModContactStyle1ViewController.h>
#import <ModUserCenterStyle1/ModUserCenterStyle1ViewController.h>

@interface AppDelegate ()
@property (nonatomic, copy) NSString *wechatAppID;
@property (nonatomic, copy) NSString *qqAppID;

@end

@implementation AppDelegate

+ (AppDelegate *)shareAppDelagate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if (@available(iOS 13.0, *)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
    NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
    NSDictionary *platformInfo = infoDic[@"PlatformInfo"];
    
    if (platformInfo.count) {
        self.wechatAppID = platformInfo[@"WechatAppID"];
        self.qqAppID = platformInfo[@"QQAppID"];
        
        if (!self.wechatAppID.length) {
            NSAssert(NO, @"微信AppID不存在, 请在info.plist中添加");
        }

        if (!self.qqAppID.length) {
            NSAssert(NO, @"QQ的AppID不存在, 请在info.plist中添加");
        }
    }
    

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
        
    // 如果未选择学校,则显示选择学校界面
    if (![NSUserDefaults schoolId]) {
        ChooseSchoolViewController *viewController = [[ChooseSchoolViewController alloc] initWithTitle:@"选择学校" rightItem:nil];
        MainNavigationController *nav = [[MainNavigationController alloc] initWithRootViewController:viewController];
        self.window.rootViewController = nav;
        [self.window makeKeyAndVisible];
    }
    else {
        self.window.rootViewController = [self configureTabController];
        [self.window makeKeyAndVisible];
        
        [[AccountManager shareManager] startAutoLogin];
    }

    if (![NSUserDefaults splashKey]) {
        [[AdsManager shareManager] showSplash];
    }
    
    [ThemeManager shareManager];
    
    [[AliOssManager shareManager] requestOssInfoWithCompletion:nil];
    
    return YES;
}

- (MainTabController *)configureTabController {
    // 配置tab图标和标题
    NSArray *items = @[[BaseTabbarModel allocWithTitle:NSLocalizedString(@"Home", nil)
                              image:[UIImage imageNamed:@"ic_tab_home"]
                      selectedImage:[UIImage imageNamed:@"ic_tab_home_selected"]],
    [BaseTabbarModel allocWithTitle:NSLocalizedString(@"Contacts", nil)
                              image:[UIImage imageNamed:@"ic_tab_contact"]
                      selectedImage:[UIImage imageNamed:@"ic_tab_contact_selected"]],
    [BaseTabbarModel allocWithTitle:NSLocalizedString(@"Me", nil)
                              image:[UIImage imageNamed:@"ic_tab_mine"]
                      selectedImage:[UIImage imageNamed:@"ic_tab_mine_selected"]]];
    // 配置控制器
    NSURL *homeUrl = [NSURL URLWithString:@"https://tyves.yuanyuedu.com/dkq/jsbridge/index.html"];
    ModWebViewStyle1ViewController *homeVC = [[ModWebViewStyle1ViewController alloc] initWithUrl:homeUrl withTitle:[NSUserDefaults schoolName]];
    homeVC.isMainTab = YES;
    MainNavigationController *homeNav = [[MainNavigationController alloc] initWithRootViewController:homeVC];
    
    ModContactStyle1ViewController *contactVC = [[ModContactStyle1ViewController alloc] initWithCategory:nil grouped:YES];
    MainNavigationController *contactNav = [[MainNavigationController alloc] initWithRootViewController:contactVC];
    
    ModUserCenterStyle1ViewController *meVC = [[ModUserCenterStyle1ViewController alloc] initWithTitle:NSLocalizedString(@"Me", nil) rightItem:nil];
    MainNavigationController *meNav = [[MainNavigationController alloc] initWithRootViewController:meVC];
    // 创建TabController
    MainTabController *tabController = [[MainTabController alloc] initWithItems:items controllers:@[homeNav, contactNav, meNav]];
    tabController.backgroundImage = [UIImage imageNamed:@"ic_tab_bg"];
    
    return tabController;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    return [WXApi handleOpenUniversalLink:userActivity delegate:[AccountManager shareManager]];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [self accountHandleOpenUrl:url];
    
    return YES;
}

- (void)accountHandleOpenUrl:(NSURL *)url {
    NSString *string = url.absoluteString;

    if ([string containsString:self.wechatAppID]) {
        if ([string containsString:@"//pay/"]) {
            [WXApi handleOpenURL:url delegate:[PayManager shareManager]];
        }else {
            [WXApi handleOpenURL:url delegate:[AccountManager shareManager]];
        }
    }
    else if ([string containsString:self.qqAppID]) {
        [TencentOAuth HandleOpenURL:url];
        [QQApiInterface handleOpenURL:url delegate:[AccountManager shareManager]];
    }
    else if ([string containsString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if (resultDic) {

            }
        }];
    }
}



@end
