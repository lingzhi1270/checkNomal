//
//  ThemeManager.m
//  Unilife
//
//  Created by 唐琦 on 2019/7/20.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ThemeManager.h"
#import <NYXImagesKit/UIImage+Resizing.h>
#import <NYXImagesKit/UIImage+Saving.h>
#import <NYXImagesKit/UIImage+Blurring.h>
#import <GPUImage/GPUImage.h>
#import <LibCoredata/CacheDataSource.h>
#import <ModloginBase/AccountManager.h>

NSString * const ThemeContentBackgroundViewColorKey     = @"CONTENT_BACKGROUND_COLOR";
NSString * const ThemeNavBarBackgroundColorKey          = @"NAV_BAR_BACKGROUND_COLOR";
NSString * const ThemeNavBarForegroundColorKey          = @"NAV_BAR_FOREGROUND_COLOR";
NSString * const ThemeTabBarBackroundColorKey           = @"TAB_BAR_BACKGROUND_COLOR";
NSString * const ThemeTabBarForegroundColorKey          = @"TAB_BAR_FOREGROUND_COLOR";
NSString * const ThemeContentViewTextPrimaryColorKey    = @"CONTENT_TEXT_PRIMARY_COLOR";
NSString * const ThemeContentViewTextSecondaryColorKey  = @"CONTENT_TEXT_SECONDARY_COLOR";
NSString * const ThemeContentViewSeparatorColorKey      = @"CONTENT_SEPARATOR_COLOR";
NSString * const ThemeButtonBackgroundColorKey          = @"BUTTON_BACKGROUND_COLOR";
NSString * const ThemeButtonForeroundColorKey           = @"BUTTON_FOREGROUND_COLOR";

NSString * const ThemeWindowBackgroundImageKey          = @"WINDOW_BACKGROUND_IMAGE";
NSString * const ThemeNavBarBackgroundImageKey          = @"NAV_BAR_BACKGROUND_IMAGE";
NSString * const ThemeMeTitleImageKey                   = @"ME_TITLE_IMAGE";

@interface ThemeManager ()

@property (nonatomic, strong) NSFileManager         *fileManager;

@property (nonatomic, strong) ThemeData             *activeTheme;

@end

@implementation ThemeManager

+ (instancetype)shareManager {
    static dispatch_once_t token;
    static ThemeManager *client = nil;
    dispatch_once(&token, ^{
        client = [[ThemeManager alloc] init];
    });
    
    return client;
}

- (instancetype)init {
    if (self = [super init]) {
        self.fileManager = [NSFileManager defaultManager];
        
        [self requestThemeWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
            if (success) {
                for (ThemeData *item in [self allThemes]) {
                    if (item.timeOn || item.timeOff) {
                        //这是一个自动上线的主题，可能需要提前下载
                        BOOL downloaded = [self themeDownload:item];
                        BOOL activated = [item.name isEqualToString:[NSUserDefaults activatedTheme]];
                        if (!item.timeOff || [item.timeOff timeIntervalSinceDate:[NSDate date]] > 0) {
                            if (!downloaded) {
                                //没有自动下线时间，或者自动下线时间在今天以后，则需要预先下载
                                [self downloadTheme:item
                                           progress:nil
                                         completion:nil];
                            }
                            
                            if (downloaded && !activated && !item.autoActivated && [item.timeOn compare:[NSDate date]] == NSOrderedAscending) {
                                //需要自动激活
                                [self activateTheme:item
                                         completion:^(BOOL success, NSDictionary * _Nullable info) {
                                             item.autoActivated = YES;
                                             [self addTheme:item ];
                                         }];
                            }
                        }
                        
                        if (activated) {
                            if (item.timeOff && [item.timeOff compare:[NSDate date]] == NSOrderedAscending) {
                                //需要自动下线
                                [self activateDefault];
                            }
                        }
                    }
                }
            }
            else {
                [self activateDefault];
            }
        }];
        
        NSString *name = [NSUserDefaults activatedTheme];
        ThemeData *theme = [self themeWithName:name];
        
        if (theme && [self themeExtracted:theme]) {
            //目前有激活的theme
            [self setActiveTheme:theme completion:nil];
        }
        else {
            //使用系统默认主题
            [self activateDefault];
        }
    }
    
    return self;
}

- (NSArray *)allThemes {
    return [[CacheDataSource sharedClient] getDatasWithEntityName:[ThemeEntity entityName]
                                                        predicate:nil
                                                  sortDescriptors:@[]];
}

