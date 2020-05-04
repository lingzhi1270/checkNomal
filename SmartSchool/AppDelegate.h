//
//  AppDelegate.h
//  ModuleDemo
//
//  Created by 唐琦 on 2020/1/3.
//  Copyright © 2020 唐琦. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP_DELEGATE_WINDOW     [AppDelegate shareAppDelagate].window

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;

+ (AppDelegate *)shareAppDelagate;

- (MainTabController *)configureTabController;

@end

