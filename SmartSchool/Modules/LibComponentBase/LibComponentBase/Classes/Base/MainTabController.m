//
//  MainTabController.m
//  Unilife
//
//  Created by 唐琦 on 2019/6/13.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "MainTabController.h"
//#import "HomeNewViewController.h"
//#import "MessagesViewController.h"
//#import "ModUserCenterStyle1ViewController.h"
//#import "MainNavigationController.h"
//#import "CommunityManager.h"
//#import "ModContactStyle1ViewController.h"
//#import "VoiceButton.h"
//#import "YuyinManager.h"
#import "BaseTabbarView.h"
#import "ConfigureHeader.h"

@interface MainTabController () < BaseTabbarItemDelegate, BaseTabbarViewDelegate >
@property (nonatomic, strong) BaseTabbarView *tabbarView;

@property (nonatomic, strong) BaseTabbarItem            *voiceBtn;
@property (nonatomic, copy)   NSDate                    *touchDownDate;

@end

@implementation MainTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.hidden = YES;
}

- (instancetype)initWithItems:(NSArray *)items controllers:(NSArray *)controllers {
    if (self = [super init]) {
        self.viewControllers = controllers;
        
        self.tabbarView = [[BaseTabbarView alloc] initWithArray:items];
        self.tabbarView.backgroundColor = [UIColor whiteColor];
        self.tabbarView.delegate = self;
        [self.view addSubview:self.tabbarView];
        
        [self.tabbarView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            } else {
                make.left.bottom.right.equalTo(self.view);
            }
            
            make.height.equalTo(@kTabbarHeight);
        }];
    }
    
    return self;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    
    [self.tabbarView configureBackgroundImage:backgroundImage];
}

- (void)tabbarButtonClick:(NSInteger)index {
    if (index < self.viewControllers.count) {
        self.selectedIndex = index;
    }
}

- (void)showTabbarView {
    [UIView animateWithDuration:0.1 animations:^{
        [self.tabbarView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            } else {
                make.bottom.equalTo(self.view);
            }
        }];
        
        [self.view layoutIfNeeded];
    }];
}

- (void)hideTabbarView {
    [UIView animateWithDuration:0.2 animations:^{
        [self.tabbarView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(kTabbarHeight+KBottomSafeHeight);
            } else {
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(kTabbarHeight+KBottomSafeHeight);
            }
            
            make.height.equalTo(@kTabbarHeight);
        }];
        
        [self.view layoutIfNeeded];
    }];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [YuyinManager shareManager].delegate = self;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BaseTabbarItemDelegate
//- (void)baseTabbarItemTouchDown:(BaseTabbarItem *)button {
//    [[YuyinManager shareManager] startAsrWithToneStart:NO toneEnd:NO];
//    self.touchDownDate = [NSDate date];
//}
//
//- (void)baseTabbarItemTouchUpInside:(BaseTabbarItem *)button {
//    [[YuyinManager shareManager] finishAsr];
//    if ([self.touchDownDate timeIntervalToNow] < .5) {
//        [[UniManager shareManager] startVA];
//    }
//}
//
//- (void)baseTabbarItemTouchUpOutside:(BaseTabbarItem *)button {
//    [[YuyinManager shareManager] cancelAsr];
//}
//
//#pragma mark - YuyinManagerDelegate
//
//- (void)voiceAsrFailed {
//    self.voiceBtn.state = VoiceButtonFailed;
//
//    [[UniManager shareManager] startVA];
//}
//
//- (void)voiceAsrCanceled {
//
//}
//
//- (void)voiceAsrSpeakFinished {
//
//}
//
//- (void)voiceAsrMeterLevel:(NSNumber *)level {
//    self.voiceBtn.meter = level.floatValue;
//}
//
//- (void)voiceAsrNluResult:(NluObject *)object {
//
//}
//
//- (void)voiceProcNlu:(NluObject *)object status:(BOOL)success result:(VoiceResult *)result {
//    if (!success) {
//        [[UniManager shareManager] startVAWithNlu:object
//                                      result:result];
//    }
//}

@end