- (void)addTheme:(ThemeData *)theme  {
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:[self allThemes]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", theme.name];
    NSArray *array = [[self allThemes] filteredArrayUsingPredicate:predicate];
    if (array.count) {
        [tempArr removeObjectsInArray:array];
    }
    
    [tempArr addObject:theme];
    
    [[CacheDataSource sharedClient] addObject:theme
                                   entityName:[ThemeEntity entityName]];
}

+ (void)changeThemeDirectory {
    NSURL *cache = [[UIApplication sharedApplication] cachesURL];
    cache = [cache URLByAppendingPathComponent:@"theme"];
    [[NSFileManager defaultManager] createDirectoryAtURL:cache
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:nil];
    
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:cache.path];
}

- (void)setActiveTheme:(ThemeData *)theme completion:(CommonBlock)completion {
    [self activate:theme completion:^(BOOL success, NSDictionary * _Nullable info) {
        if (success) {
            self.activeTheme = theme;
            
            [[UINavigationBar appearance] setBackgroundImage:theme.imageTop forBarMetrics:UIBarMetricsDefault];
            [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [theme colorForKey:ThemeNavBarForegroundColorKey]}];
        }
        
        if (completion) {
            completion(success, nil);
        }
    }];
}

- (void)activate:(ThemeData *)theme completion:(CommonBlock)completion {
    [ThemeManager changeThemeDirectory];
    
    NSString *path = [[NSFileManager defaultManager] currentDirectoryPath];
    path = [path stringByAppendingPathComponent:theme.fileName];
    path = [path stringByAppendingPathComponent:@"theme.plist"];
    
    theme.themeFile = path;
    
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSAssert(dic, @"theme.plist file should be loaded");
    theme.images = dic[@"image"];
    
    NSDictionary *colors = dic[@"color"];
    
    [UINavigationBar appearance].translucent = YES;
    [UINavigationBar appearance].shadowImage = [UIImage new];
    [UITabBar appearance].translucent = YES;
    [UITabBar appearance].shadowImage = [UIImage new];
    
    [colors enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        UIColor *color = [UIColor colorAlphaFromString:obj];
        [theme.colors setObject:color forKey:key];
        
        if ([key isEqualToString:ThemeNavBarBackgroundColorKey]) {
            [UINavigationBar appearance].barTintColor = color;
        }
        else if ([key isEqualToString:ThemeNavBarForegroundColorKey]) {
            [UINavigationBar appearance].tintColor = color;
            [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName : color};
        }
        else if ([key isEqualToString:ThemeTabBarBackroundColorKey]) {
            [[UITabBar appearance] setBarTintColor:color];
        }
        else if ([key isEqualToString:ThemeTabBarForegroundColorKey]) {
            [[UITabBar appearance] setTintColor:color];
        }
        else if ([key isEqualToString:ThemeContentBackgroundViewColorKey]) {
            [UITableView appearance].backgroundColor = color;
            [UITableViewCell appearance].backgroundColor = color;
            
            [UICollectionView appearance].backgroundColor = color;
            [UICollectionViewCell appearance].backgroundColor = color;
        }
        else if ([key isEqualToString:ThemeContentViewTextPrimaryColorKey]) {
            
        }
        else {
        }
    }];
    
    UIImage *image = [theme imageForKey:ThemeWindowBackgroundImageKey];
    if (image) {
        if (!theme.imageTop || !theme.imageFull || !theme.imageBottom) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                CGFloat scale = [UIScreen mainScreen].scale;
                CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
                UIImage *fullImage = [[UIImage imageWithData:UIImagePNGRepresentation(image) scale:scale] scaleToCoverSize:size];
                fullImage = [fullImage cropToSize:size usingMode:NYXCropModeCenter];
                
                theme.imageFull = fullImage;
                theme.imageTop = [fullImage cropToSize:CGSizeMake(size.width * scale, 120) usingMode:NYXCropModeTopCenter];
                
                if ([UIScreen resolution] == UIDeviceResolution_iPhoneRetinaX) {
                    theme.imageBottom = [fullImage cropToSize:CGSizeMake(size.width * scale, 49 + 34) usingMode:NYXCropModeBottomCenter];
                }
                else {
                    theme.imageBottom = [fullImage cropToSize:CGSizeMake(size.width * scale, 49) usingMode:NYXCropModeBottomCenter];
                }
                
                GPUImageGaussianBlurFilter *filter = [[GPUImageGaussianBlurFilter alloc] init];
                filter.blurRadiusInPixels = 32;
                UIImage *image = [filter imageByFilteringImage:theme.imageTop];
                if (image) {
                    theme.imageTop = image;
                }
                
                image = [filter imageByFilteringImage:theme.imageBottom];
                if (image) {
                    theme.imageBottom = image;
                }
                [self addTheme:theme];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(YES, nil);
                    }
                });
            });
            
            return;
        }
    }
    
    if ([UIScreen resolution] != UIDeviceResolution_iPhoneRetinaX) {
        image = [self imageForKey:ThemeNavBarBackgroundImageKey];
        if (image) {
            CGSize size = [UIScreen mainScreen].bounds.size;
            size = CGSizeMake(size.width, 64);
            image = [image scaleToCoverSize:size];
            image = [image cropToSize:size usingMode:NYXCropModeCenter];
            theme.imageTop = image;
            [self addTheme:theme];
        }
    }
    
    image = [theme imageForKey:ThemeMeTitleImageKey];
    if (image) {
        theme.imageMeTitle = image;
        [self addTheme:theme];
    }
    
    if (completion) {
        completion(YES, nil);
    }
}

