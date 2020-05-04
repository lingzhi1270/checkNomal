//
//  CacheDataSource.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/19.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <ViroyalCoreDataSource/VICoreDataSource.h>

// 导入或生成新的数据模型时，引入头文件
#import "AppEntity+CoreDataClass.h"
#import "UserEntity+CoreDataClass.h"
#import "PayOrderEntity+CoreDataClass.h"
#import "ContactOnlineEntity+CoreDataClass.h"
#import "ContactLocalEntity+CoreDataClass.h"
#import "FriendRequestEntity+CoreDataClass.h"
#import "ThemeEntity+CoreDataClass.h"
#import "FavEntity+CoreDataClass.h"
#import "NewsEntity+CoreDataClass.h"
#import "BannerEntity+CoreDataClass.h"
#import "CityEntity+CoreDataClass.h"
#import "AdEntity+CoreDataClass.h"

typedef void (^CacheBlock)(BOOL success, NSArray * _Nullable resultArray);

NS_ASSUME_NONNULL_BEGIN
//// 主题相关
//#define APP_THEME_KEY                   [NSString stringWithFormat:@"com.viroyal.theme.loginid=%@", ACCOUNT_USERID]
//#define APP_THEME_UID                   @"com.viroyal.theme.data"
//// User相关
//#define APP_USER_KEY                    [NSString stringWithFormat:@"com.viroyal.user.loginid=%@", ACCOUNT_USERID]
//#define APP_USER_UID                    @"com.viroyal.user.data"
//// App模块相关
//#define APP_APP_KEY                     [NSString stringWithFormat:@"com.viroyal.app.loginid=%@", ACCOUNT_USERID]
//#define APP_APP_UID                     @"com.viroyal.app.data"
//// 启动图相关
//#define APP_ADVERTISEMENT_KEY           [NSString stringWithFormat:@"com.viroyal.advertisement.loginid=%@", ACCOUNT_USERID]
//#define APP_ADVERTISEMENT_UID           @"com.viroyal.advertisement.data"
//// 轮播图相关
//#define APP_BANNER_KEY                  [NSString stringWithFormat:@"com.viroyal.banner.loginid=%@", ACCOUNT_USERID]
//#define APP_BANNER_UID                  @"com.viroyal.banner.data"
//// 新闻相关
//#define APP_NEWS_KEY                    [NSString stringWithFormat:@"com.viroyal.news.loginid=%@", ACCOUNT_USERID]
//#define APP_NEWS_UID                    @"com.viroyal.news.data"
//// 联系人相关
//#define APP_CONTACT_KEY                 [NSString stringWithFormat:@"com.viroyal.contact.loginid=%@", ACCOUNT_USERID]
//#define APP_CONTACT_ONLINE_UID          @"com.viroyal.contact.online"
//#define APP_CONTACT_OFFLINE_UID         @"com.viroyal.contact.local"
//// 好友申请相关
//#define APP_FRIEND_KEY                  [NSString stringWithFormat:@"com.viroyal.friend.loginid=%@", ACCOUNT_USERID]
//#define APP_FRIEND_UID                  @"com.viroyal.friend.data"
//// 收藏相关
//#define APP_FAV_KEY                     [NSString stringWithFormat:@"com.viroyal.fav.loginid=%@", ACCOUNT_USERID]
//#define APP_FAV_UID                     @"com.viroyal.fav.data"
//// 天气相关
//#define APP_WEATHER_KEY                 [NSString stringWithFormat:@"com.viroyal.weather.loginid=%@", ACCOUNT_USERID]
//#define APP_WEATHER_CITY_UID            @"com.viroyal.weather.city"
//// 签到相关
//#define APP_CHECKIN_KEY                 [NSString stringWithFormat:@"com.viroyal.checkin.loginid=%@", ACCOUNT_USERID]
//// 车辆相关
//#define APP_CAR_KEY                     [NSString stringWithFormat:@"com.viroyal.car.loginid=%@", ACCOUNT_USERID]
//#define APP_CAR_UID                     @"com.viroyal.car.data"
//// 通行证相关
//#define APP_PASSPORT_KEY                [NSString stringWithFormat:@"com.viroyal.passpor.loginid=%@t", ACCOUNT_USERID]
//#define APP_PASSPORT_CATEGORY_UID       @"com.viroyal.passport.category"
//#define APP_PASSPORT_ACTIVITY_UID       @"com.viroyal.passport.activity"
//#define APP_PASSPORT_MINE_UID           @"com.viroyal.passport.mine"
//#define APP_PASSPORT_QRIMAGE_UID        @"com.viroyal.passport.qrImage"
//// 照片采集相关
//#define APP_CAMERA_KEY                  [NSString stringWithFormat:@"com.viroyal.avatar.loginid=%@", ACCOUNT_USERID]
//#define APP_CAMERA_TASK_UID             @"com.viroyal.avatar.task"
//#define APP_CAMERA_PHOTO_UID            @"com.viroyal.avatar.photo"
//// 人像识别相关
//#define APP_FACE_KEY                    [NSString stringWithFormat:@"com.viroyal.face.loginid=%@", ACCOUNT_USERID]
//#define APP_FACE_LIST_UID               @"com.viroyal.face.list"
//// 视频播放相关
//#define APP_VIDEO_PLAYBACK_KEY          [NSString stringWithFormat:@"com.viroyal.video_playback.loginid=%@", ACCOUNT_USERID]
//// 视频直播相关
//#define APP_VIDEO_LIVE_KEY              [NSString stringWithFormat:@"com.viroyal.video_live.loginid=%@", ACCOUNT_USERID]
//// 联系人相关
//#define APP_CONTACTS_KEY                [NSString stringWithFormat:@"com.viroyal.contacts.loginid=%@", ACCOUNT_USERID]
//// 智能门锁相关
//#define APP_SMART_LOCKER_KEY            [NSString stringWithFormat:@"com.viroyal.smart_locker.loginid=%@", ACCOUNT_USERID]
//// 支付相关
//#define APP_PAY_KEY                     [NSString stringWithFormat:@"com.viroyal.pay.loginid=%@", ACCOUNT_USERID]
//#define APP_PAY_UID                     @"com.viroyal.pay.data"
//// 导航相关
//#define APP_NAVI_KEY                    [NSString stringWithFormat:@"com.viroyal.navigation.loginid=%@", ACCOUNT_USERID]
//#define APP_NAVI_STRATEGY_UID           @"com.viroyal.navigation.strategy"

