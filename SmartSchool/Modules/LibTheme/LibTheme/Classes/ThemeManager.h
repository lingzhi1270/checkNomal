//
//  ThemeManager.h
//  Unilife
//
//  Created by 唐琦 on 2019/7/20.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/ThemeData.h>
#import "ThemeView.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const ThemeContentBackgroundViewColorKey;
extern NSString * const ThemeNavBarBackgroundColorKey;
extern NSString * const ThemeNavBarForegroundColorKey;
extern NSString * const ThemeTabBarBackroundColorKey;
extern NSString * const ThemeTabBarForegroundColorKey;
extern NSString * const ThemeContentViewTextPrimaryColorKey;
extern NSString * const ThemeContentViewTextSecondaryColorKey;
extern NSString * const ThemeContentViewSeparatorColorKey;
extern NSString * const ThemeButtonBackgroundColorKey;
extern NSString * const ThemeButtonForeroundColorKey;

extern NSString * const ThemeWindowBackgroundImageKey;
extern NSString * const ThemeNavBarBackgroundImageKey;
extern NSString * const ThemeMeTitleImageKey;

#define UNILIFE_THEME_PRIMARY_COLOR     [[ThemeManager shareManager].activeTheme colorForKey:ThemeButtonBackgroundColorKey]

#define THEME_TEXT_PRIMARY_COLOR        [[ThemeManager shareManager].activeTheme colorForKey:ThemeContentViewTextPrimaryColorKey]
#define THEME_TEXT_SECONDARY_COLOR      [[ThemeManager shareManager].activeTheme colorForKey:ThemeContentViewTextSecondaryColorKey]

#define THEME_BUTTON_FOREGROUND_COLOR   [[ThemeManager shareManager].activeTheme colorForKey:ThemeButtonForeroundColorKey]
#define THEME_BUTTON_BACKGROUND_COLOR   [[ThemeManager shareManager].activeTheme colorForKey:ThemeButtonBackgroundColorKey]

#define THEME_CONTENT_SEPARATOR_COLOR   [[ThemeManager shareManager].activeTheme colorForKey:ThemeContentViewSeparatorColorKey]

#define THEME_CONTENT_BACKGROUND_COLOR  [[ThemeManager shareManager].activeTheme colorForKey:ThemeContentBackgroundViewColorKey]

@interface ThemeManager : BaseManager

@property (nonatomic, readonly) ThemeData     *activeTheme;

- (void)addTheme:(ThemeData *)city;

+ (void)changeThemeDirectory;

- (BOOL)themeDownload:(ThemeData *)theme;
- (BOOL)themeExtracted:(ThemeData *)theme;

- (void)requestThemeWithCompletion:(nullable CommonBlock)completion;

- (void)downloadTheme:(ThemeData *)theme
             progress:(nullable void (^)(NSProgress * _Nonnull))downloadProgress
           completion:(nullable CommonBlock)completion;

- (void)activateTheme:(ThemeData *)theme
           completion:(nullable CommonBlock)completion;

- (NSArray *)allThemes;

- (nullable ThemeData *)themeWithName:(NSString *)name;

- (nullable ThemeData *)systemDefaultTheme;

@end

NS_ASSUME_NONNULL_END