- (BOOL)themeDownload:(ThemeData *)theme {
    [ThemeManager changeThemeDirectory];
    
    if (theme.fileName.length == 0) {
        return NO;
    }
    
    NSString *path = [[NSFileManager defaultManager] currentDirectoryPath];
    path = [path stringByAppendingPathComponent:theme.fileName];
    path = [path stringByAppendingPathExtension:@"zip"];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (BOOL)themeExtracted:(ThemeData *)theme {
    [ThemeManager changeThemeDirectory];
    
    NSString *path = [[NSFileManager defaultManager] currentDirectoryPath];
    path = [path stringByAppendingPathComponent:theme.fileName];
    path = [path stringByAppendingPathComponent:@"theme.plist"];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (void)activateDefault {
    ThemeData *theme = [self systemDefaultTheme];

    if (!theme) {
        theme = [ThemeData new];
        theme.name = @"默认主题";
        theme.sysDefault = YES;
    }
    
    [self downloadTheme:theme
               progress:nil
             completion:^(BOOL success, NSDictionary * _Nullable info) {
                 if (success) {
                     [self extractTheme:theme
                             completion:^(BOOL success, NSDictionary * _Nullable info) {
                                 if (success) {
                                     [NSUserDefaults saveActivatedTheme:theme.name];
                                     [self setActiveTheme:theme completion:nil];
                                 }
                             }];
                 }
             }];
}

- (UIColor *)colorForKey:(NSString *)key {
    return [self.activeTheme colorForKey:key];
}

- (UIImage *)imageForKey:(NSString *)key {
    return [self.activeTheme imageForKey:key];
}

- (void)requestThemeWithCompletion:(CommonBlock)completion {
    [[MainInterface sharedClient] doWithMethod:@"GET"
                                     urlString:@"home/theme"
                                    parameters:nil
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                           NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                           NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                           ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                           
                                           NSDictionary *extra = responseObject[@"extra"];
                                           if ([error_code errorCodeSuccess]) {
                                               NSArray *data = extra[@"data"];
                                               
                                               NSMutableArray *arr = [NSMutableArray new];
                                               for (NSDictionary *item in data) {
                                                   NSNumber *number = item[@"default"];
                                                   NSString *name = item[@"name"];
                                                   ThemeData *theme = nil;
                                                   
                                                   if ([number boolValue]) {
                                                       theme = [[ThemeManager shareManager] systemDefaultTheme];
                                                       if (!theme) {
                                                           theme = [ThemeData new];
                                                       }
                                                       theme.name = name;
                                                       theme.sysDefault = [number boolValue];
                                                       theme.detail = VALIDATE_STRING(item[@"detail"]);
                                                       theme.coverUrl = VALIDATE_STRING(item[@"cover_url"]);
                                                       theme.bundleUrl = VALIDATE_STRING(item[@"bundle_ios"]);
                                                       theme.screenUrl = item[@"screen_url"];
                                                       
                                                       NSDateFormatter *formatter = [NSDateFormatter new];
                                                       formatter.dateFormat = @"y-M-d";
                                                       NSString *time_on = VALIDATE_STRING(item[@"time_on"]);
                                                       if (time_on) {
                                                           theme.timeOn = [formatter dateFromString:time_on];
                                                       }
                                                       
                                                       NSString *time_off = VALIDATE_STRING(item[@"time_off"]);
                                                       if (time_off) {
                                                           theme.timeOff = [formatter dateFromString:time_off];
                                                       }
                                                   }
                                                   else {
                                                       theme =  [[ThemeManager shareManager] themeWithName:name];
                                                       if (!theme) {
                                                           theme = [ThemeData new];
                                                       }
                                                       theme.name = name;
                                                       theme.sysDefault = [number boolValue];
                                                       theme.detail = VALIDATE_STRING(item[@"detail"]);
                                                       theme.coverUrl = VALIDATE_STRING(item[@"cover_url"]);
                                                       theme.bundleUrl = VALIDATE_STRING(item[@"bundle_ios"]);
                                                       theme.screenUrl = item[@"screen_url"];
                                                       
                                                       NSDateFormatter *formatter = [NSDateFormatter new];
                                                       formatter.dateFormat = @"y-M-d";
                                                       NSString *time_on = VALIDATE_STRING(item[@"time_on"]);
                                                       if (time_on) {
                                                           theme.timeOn = [formatter dateFromString:time_on];
                                                       }
                                                       
                                                       NSString *time_off = VALIDATE_STRING(item[@"time_off"]);
                                                       if (time_off) {
                                                           theme.timeOff = [formatter dateFromString:time_off];
                                                       }
                                                   }
                                                   
                                                   [arr addObject:theme];
                                               }
                                               // 保存主题数据成功
                                               [[CacheDataSource sharedClient] addObjects:arr
                                                                               entityName:[ThemeEntity entityName]
                                                                                  syncAll:NO
                                                                            syncPredicate:nil];
                                               
                                               if (completion) {
                                                   completion(YES, responseObject[@"extra"]);
                                               }
                                           }
                                           else if (completion) {
                                               completion(NO, @{@"error_code" : error_code,
                                                                @"error_msg" : error_msg});
                                           }
                                       }
                                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                           if (completion) {
                                               completion(NO, @{@"error_code" : [NSNumber commonNetError],
                                                                @"error_msg" : [error localizedDescription]});
                                           }
                                       }];
}

