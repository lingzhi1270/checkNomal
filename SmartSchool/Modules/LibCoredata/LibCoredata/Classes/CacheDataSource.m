//
//  CacheDataSource.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/19.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "CacheDataSource.h"
#import <YYKit/YYCache.h>
#import <CommonCrypto/CommonDigest.h>
#import <LibDataModel/DataHeader.h>"

NSString *databaseKey  = @"1030";

@interface CoreDataConfiguration : NSObject
@property (nonatomic, strong) NSManagedObjectContext        *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator  *persistentStoreCoordinator;

+ (CoreDataConfiguration *)shareConfiguration;

@end

@implementation CoreDataConfiguration

+ (CoreDataConfiguration *)shareConfiguration {
    static dispatch_once_t onceToken;
    static CoreDataConfiguration *configuration = nil;
    dispatch_once(&onceToken, ^{
        configuration = [[CoreDataConfiguration alloc] init];
    });
    
    return configuration;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        NSManagedObjectModel *model = [self managedObjectModel];
        NSDictionary *hashs = model.entityVersionHashesByName;
        NSUInteger hash = 0;
        for (NSData *item in hashs.objectEnumerator) {
            NSString *md5 = [item MD5];
            hash += md5.hash;
        }
        
        hash += databaseKey.hash;
        
        if ([NSUserDefaults databaseHash] != hash) {
            [[NSFileManager defaultManager] removeItemAtURL:[self storeUrl] error:nil];
            [NSUserDefaults saveDatabaseHash:hash];
        }
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        NSError *error;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeUrl] options:nil error:&error]) {
            if (error != nil) {
//                DDLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
            }
        }
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel {
    NSString *myBundlePath = [[NSBundle mainBundle] pathForResource:@"LibCoredata" ofType:@"bundle"];
    NSBundle *myBundle = [NSBundle bundleWithPath:myBundlePath];
    
    NSURL *modelURL = [myBundle URLForResource:@"Model" withExtension:@"momd"];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)storeUrl {
    NSURL *url = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"data.sqlite"];
//    DDLog(@"Data base location: %@", url);
    return url;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    return _managedObjectContext;
}

@end

@interface CacheDataSource ()

@end

@implementation CacheDataSource

+ (instancetype)sharedClient {
    static dispatch_once_t onceToken;
    static CacheDataSource *client = nil;
    dispatch_once(&onceToken, ^{
        client = [[CacheDataSource alloc] initWithManagedObjectContext:[CoreDataConfiguration shareConfiguration].managedObjectContext
                                                           coordinator:[CoreDataConfiguration shareConfiguration].persistentStoreCoordinator];
    });
    
    return client;
}

- (NSString *)accountUserId {
    Class accountClass = NSClassFromString(@"AccountManager");
    if (accountClass && [accountClass respondsToSelector:@selector(shareManager)]) {
        Class manager = [accountClass performSelector:@selector(shareManager)];
        if (manager && [manager respondsToSelector:@selector(fetchAccountInfo)]) {
            id accountInfo = [manager performSelector:@selector(fetchAccountInfo)];
            if (accountInfo && [accountInfo valueForKey:@"union_id"]) {
                NSString *userId = [accountInfo valueForKey:@"union_id"];
                
                return userId;
            }
        }
    }

    NSAssert(NO, @"获取用户userid失败，请检查映射方式获取用户userid的代码");
}

