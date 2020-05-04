//
//  AppManager.h
//  Unilife
//
//  Created by 唐琦 on 2019/8/22.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <LibCoredata/CacheDataSource.h>
#import <LibDataModel/AppData.h>

NS_ASSUME_NONNULL_BEGIN

#define APPS_NUMBER_PER_LINE    4
#define APPS_MAX_LINE           3

typedef enum : NSUInteger {
    PassCategoryTypeLibry,
    PassCategoryTypeClassRoom,
    PassCategoryTypeMeeting,
    PassCategoryTypeActivity,
    PassCategoryTypeNone
} PassCategoryType;

@interface AppManager : BaseManager
// 添加或更新模块
- (void)addAppDatas:(NSArray *)array;
// 返回所有模块信息
- (NSArray *)allApps;
// 返回所有首页模块信息
- (NSArray *)allHomeApps;
// 根据name匹配模块名
- (NSString *)similarName:(NSString *)name;
// 根据uid筛选模块信息
- (AppData *)appWithUid:(NSString *)uid;
// 获取所有模块的图片链接
- (NSArray *)allAppImages;
// 根据扫码结果返回对应模块信息
- (AppData *)appToProcessQRKey:(NSString *)key;

- (UIImage *)qrImageForId:(NSString *)uid;

// 联系人
- (void)fetchAllContactsWithCompletion:(nullable CommonBlock)completion;

@end

NS_ASSUME_NONNULL_END
