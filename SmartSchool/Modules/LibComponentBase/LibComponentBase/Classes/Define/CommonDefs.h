//
//  CommonDefs.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/15.
//  Copyright © 2019 唐琦. All rights reserved.
//

#ifndef CommonDefs_h
#define CommonDefs_h

#ifdef DEBUG
#   define DDLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#   define ELog(err) {if(err) DDLog(@"%@", err)}
#else
#   define DDLog(...){NSLog((@"111 ");}
#   define ELog(err)
#endif

#import "ConfigureHeader.h"

typedef void (^CommonBlock)(BOOL success, NSDictionary * _Nullable info);

typedef NS_ENUM(NSInteger, YuCloudDataActions) {
    YuCloudDataList,
    YuCloudDataAdd,
    YuCloudDataEdit,
    YuCloudDataDelete
};

///来源
typedef NS_ENUM(NSInteger, CheckGradeFromType) {
    CheckGradeFromTypeStudent = 0,     /**个人 */
    CheckGradeFromTypeClass,           /**班级 */
    CheckGradeFromTypeArea             /**包干区 */
};


#define NavigationController \
^(){   \
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController; \
    if ([controller isKindOfClass:[UITabBarController class]]) { \
        UINavigationController *nav = ((UITabBarController *)controller).selectedViewController; \
        /*DDLog(@"MainTabBarController");*/ \
        return nav; \
    } \
    else if ([controller isKindOfClass:[UINavigationController class]]) { \
       /* DDLog(@"UINavigationController"); */\
        return ((UINavigationController *)controller); \
    } \
        \
    return [UINavigationController new]; \
}()

#define TopViewController \
^(){ \
    UINavigationController *nav = NavigationController;\
    /*DDLog(@"%@", nav.class);*/ \
    if (nav.presentedViewController) {\
        /*DDLog(@"presentedViewController %@", nav.presentedViewController);*/\
        return nav.presentedViewController;\
    }\
    else {\
       /* DDLog(@"topViewController %@", nav.topViewController);*/\
        return nav.topViewController;\
    }\
}()

#define SchoolId                1003

#define SCREENWIDTH             [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT            [UIScreen mainScreen].bounds.size.height
#define MAIN_COLOR              [UIColor colorWithRGB:0x4D7BFD]
#define MAIN_BG_COLOR           [UIColor colorWithRGB:0xF9F9F9]
#define MAIN_NAVI_BG_COLOR      [UIColor colorWithRGB:0xFFFFFF]
#define MAIN_NAVI_TITLE_COLOR   [UIColor colorWithRGB:0x444444]
#define MAIN_LINE_COLOR         [UIColor colorWithRGB:0xE4E4E4]

#define CONTENT_VIEW                                    self.contentView

#define VALIDATE_STRING(string) (string && [string isKindOfClass:[NSString class]])?string:nil
#define VALIDATE_NUMBER(number) (number && [number isKindOfClass:[NSNumber class]])?number:nil
#define VALIDATE_STRING_WITH_DEFAULT(string, default) (string && [string isKindOfClass:[NSString class]])?string:default
#define VALIDATE_NUMBER_WITH_DEFAULT(number, default) (number && [number isKindOfClass:[NSNumber class]])?number:default

#define YUCLOUD_STRING_PLEASE_WAIT                      NSLocalizedString(@"Please wait", nil)
#define YUCLOUD_STRING_SUCCESS                          NSLocalizedString(@"Success", nil)
#define YUCLOUD_STRING_FAILED                           NSLocalizedString(@"Failed", nil)
#define YUCLOUD_STRING_CANCEL                           NSLocalizedString(@"Cancel", nil)
#define YUCLOUD_STRING_CONTINUE                         NSLocalizedString(@"Continue", nil)
#define YUCLOUD_STRING_DONE                             NSLocalizedString(@"Done", nil)
#define YUCLOUD_STRING_SAVE                             NSLocalizedString(@"Save", nil)
#define YUCLOUD_STRING_OK                               NSLocalizedString(@"OK", nil)
#define YUCLOUD_STRING_CLOSE                            NSLocalizedString(@"Close", nil)
#define YUCLOUD_STRING_EDIT                             NSLocalizedString(@"Edit", nil)
#define YUCLOUD_STRING_DELETE                           NSLocalizedString(@"Delete", nil)
#define YUCLOUD_STRING_ADD                              NSLocalizedString(@"Add", nil)

#define WEAK(var, name)             __weak __typeof(var) name = var
#define STRONG(var, name)           __strong __typeof(var) name = var
#define LATER_DATE(a, b)            a = a?[a laterDate:b]:b

#define KStatusBarHeight        ([UIScreen resolution] > UIDeviceResolution_iPhoneRetina6p ? 44 : 20)
#define KBottomSafeHeight       ([UIScreen resolution] > UIDeviceResolution_iPhoneRetina6p ? 34 : 0)
#define KTopViewHeight          ([UIScreen resolution] > UIDeviceResolution_iPhoneRetina6p ? 88 : 64)
#define NAVIBAR_HEIGHT          44.f
#define kTabbarHeight           49.f

#endif /* CommonDefs_h */