#pragma mark - 重写父类添加和删除方法
// 添加新数据
- (NSManagedObject *)onAddObject:(id)object managedObjectContext:(NSManagedObjectContext *)managedObjectContex {
    // 模块控制类
    if ([object isKindOfClass:[AppData class]]) {
        AppData *data = (AppData *)object;
        NSFetchRequest *request = [AppEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", data.uid, [self accountUserId]];
        
        AppEntity *info = [[managedObjectContex executeFetchRequest:request error:nil] firstObject];
        if (!info) {
            info = [NSEntityDescription insertNewObjectForEntityForName:[AppEntity entityName]
                                                 inManagedObjectContext:managedObjectContex];
        }
        
        info.uid                = data.uid;
        info.name_en            = data.name_en;
        info.name_chs           = data.name_chs;
        info.homeUrl            = data.homeUrl;
        info.iconUrl            = data.iconUrl;
        info.type               = data.type;
        info.categoryId         = data.categoryId;
        info.categoryIndex      = data.categoryIndex;
        info.categoryName       = data.categoryName;
        info.homeIndex          = data.homeIndex;
        info.admin              = data.admin;
        info.qrKey              = data.qrKey;
        info.loginid            = [self accountUserId];
        
        return info;
    }
    // 用户信息
    else if ([object isKindOfClass:[UserData class]]) {
        UserData *data = (UserData *)object;
        NSFetchRequest *request = [UserEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"userid == %@ && loginid == %@", data.userid, [self accountUserId]];
        
        UserEntity *info = [[managedObjectContex executeFetchRequest:request error:nil] firstObject];
        if (!info) {
            info = [NSEntityDescription insertNewObjectForEntityForName:[UserEntity entityName]
                                                 inManagedObjectContext:managedObjectContex];
        }
        
        info.userid             = data.userid;
        info.name               = data.name;
        info.nickname           = data.nickname;
        info.avatarUrl          = data.avatarUrl;
        info.im_id              = data.im_id;
        info.school             = data.school;
        info.relation           = data.relation;
        info.refreshKey         = data.refreshKey;
        info.followed_count     = data.followed_count.integerValue;
        info.follower_count     = data.follower_count.integerValue;
        info.topic_count        = data.topic_count.integerValue;
        info.loginid            = [self accountUserId];
        
        return info;
    }
    // 线上好友
    else if ([object isKindOfClass:[ContactData class]]) {
        ContactData *data = (ContactData *)object;
        NSFetchRequest *request = [ContactOnlineEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %ld && loginid == %@", data.uid.integerValue, [self accountUserId]];
        
        ContactOnlineEntity *info = [[managedObjectContex executeFetchRequest:request error:nil] firstObject];
        if (!info) {
            info = [NSEntityDescription insertNewObjectForEntityForName:[ContactOnlineEntity entityName]
                                                 inManagedObjectContext:managedObjectContex];
        }
        
        info.uid                = data.uid;
        info.category           = data.category;
        info.phone              = data.phone;
        info.section            = data.section;
        info.title              = data.title;
        info.index              = data.index;
        info.avatarUrl          = data.avatarUrl;
        info.placeholder        = data.placeholder;
        info.note               = data.note;
        info.shortNo            = data.shortNo;
        info.email              = data.email;
        info.status             = data.status;
        info.sectionKey         = data.sectionKey;
        info.pinyin             = data.pinyin;
        info.shengmu            = data.shengmu;
        info.givenName          = data.givenName;
        info.givenPinyin        = data.givenPinyin;
        info.orgName            = data.orgName;
        info.orgNamePinyin      = data.orgNamePinyin;
        info.loginid            = [self accountUserId];
        
        return info;
    }
    // 通讯录好友
    else if ([object isKindOfClass:[ContactLocalData class]]) {
        ContactLocalData *data = (ContactLocalData *)object;
        NSFetchRequest *request = [ContactLocalEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %ld && loginid == %@", data.uid.integerValue, [self accountUserId]];
        
        ContactLocalEntity *info = [[managedObjectContex executeFetchRequest:request error:nil] firstObject];
        if (!info) {
            info = [NSEntityDescription insertNewObjectForEntityForName:[ContactLocalEntity entityName]
                                                 inManagedObjectContext:managedObjectContex];
        }
        
        info.uid                = data.uid;
        info.phone              = data.phone;
        info.sectionKey         = data.sectionKey;
        info.title              = data.title;
        info.sectionKey         = data.sectionKey;
        info.pinyin             = data.pinyin;
        info.shengmu            = data.shengmu;
        info.givenName          = data.givenName;
        info.givenPinyin        = data.givenPinyin;
        info.orgName            = data.orgName;
        info.orgNamePinyin      = data.orgNamePinyin;
        info.loginid            = [self accountUserId];
        
        return info;
    }
    // 好友申请
    else if ([object isKindOfClass:[FriendRequestData class]]) {
        FriendRequestData *data = (FriendRequestData *)object;
        NSFetchRequest *request = [FriendRequestEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"requestid == %@ && loginid == %@", data.requestid, [self accountUserId]];
        
        FriendRequestEntity *info = [[managedObjectContex executeFetchRequest:request error:nil] firstObject];
        if (!info) {
            info = [NSEntityDescription insertNewObjectForEntityForName:[FriendRequestEntity entityName]
                                                 inManagedObjectContext:managedObjectContex];
        }
        
        info.requestid          = data.requestid;
        info.userid             = data.userid;
        info.name               = data.name;
        info.message            = data.message;
        info.accepted           = data.accepted;
        info.date               = data.date;
        info.avatarUrl          = data.avatarUrl;
        info.type               = data.type;
        info.readStatus         = data.readStatus;
        info.loginid            = [self accountUserId];
        
        return info;
    }
    // 收藏数据
    else if ([object isKindOfClass:[FavData class]]) {
        FavData *data = (FavData *)object;
        NSFetchRequest *request = [FavEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %ld && loginid == %@", data.uid, [self accountUserId]];
        
        FavEntity *info = [[managedObjectContex executeFetchRequest:request error:nil] firstObject];
        if (!info) {
            info = [NSEntityDescription insertNewObjectForEntityForName:[FavEntity entityName]
                                                 inManagedObjectContext:managedObjectContex];
        }
        
        info.uid                = data.uid;
        info.title              = data.title;
        info.content            = data.content;
        info.imageUrl           = data.imageUrl;
        info.type               = data.type;
        info.overview           = data.overview;
        info.loginid            = [self accountUserId];
        
        return info;
    }
    else {
        return nil;
    }
}

// 删除数据
- (void)onDeleteObject:(id)object managedObjectContext:(NSManagedObjectContext *)managedObjectContex {
    // 首页模块
    if ([object isKindOfClass:[AppData class]]) {
        AppData *data = (AppData *)object;
        NSFetchRequest *request = [AppEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %@ && loginid == %@", data.uid, [self accountUserId]];
        AppEntity *item = [managedObjectContex executeFetchRequest:request error:nil].firstObject;
        
        if (item && !item.isDeleted) {
            [managedObjectContex deleteObject:item];
        }
    }
    // 用户信息
    else if ([object isKindOfClass:[UserData class]]) {
        UserData *data = (UserData *)object;
        NSFetchRequest *request = [UserEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"userid == %@ && loginid == %@", data.userid, [self accountUserId]];
        UserEntity *item = [managedObjectContex executeFetchRequest:request error:nil].firstObject;
        
        if (item && !item.isDeleted) {
            [managedObjectContex deleteObject:item];
        }
    }
    // 线上好友
    else if ([object isKindOfClass:[ContactData class]]) {
        ContactData *data = (ContactData *)object;
        NSFetchRequest *request = [ContactOnlineEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %ld && loginid == %@", data.uid.integerValue, [self accountUserId]];
        ContactOnlineEntity *item = [managedObjectContex executeFetchRequest:request error:nil].firstObject;
        
        if (item && !item.isDeleted) {
            [managedObjectContex deleteObject:item];
        }
    }
    // 通讯录好友
    else if ([object isKindOfClass:[ContactLocalData class]]) {
        ContactLocalData *data = (ContactLocalData *)object;
        NSFetchRequest *request = [ContactLocalEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %ld && loginid == %@", data.uid.integerValue, [self accountUserId]];
        ContactLocalEntity *item = [managedObjectContex executeFetchRequest:request error:nil].firstObject;
        
        if (item && !item.isDeleted) {
            [managedObjectContex deleteObject:item];
        }
    }
    // 好友申请
    else if ([object isKindOfClass:[FriendRequestData class]]) {
        FriendRequestData *data = (FriendRequestData *)object;
        NSFetchRequest *request = [FriendRequestEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"requestid == %@ && loginid == %@", data.requestid, [self accountUserId]];
        FriendRequestEntity *item = [managedObjectContex executeFetchRequest:request error:nil].firstObject;
        
        if (item && !item.isDeleted) {
            [managedObjectContex deleteObject:item];
        }
    }
    // 收藏数据
    else if ([object isKindOfClass:[FavData class]]) {
        FavData *data = (FavData *)object;
        NSFetchRequest *request = [FavEntity fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %ld && loginid == %@", data.uid, [self accountUserId]];
        FavEntity *item = [managedObjectContex executeFetchRequest:request error:nil].firstObject;
        
        if (item && !item.isDeleted) {
            [managedObjectContex deleteObject:item];
        }
    }
}

#pragma mark - 查询数据库
- (NSArray *)getDatasWithEntityName:(NSString *)entityName
                          predicate:(NSPredicate *)predicate
                    sortDescriptors:(NSArray <NSSortDescriptor *> *)sortDescriptors {
    
    // 获取Coredata表名
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:self.managedObjectContext];
    // 配置搜索的搜索范围、筛选条件、排序规则
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = predicate;
    request.sortDescriptors = sortDescriptors;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:nil];
    // 转换成数据模型
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    
    // 首页模块
    if ([entityName isEqualToString:[AppEntity entityName]]) {
        for (AppEntity *entity in array) {
            [tempArr addObject:[self appWithEntity:entity]];
        }
    }
    // 用户信息
    else if ([entityName isEqualToString:[UserEntity entityName]]) {
        for (UserEntity *entity in array) {
            [tempArr addObject:[self userDataWithEntity:entity]];
        }
    }
    // 线上好友
    else if ([entityName isEqualToString:[ContactOnlineEntity entityName]]) {
        for (ContactOnlineEntity *entity in array) {
            [tempArr addObject:[self contactDataWithEntity:entity]];
        }
    }
    // 通讯录好友
    else if ([entityName isEqualToString:[ContactLocalEntity entityName]]) {
        for (ContactLocalEntity *entity in array) {
            [tempArr addObject:[self contactLocalDataWithEntity:entity]];
        }
    }
    // 好友申请
    else if ([entityName isEqualToString:[FriendRequestEntity entityName]]) {
        for (FriendRequestEntity *entity in array) {
            [tempArr addObject:[self friendReuqestDataWithEntity:entity]];
        }
    }
    else if ([entityName isEqualToString:[FavEntity entityName]]) {
        for (FavEntity *entity in array) {
            [tempArr addObject:[self favDataWithEntity:entity]];
        }
    }

    return [NSArray arrayWithArray:tempArr];
}

#pragma mark - 数据库类型转换为数据模型
- (AppData *)appWithEntity:(AppEntity *)entity {
    AppData *app = [AppData new];
    
    app.uid                = entity.uid;
    app.name_en            = entity.name_en;
    app.name_chs           = entity.name_chs;
    app.homeUrl            = entity.homeUrl;
    app.iconUrl            = entity.iconUrl;
    app.type               = entity.type;
    app.categoryId         = entity.categoryId;
    app.categoryIndex      = entity.categoryIndex;
    app.categoryName       = entity.categoryName;
    app.homeIndex          = entity.homeIndex;
    app.admin              = entity.admin;
    app.qrKey              = entity.qrKey;
    
    return app;
}

- (UserData *)userDataWithEntity:(UserEntity *)entity {
    UserData *user = [UserData new];
    
    user.userid             = entity.userid;
    user.name               = entity.name;
    user.nickname           = entity.nickname;
    user.avatarUrl          = entity.avatarUrl;
    user.im_id              = entity.im_id;
    user.school             = entity.school;
    user.relation           = entity.relation;
    user.refreshKey         = entity.refreshKey;
    user.followed_count     = @(entity.followed_count);
    user.follower_count     = @(entity.follower_count);
    user.topic_count        = @(entity.topic_count);
    
    return user;
}

- (ContactData *)contactDataWithEntity:(ContactOnlineEntity *)entity {
    ContactData *contact = [ContactData new];
    
    contact.uid                = @(entity.uid);
    contact.category           = entity.category;
    contact.phone              = entity.phone;
    contact.section            = entity.section;
    contact.title              = entity.title;
    contact.index              = entity.index;
    contact.avatarUrl          = entity.avatarUrl;
    contact.placeholder        = entity.placeholder;
    contact.note               = entity.note;
    contact.shortNo            = entity.shortNo;
    contact.email              = entity.email;
    contact.status             = entity.status;
    contact.sectionKey         = entity.sectionKey;
    contact.pinyin             = entity.pinyin;
    contact.shengmu            = entity.shengmu;
    contact.givenName          = entity.givenName;
    contact.givenPinyin        = entity.givenPinyin;
    contact.orgName            = entity.orgName;
    contact.orgNamePinyin      = entity.orgNamePinyin;
    
    return contact;
}

- (ContactLocalData *)contactLocalDataWithEntity:(ContactLocalEntity *)entity {
    ContactLocalData *local = [ContactLocalData new];
    
    local.uid                = @(entity.uid);
    local.phone              = entity.phone;
    local.sectionKey         = entity.sectionKey;
    local.title              = entity.title;
    local.sectionKey         = entity.sectionKey;
    local.pinyin             = entity.pinyin;
    local.shengmu            = entity.shengmu;
    local.givenName          = entity.givenName;
    local.givenPinyin        = entity.givenPinyin;
    local.orgName            = entity.orgName;
    local.orgNamePinyin      = entity.orgNamePinyin;
    
    return local;
}

- (FriendRequestData *)friendReuqestDataWithEntity:(FriendRequestEntity *)entity {
    FriendRequestData *friendRequest = [FriendRequestData new];
    
    friendRequest.requestid     = entity.requestid;
    friendRequest.userid        = entity.userid;
    friendRequest.name          = entity.name;
    friendRequest.message       = entity.message;
    friendRequest.accepted      = entity.accepted;
    friendRequest.date          = entity.date;
    friendRequest.avatarUrl     = entity.avatarUrl;
    friendRequest.type          = entity.type;
    friendRequest.readStatus    = entity.readStatus;
    
    return friendRequest;
}

- (FavData *)favDataWithEntity:(FavEntity *)entity {
    FavData *fav = [FavData new];
    
    fav.uid                = entity.uid;
    fav.title              = entity.title;
    fav.content            = entity.content;
    fav.imageUrl           = entity.imageUrl;
    fav.type               = entity.type;
    fav.overview           = entity.overview;
    
    return fav;
}

@end

//@interface CacheManager ()
//@property (nonatomic, strong) YYCache *cache;
//
//@end
//
//@implementation CacheManager
//
//+ (instancetype)shareManager {
//    static dispatch_once_t onceToken;
//    static CacheManager *manager = nil;
//    dispatch_once(&onceToken, ^{
//        manager = [[CacheManager alloc] init];
//    });
//
//    return manager;
//}
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
//          forKey:(NSString *)key {
//    self.cache = [YYCache cacheWithName:key];
//    if (!self.cache) {
//        self.cache = [[YYCache alloc] initWithName:key];
//    }
//
//    [self.cache setObject:data forKey:uid];
//}
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
//      completion:(CacheBlock)completion {
//    self.cache = [YYCache cacheWithName:key];
//    if (!self.cache) {
//        self.cache = [[YYCache alloc] initWithName:key];
//    }
//
//    [self.cache setObject:data forKey:uid withBlock:^{
//        if (completion) {
//            completion(YES, nil);
//        }
//    }];
//}
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
//        completion:(CacheBlock)completion {
//    self.cache = [YYCache cacheWithName:key];
//    if (!self.cache) {
//        self.cache = [[YYCache alloc] initWithName:key];
//    }
//
//    // 判断是否存在缓存
//    [self.cache containsObjectForKey:uid withBlock:^(NSString * _Nonnull key, BOOL contains) {
//        if (contains) {
//            [self.cache objectForKey:uid withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
//                // 找到要删除的数据
//                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:(NSArray *)object];
//                NSInteger index = -1;
//                for (id obj in tempArray) {
//                    if ([obj respondsToSelector:@selector(uid)]) {
//                        if ([[obj performSelector:@selector(uid)] isEqualToString:[data performSelector:@selector(uid)]]) {
//                            index = [tempArray indexOfObject:obj];
//
//                            break;
//                        }
//                    }
//                }
//                // 删除数据
//                if (index > -1) {
//                    [tempArray removeObjectAtIndex:index];
//                }
//
//                // 重新存储数据
//                NSArray *array = [NSArray arrayWithArray:tempArray];
//                [self.cache setObject:array forKey:uid withBlock:^{
//                    if (completion) {
//                        completion(YES, nil);
//                    }
//                }];
//            }];
//        }
//        else {
//            if (completion) {
//                completion(NO, nil);
//            }
//        }
//    }];
//}
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
//                 completion:(CacheBlock)completion {
//    self.cache = [YYCache cacheWithName:key];
//    if (!self.cache) {
//        self.cache = [[YYCache alloc] initWithName:key];
//    }
//
//    // 清空数据
//    [self.cache setObject:@[] forKey:uid withBlock:^{
//        if (completion) {
//            completion(YES, nil);
//        }
//    }];
//}
//
//- (NSArray *)getDataForUid:(NSString *)uid
//                    forKey:(NSString *)key {
//    self.cache = [YYCache cacheWithName:key];
//    if (!self.cache) {
//        self.cache = [[YYCache alloc] initWithName:key];
//    }
//
//    // 判断是否存在缓存
//    if ([self.cache containsObjectForKey:uid]) {
//        NSArray *array = (NSArray*)[self.cache objectForKey:uid];
//        return array;
//    }
//    else {
//        return @[];
//    }
//}
//
///**
// 获取某个键值下所有数据
//
// @param uid 存储键值
// @param key 主键
// @param completion 回调
// */
//- (void)getDataForUid:(NSString *)uid
//               forKey:(NSString *)key
//           completion:(CacheBlock)completion {
//    self.cache = [YYCache cacheWithName:key];
//    if (!self.cache) {
//        self.cache = [[YYCache alloc] initWithName:key];
//    }
//
//    // 判断是否存在缓存
//    [self.cache containsObjectForKey:uid withBlock:^(NSString * _Nonnull key, BOOL contains) {
//        if (contains) {
//            [self.cache objectForKey:uid withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
//                NSArray *array = (NSArray*)object;
//                if (completion) {
//                    completion(YES, array);
//                }
//            }];
//        }
//        else {
//            if (completion) {
//                completion(NO, @[]);
//            }
//        }
//    }];
//}
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
//        completion:(CacheBlock)completion {
//    self.cache = [YYCache cacheWithName:key];
//    if (!self.cache) {
//        self.cache = [[YYCache alloc] initWithName:key];
//    }
//
//    // 判断是否存在缓存
//    [self.cache containsObjectForKey:uid withBlock:^(NSString * _Nonnull key, BOOL contains) {
//        if (contains) {
//            [self.cache objectForKey:uid withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
//                // 找到要更新的数据
//                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:(NSArray *)object];
//                NSInteger index = -1;
//                for (id obj in tempArray) {
//                    if ([obj respondsToSelector:@selector(uid)]) {
//                        if ([[obj performSelector:@selector(uid)] isEqualToString:[data performSelector:@selector(uid)]]) {
//                            index = [tempArray indexOfObject:obj];
//
//                            break;
//                        }
//                    }
//                }
//                // 更新数据
//                if (index > -1) {
//                    [tempArray replaceObjectAtIndex:index withObject:data];
//                }
//
//                // 重新存储数据
//                NSArray *array = [NSArray arrayWithArray:tempArray];
//                [self.cache setObject:array forKey:uid withBlock:^{
//                    if (completion) {
//                        completion(YES, nil);
//                    }
//                }];
//            }];
//        }
//        else {
//            if (completion) {
//                completion(NO, nil);
//            }
//        }
//    }];
//}
//
//@end
