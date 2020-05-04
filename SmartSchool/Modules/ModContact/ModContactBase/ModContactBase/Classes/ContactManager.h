//
//  ContactManager.h
//  Menci
//
//  Created by 唐琦 on 2018/2/7.
//  Copyright © 2018年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <Contacts/Contacts.h>
#import <LibDataModel/ContactData.h>
#import <LibDataModel/ContactLocalData.h>
#import <LibDataModel/FriendRequestData.h>

#define kContactSectionKey      [NSString stringWithFormat:@"%@.section", [[UIApplication sharedApplication] appBundleID]]
#define kContactListKey         [NSString stringWithFormat:@"%@.list", [[UIApplication sharedApplication] appBundleID]]

NS_ASSUME_NONNULL_BEGIN

@interface ContactManager : BaseManager
@property (nonatomic, readonly) NSInteger           myStatus;
@property (nonatomic, readonly) NSArray             *statusMenu;

- (void)startContactSelectWithType:(NSString *)type
                             limit:(nullable NSNumber *)limit
                        completion:(nullable CommonBlock)completion;

#pragma mark - 本地数据
+ (NSArray *)colorArray;

#pragma mark - 线上好友相关
// 返回所有线上好友(接口顺序)
- (NSArray *)allOnlineContacts;
// 返回所有线上好友数据(首字母分组排序)
- (NSArray *)allSortOnlineContacts;
// 根据关键字搜索线上好友
- (ContactData *)onlineContactsWithSearchText:(NSString *)text;

#pragma mark - 本地联系人相关
// 返回所有本地联系人数据
- (NSArray *)allOfflineContacts;
// 根据名字搜索本地联系人
- (nullable NSArray<CNContact *> *)contactsWithName:(NSString *)name;
// 模糊查询本地联系人
- (void)similarName:(NSString *)string
         completion:(CommonBlock)completion;

#pragma mark - 好友申请相关
// 返回所有好友申请(时间顺序排列)
- (NSArray *)allFriendRequest;
// 根据好友申请id查找对应的好友申请记录
- (nullable FriendRequestData *)requestWithId:(NSString *)requestid;
// 删除好友申请
- (void)deleteFriendRequestData:(FriendRequestData *)data;
;
// 清除所有好友申请记录
- (void)clearAllUnreadFriendRequests;

#pragma mark - 用户状态相关
// 根据用户id返回状态
- (nullable ContactStatusData *)statusWithUid:(NSInteger)uid;

#pragma mark - 数据请求
- (void)requestAccessWithCompletion:(nullable CommonBlock)completion;

- (void)requestContactsWithCompletion:(nullable CommonBlock)completion;

- (void)requestMyStatusWithAction:(YuCloudDataActions)action
                           status:(NSInteger)status
                       completion:(nullable CommonBlock)completion;

- (void)requestContactsStatusMenuWithCompletion:(nullable CommonBlock)completion;

- (void)requestFriendConnectWith:(NSString *)userid
                         message:(nullable NSString *)message
                      completion:(CommonBlock)completion;

- (void)respondFriendRequestWith:(NSString *)requestid
                          accept:(BOOL)accept
                      completion:(CommonBlock)completion;

- (void)requestFriendWithStartid:(NSString *)startid completion:(CommonBlock)completion;

@end

NS_ASSUME_NONNULL_END
