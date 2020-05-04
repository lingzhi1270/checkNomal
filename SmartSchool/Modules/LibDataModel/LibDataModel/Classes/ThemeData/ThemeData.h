//
//  ThemeDataSource.h
//  Unilife
//
//  Created by 唐琦 on 2019/7/20.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThemeData : NSObject

//这些是要存在数据库的
@property (nonatomic, copy) NSString        *name;
@property (nonatomic)       BOOL            sysDefault;
@property (nonatomic, copy) NSString        *coverUrl;
@property (nonatomic, copy) NSString        *detail;
@property (nonatomic, copy) NSString        *bundleUrl;
@property (nonatomic, copy) NSArray         *screenUrl;
@property (nonatomic, copy) NSString        *fileName;
@property (nonatomic, copy) NSDate          *timeOn;
@property (nonatomic, copy) NSDate          *timeOff;

//这些是运行时得到的
@property (nonatomic, copy) NSString        *themeFile;
@property (nonatomic, copy) UIImage         *imageTop;
@property (nonatomic, copy) UIImage         *imageFull;
@property (nonatomic, copy) UIImage         *imageBottom;
@property (nonatomic, copy) UIImage         *imageMeTitle;
@property (nonatomic, assign) BOOL          autoActivated;
@property (nonatomic, strong) NSMutableDictionary   *colors;
@property (nonatomic, strong) NSDictionary          *images;

- (UIColor *)colorForKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