- (void)downloadTheme:(ThemeData *)theme
             progress:(nullable void (^)(NSProgress * _Nonnull))downloadProgress
           completion:(CommonBlock)completion {
    if (theme.sysDefault) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"default" withExtension:@"zip"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSString *name = data.MD5;
        
        [ThemeManager changeThemeDirectory];
        
        BOOL success = [data writeToFile:[name stringByAppendingString:@".zip"] atomically:YES];
        if (success) {
            theme.fileName = name;
            [self addTheme:theme];
        }
        
        if (completion) {
            completion(success, nil);
        }
    }
    else {
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        manager.responseSerializer = [AFDataResponseSerializer serializer];
        [manager GET:theme.bundleUrl
          parameters:nil
            progress:downloadProgress
             success:^(NSURLSessionDataTask * _Nonnull task, NSData *data) {
                 [ThemeManager changeThemeDirectory];
                 NSString *name = data.MD5;
                 
                 BOOL success = [data writeToFile:[name stringByAppendingString:@".zip"] atomically:YES];
                 if (success) {
                     theme.fileName = name;
                     [self addTheme:theme];
                 }
                 
                 if (completion) {
                     completion(success, nil);
                 }
             }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 if (completion) {
                     completion(NO, nil);
                 }
             }];
    }
}

- (void)extractTheme:(ThemeData *)theme completion:(CommonBlock)completion {
    [ThemeManager changeThemeDirectory];
    
    NSString *path = [[NSFileManager defaultManager] currentDirectoryPath];
    path = [path stringByAppendingPathComponent:theme.fileName];
    path = [path stringByAppendingPathExtension:@"zip"];
    
    NSString *desti = [[NSFileManager defaultManager] currentDirectoryPath];
    desti = [desti stringByAppendingString:@"/"];
    desti = [desti stringByAppendingString:theme.fileName];
    
    [[ArchiveManager manager] unzipFile:path
                            destination:desti
                            complection:^(BOOL success, NSString * _Nonnull destination) {
                                if (success) {
                                    
                                }
                                
                                if (completion) {
                                    completion(success, nil);
                                }
                            }];
}

- (void)activateTheme:(ThemeData *)theme completion:(CommonBlock)completion {
    [self extractTheme:theme
            completion:^(BOOL success, NSDictionary * _Nullable info) {
                if (success) {
                    [NSUserDefaults saveActivatedTheme:theme.name];
                    [self setActiveTheme:theme completion:completion];
                }
                else if (completion) {
                    completion(success, nil);
                }
            }];
}

- (nullable ThemeData *)themeWithName:(NSString *)name {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    NSArray *array = [[self allThemes] filteredArrayUsingPredicate:predicate];
    
    if (array.count) {
        return array.firstObject;
    }
    else {
        return nil;
    }
}

- (nullable ThemeData *)systemDefaultTheme {
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sysDefault == %d", YES];
     NSArray *array = [[self allThemes] filteredArrayUsingPredicate:predicate];
     
     if (array.count) {
         return array.firstObject;
     }
     else {
         return nil;
     }
}

@end