@interface CacheDataSource : VIDataSource

- (NSArray *)getDatasWithEntityName:(NSString *)entityName
                          predicate:(NSPredicate *)predicate
                    sortDescriptors:(NSArray <NSSortDescriptor *> *)sortDescriptors;
@end

//@interface CacheManager : BaseManager
//
///**
// 新增数据(同步)
//
// @param data 数据的数组
// @param uid 存储键值
// @param key 主键
// */
//- (void)saveData:(NSArray *)data
//          forUid:(NSString *)uid
//          forKey:(NSString *)key;
//
///**
// 新增数据(异步)
//
// @param data 数据的数组
// @param uid 存储键值
// @param key 主键
// @param completion 回调
// */
//- (void)saveData:(NSArray *)data
//          forUid:(NSString *)uid
//          forKey:(NSString *)key
//      completion:(CacheBlock)completion;
//
///**
// 删除某个键值下的单个数据
//
// @param data 数据
// @param uid 存储键值
// @param key 主键
// @param completion 回调
// */
//- (void)deleteData:(id)data
//            forUid:(NSString *)uid
//            forKey:(NSString *)key
//        completion:(CacheBlock)completion;
//
//
//
///**
// 删除某个键值下所有数据
//
// @param uid 存储键值
// @param key 主键
// @param completion 回调
// */
//- (void)deleteAllDataForUid:(NSString *)uid
//                     forKey:(NSString *)key
//                 completion:(CacheBlock)completion;
//
///**
// 获取某个键值下所有数据(同步)
//
// @param uid 存储键值
// @param key 主键
// */
//- (NSArray *)getDataForUid:(NSString *)uid
//                    forKey:(NSString *)key;
//
///**
// 获取某个键值下所有数据(异步)
//
// @param uid 存储键值
// @param key 主键
// @param completion 回调
// */
//- (void)getDataForUid:(NSString *)uid
//               forKey:(NSString *)key
//           completion:(CacheBlock)completion;
//
///**
// 更新某个键值下的单个数据
//
// @param data 数据
// @param uid 存储键值
// @param key 主键
// @param completion 回调
// */
//- (void)updateData:(id)data
//            forUid:(NSString *)uid
//            forKey:(NSString *)key
//        completion:(CacheBlock)completion;
//
//@end

NS_ASSUME_NONNULL_END
