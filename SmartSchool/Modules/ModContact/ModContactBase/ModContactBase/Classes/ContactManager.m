//
//  ContactManager.m
//  Menci
//
//  Created by 唐琦 on 2018/2/7.
//  Copyright © 2018年 南京远御网络科技有限公司. All rights reserved.
//

#import "ContactManager.h"
#import <ContactsUI/ContactsUI.h>
#import <ModLoginBase/AccountManager.h>
#import <LibCoredata/CacheDataSource.h>

@interface ContactManager ()
@property (nonatomic, strong) CNContactStore        *contactStore;
@property (nonatomic, assign) NSInteger             myStatus;
@property (nonatomic, copy)   NSArray               *statusMenu;
@property (nonatomic, strong) NSTimer               *timer;
@property (nonatomic, assign) BOOL                  listing;

@property (nonatomic, copy)   CommonBlock           contactSelectCompletion;


@end

@implementation ContactManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static ContactManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [ContactManager new];
    });
    
    return client;
}

+ (NSArray *)colorArray {
    return @[[UIColor colorWithRGB:0x5ba2ee],
             [UIColor colorWithRGB:0x44b0ca],
             [UIColor colorWithRGB:0x12a988],
             [UIColor colorWithRGB:0xe7762b],
             [UIColor colorWithRGB:0x49bd70],
             [UIColor colorWithRGB:0xae5dc3]];
}

- (instancetype)init {
    if (self = [super init]) {
        self.contactStore = [CNContactStore new];
        
        [[AccountManager shareManager] addObserver:self
                                        forKeyPath:@"accountStatus"
                                           options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                           context:nil];
        
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"accountStatus"]) {
        if ([[AccountManager shareManager] isServerSignin]) {
            [self startListTimer];
            
            [self requestContactsStatusMenuWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                if (success) {
                    NSArray *data = info[@"data"];
                    NSMutableArray *arr = [NSMutableArray new];
                    for (NSDictionary *item in data) {
                        [arr addObject:[ContactStatusData statusWithData:item]];
                    }
                    self.statusMenu = arr.copy;
                    
                    [self requestMyStatusWithAction:YuCloudDataList
                                             status:0
                                         completion:^(BOOL success, NSDictionary * _Nullable info) {
                                             if (success) {
                                                 NSNumber *number = info[@"status"];
                                                 self.myStatus = [number integerValue];
                                             }
                                         }];
                }
            }];
        }
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)noti {
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        [self startParse];
    }
}

#pragma mark - 选择联系人
- (void)startContactSelectWithType:(NSString *)type
                             limit:(nullable NSNumber *)limit
                        completion:(CommonBlock)completion {
    self.contactSelectCompletion = completion;

    if ([type isEqualToString:@"phone"]) {
        CNContactPickerViewController *picker = [[CNContactPickerViewController alloc] init];
        picker.delegate = self;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [TopViewController presentViewController:picker
                                        animated:YES
                                      completion:nil];
    }
    else if ([type isEqualToString:@"app"]) {
        Class class = NSClassFromString(@"ModContactStyle1ViewController");
        if (class) {
            UIViewController *org = [[class alloc] init];
            if ([org respondsToSelector:NSSelectorFromString(@"initWithCategory:grouped:")]) {
                [org performSelector:@selector(initWithCategory:grouped:) withObject:@"" withObject:@YES];
            }
            [org setValue:self forKey:@"delegate"];
            
            [TopViewController presentViewController:[[MainNavigationController alloc] initWithRootViewController:org]
                                            animated:YES
                                          completion:nil];
        }
    }
}

#pragma mark - ContactSelectDelegate
- (void)contactSelectCanceled {
    if (self.contactSelectCompletion) {
        self.contactSelectCompletion(NO, nil);
    }
}

- (void)contactSelected:(id)data {
    if ([data isKindOfClass:[NSClassFromString(@"ContactData") class]]) {
        NSString *name = nil;
        NSString *phone = nil;
        
        SEL titleSelector = NSSelectorFromString(@"title");
        if ([data respondsToSelector:titleSelector]) {
            name = [data performSelector:titleSelector];
        }
        
        SEL phoneSelector = NSSelectorFromString(@"phone");
        if ([data respondsToSelector:phoneSelector]) {
            phone = [data performSelector:phoneSelector];
        }
        
        [TopViewController dismissViewControllerAnimated:YES
                                                     completion:^{
                                                         if (self.contactSelectCompletion) {
                                                             self.contactSelectCompletion(YES, @{@"contacts" : @[@{@"name" : name,
                                                                                                                   @"phone": phone}]});
                                                         }
                                                     }];
    }
}

#pragma mark - CNContactPickerDelegate

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    if (self.contactSelectCompletion) {
        self.contactSelectCompletion(NO, nil);
    }
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    NSString *name, *phone;
    
    name = [contact.familyName stringByAppendingString:contact.givenName];
    
    for (CNLabeledValue *numbers in contact.phoneNumbers) {
        CNPhoneNumber *number = numbers.value;
        if (number.stringValue.length) {
            phone = [number.stringValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
            break;
        }
    }
    
    if (name.length && phone.length && self.contactSelectCompletion) {
        NSDictionary *dic = @{@"name" : name, @"phone" : phone};
        
        self.contactSelectCompletion(YES, @{@"contacts" : @[dic]});
    }
}

#pragma mark - 本地数据
- (NSArray *)allOnlineContacts {
    // 筛选条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == 1"];
    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[ContactOnlineEntity entityName]
                                                                  predicate:predicate
                                                            sortDescriptors:@[]];
}

- (NSArray *)allSortOnlineContacts {
    // 排序规则
    NSSortDescriptor *sectionDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sectionKey" ascending:YES];
    NSSortDescriptor *indexDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    NSSortDescriptor *pinyinDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pinyin" ascending:YES];
    
    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[ContactOnlineEntity entityName]
                                                                  predicate:nil
                                                            sortDescriptors:@[sectionDescriptor, indexDescriptor, pinyinDescriptor]];
    
    if (array.count) {
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        ContactData *contact = array.firstObject;
        NSInteger section = contact.section;
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:0];
        for (ContactData *contact in array) {
            // 相同首字母的数据存到同一个数组
            if (section == contact.section) {
                [temp addObject:contact];
                
                if (contact == array.lastObject) {
                    [tempArr addObject:@{kContactSectionKey:@(section),
                                         kContactListKey:temp.mutableCopy}];
                }
            }
            // 遇到不同的首字母数据，将之前存储的数据保存到返回数组中
            else {
                [tempArr addObject:@{kContactSectionKey:@(section),
                                     kContactListKey:temp.mutableCopy}];
                
                section = contact.section;
                [temp removeAllObjects];
                [temp addObject:contact];
            }
        }
        
        return [NSArray arrayWithArray:tempArr];
    }
    else {
        return @[];
    }
}

- (NSArray *)allOfflineContacts {
    // 筛选条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == 0"];
    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[ContactOnlineEntity entityName]
                                                                  predicate:predicate
                                                            sortDescriptors:@[]];
    
    return array;
}

- (NSArray *)onlineContactsWithSearchText:(NSString *)text {
    // 筛选条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"statue == 1 && (title CONTAINS %@ OR phone CONTAINS %@ || shengmu CONTAINS %@) AND phone != nil", text, text, text];
    // 排序规则
    NSSortDescriptor *titleDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pinyin" ascending:YES];
    
    
    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[ContactOnlineEntity entityName]
                                                                          predicate:predicate
                                                                    sortDescriptors:@[titleDescriptor]];
    // 根据首字母分组
    if (array.count) {
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        NSString *sectionKey = [array.firstObject sectionKey];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:0];
        for (ContactData *contact in array) {
            // 相同首字母的数据存到同一个数组
            if ([sectionKey isEqualToString:contact.sectionKey]) {
                [temp addObject:contact];
            }
            // 遇到不同的首字母数据，将之前存储的数据保存到返回数组中
            else {
                [tempArr addObject:@{kContactSectionKey:sectionKey,
                                     kContactListKey:temp.mutableCopy}];
                
                sectionKey = contact.sectionKey;
                [temp removeAllObjects];
                [temp addObject:contact];
            }
        }
        
        return [NSArray arrayWithArray:tempArr];
    }
    else  {
        return @[];
    }
}

- (void)startParse {
    // 不清除遗留的数据
    NSArray *arr = [self changeToContactData:[self allLocalOriginContacts]];
    // 更新本地联系人
    [[CacheDataSource sharedClient] addObjects:arr
                                    entityName:[ContactLocalEntity entityName]
                                       syncAll:YES
                                 syncPredicate:nil];
}

- (NSArray *)changeToContactData:(NSArray *)array {
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    for (CNContact *contact in array) {
        ContactLocalData *data = [[ContactLocalData alloc] init];
        data.title = contact.name;
        data.pinyin = [contact.name pinyin];
        data.sectionKey = [data.pinyin substringToIndex:1];

        NSMutableArray *phoneArray = [NSMutableArray arrayWithCapacity:0];
        for (CNLabeledValue *item in contact.phoneNumbers) {
            CNPhoneNumber *number = item.value;
            NSString *string = [number stringValue];

            string = [string stringByReplacingOccurrencesOfString:@"+86" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@"·" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
            [phoneArray addObject:string];
        }
        
        if (phoneArray.count) {
            data.phone = phoneArray.firstObject;
        }

        NSMutableString *shengmu = [NSMutableString new];
        NSArray *arr = [data.pinyin componentsSeparatedByString:@" "];
        for (NSString *item in arr) {
            [shengmu appendString:[item substringToIndex:1]];
        }
        data.shengmu = shengmu;
        
        if (contact.givenName.length) {
            data.givenName = contact.givenName;
            data.givenPinyin = [contact.givenName pinyin];
        }
        
        if (contact.organizationName.length) {
            data.orgName = contact.organizationName;
            data.orgNamePinyin = [contact.organizationName pinyin];
        }
        
        [tempArr addObject:data];
    }
    
    return [NSArray arrayWithArray:tempArr];
}

- (NSArray<CNContact *> *)contactsWithName:(NSString *)name {
    if (name.length == 0) {
        return nil;
    }
    
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        [self requestAccessWithCompletion:nil];
    }
    else if (status == CNAuthorizationStatusAuthorized) {
        NSPredicate *predicate = [CNContact predicateForContactsMatchingName:name];
        NSArray *array = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey, CNContactOrganizationNameKey, CNContactDepartmentNameKey];
        NSArray *arr = [self.contactStore unifiedContactsMatchingPredicate:predicate
                                                               keysToFetch:array
                                                                     error:nil];
        
        return arr;
    }
    else {
        // 没有授权
    }
    
    return nil;
}

- (NSArray<CNContact *> *)allLocalOriginContacts {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        [self requestAccessWithCompletion:nil];
    }
    else if (status == CNAuthorizationStatusAuthorized) {
        NSMutableArray *arr = [NSMutableArray new];
        NSArray *array = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey, CNContactOrganizationNameKey, CNContactDepartmentNameKey];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:array];
        [self.contactStore enumerateContactsWithFetchRequest:request
                                                       error:nil
                                                  usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                                                      [arr addObject:contact];
                                                  }];
        
        return arr;
    }
    else {
        // 没有授权
    }
    
    return nil;
}

- (ContactStatusData *)statusWithUid:(NSInteger)uid {
    for (ContactStatusData *item in self.statusMenu) {
        if (item.uid == uid) {
            return item;
        }
    }
    
    return nil;
}

- (NSString *)similarName:(NSString *)string  {
    if (string.length <= 1) {
        return string;
    }
    
    NSArray *resultArray = [self allOfflineContacts];
    NSString *pinyin = [string pinyin];
    NSInteger diff = 100;
    ContactData *found = nil;
    
    for (ContactData *data in resultArray) {
        if ([data.pinyin isEqualToString:pinyin]) {
            // 姓名完全一样
            return data.title;
        }
        
        if (data.givenName.length > 1 && [data.givenPinyin isEqualToString:pinyin]) {
            // 名一样
            return data.givenName;
        }
        
        if (data.orgName.length > 1 && [data.orgNamePinyin isEqualToString:pinyin]) {
            // 公司名称一样
            return data.orgName;
        }
        
        // 姓名
        NSInteger aa = [pinyin pinyinDiffWithString:data.pinyin];
        if (aa < diff) {
            diff = aa;
            found = data;
        }
        
        // 名
        aa = [pinyin pinyinDiffWithString:data.givenPinyin];
        if (aa < diff) {
            diff = aa;
            found = data;
        }
        
        //        // 备注名
        //        aa = [pinyin pinyinDiffWithString:data.notePinyin];
        //        if (aa < diff) {
        //            diff = aa;
        //            found = data;
        //        }
        
        // 公司名
        aa = [pinyin pinyinDiffWithString:data.orgNamePinyin];
        if (aa < diff) {
            diff = aa;
            found = data;
        }
    }
    
    if (diff < 3) {
        return found.title;
    }
    else {
        return string;
    }
}

#pragma mark - 好友申请相关
- (NSArray *)allFriendRequest {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    
    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[FriendRequestEntity entityName]
                                                                  predicate:nil
                                                            sortDescriptors:@[sortDescriptor]];
    
    return array;
}

- (void)addFriendRequset:(FriendRequestData *)data {
    // 更新好友申请
    [[CacheDataSource sharedClient] addObject:data
                                   entityName:[FriendRequestEntity entityName]];
}

- (void)deleteFriendRequestData:(FriendRequestData *)data {
    // 删除好友申请
    [[CacheDataSource sharedClient] deleteObject:data];
}

- (nullable FriendRequestData *)requestWithId:(NSString *)requestid {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"requestid == %@", requestid];
    
    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[FriendRequestEntity entityName]
                                                                  predicate:predicate
                                                            sortDescriptors:@[]];
    if (array.count) {
        return array.firstObject;
    }
    
    return nil;
}

- (void)clearAllUnreadFriendRequests {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accepted == NO && readStatus == NO"];
    NSArray *array = [[CacheDataSource sharedClient] getDatasWithEntityName:[FriendRequestEntity entityName]
                                                                  predicate:predicate
                                                            sortDescriptors:@[]];
    
    for (FriendRequestData *data in array) {
        data.readStatus = YES;
    }
    
    [[CacheDataSource sharedClient] addObject:array
                                   entityName:[FriendRequestEntity entityName]];
}

#pragma mark - 数据请求
- (void)requestAccessWithCompletion:(CommonBlock)completion {
    [self.contactStore requestAccessForEntityType:CNEntityTypeContacts
                                completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                    if (granted) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self startParse];
                                        });
                                    }
                                    
                                    if (completion) {
                                        completion(granted, nil);
                                    }
                                }];
}

- (void)requestContactsWithCompletion:(CommonBlock)completion {
    [[MainInterface sharedClient] GET:@"app/contacts"
                              parameters:nil
                                progress:nil
                                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                     NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                     NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                     ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                     
                                     if ([error_code errorCodeSuccess]) {
                                         NSDictionary *extra = responseObject[@"extra"];
                                         
                                         NSArray *data = extra[@"data"];
                                         NSMutableArray *arr = [NSMutableArray new];
                                         for (NSDictionary *item in data) {
                                             ContactData *aa = [ContactData contactWithData:item];
                                             [arr addObject:aa];
                                         }
                                         // 更新线上联系人
                                         [[CacheDataSource sharedClient] addObjects:arr
                                                                         entityName:[ContactOnlineEntity entityName]
                                                                            syncAll:YES
                                                                      syncPredicate:nil];
                                         
                                         if (completion) {
                                             completion(YES, extra);
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

- (void)requestContactsStatusMenuWithCompletion:(nullable CommonBlock)completion {
    [[MainInterface sharedClient] doWithMethod:@"GET"
                                     urlString:@"app/contacts/menu"
                                    parameters:nil
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                           NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                           NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                           ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                           
                                           if ([error_code errorCodeSuccess]) {
                                               NSDictionary *extra = responseObject[@"extra"];
                                               if (completion) {
                                                   completion(YES, extra);
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

- (void)requestMyStatusWithAction:(YuCloudDataActions)action status:(NSInteger)status completion:(CommonBlock)completion {
    NSString *method;
    NSDictionary *dic;
    switch (action) {
        case YuCloudDataList:
            method = @"GET";
            break;
            
        case YuCloudDataEdit:
            method = @"PUT";
            dic = @{@"status" : @(status)};
            break;
            
        default:
            NSAssert(NO, @"you should not be here");
            break;
    }
    
    [[MainInterface sharedClient] doWithMethod:method
                                     urlString:@"app/contacts/status"
                                    parameters:dic
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                           NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                           NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                           ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                           
                                           if ([error_code errorCodeSuccess]) {
                                               if (action == YuCloudDataList) {
                                                   NSDictionary *extra = responseObject[@"extra"];
                                                   NSNumber *number = extra[@"status"];
                                                   if (completion) {
                                                       completion(YES, @{@"status" : number?:@0});
                                                   }
                                               }
                                               else if (action == YuCloudDataEdit) {
                                                   self.myStatus = status;
                                                   if (completion) {
                                                       completion(YES, @{@"status" : @(status)});
                                                   }
                                               }
                                               else {
                                                   if (completion) {
                                                       completion(NO, nil);
                                                   }
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

- (void)requestFriendConnectWith:(NSString *)userid
                         message:(nullable NSString *)message
                      completion:(CommonBlock)completion {
    NSString *urlString = [NSString stringWithFormat:@"community/people/%@/friend", userid];
    NSDictionary *dic = nil;
    if (message) {
        dic = @{@"message" : message};
    }
    [[MainInterface sharedClient] doWithMethod:@"POST"
                                     urlString:urlString
                                    parameters:dic
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                           NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                           NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                           ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                           
                                           NSDictionary *extra = responseObject[@"extra"];
                                           if ([error_code errorCodeSuccess]) {
                                               NSDictionary *data = extra[@"data"];
                                               if (completion) {
                                                   completion(YES, data);
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

- (void)respondFriendRequestWith:(NSString *)requestid
                          accept:(BOOL)accept
                      completion:(CommonBlock)completion {
    NSString *urlString = [NSString stringWithFormat:@"community/people/request/%@", requestid];
    NSDictionary *dic = @{@"response" : accept?@"accept":@"reject"};
    
    [[MainInterface sharedClient] doWithMethod:@"POST"
                                     urlString:urlString
                                    parameters:dic
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                           NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                           NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                           ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                           
                                           if ([error_code errorCodeSuccess]) {
                                               FriendRequestData *data = [self requestWithId:requestid];
                                               data.accepted = accept;
                                               [self addFriendRequset:data];
                                                   
                                               //                                               [[FollowDataSource sharedClient] addFriendUser:data.userid byUser:YUCLOUD_ACCOUNT_USERID];
                                               
                                               if (completion) {
                                                   completion(YES, nil);
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

- (void)requestFriendWithStartid:(NSString *)startid completion:(CommonBlock)completion {
    NSDictionary *dic = nil;
    if (startid) {
        dic = @{@"start_id" : startid};
    }
    [[MainInterface sharedClient] doWithMethod:@"GET"
                                     urlString:@"community/friend"
                                    parameters:dic
                     constructingBodyWithBlock:nil
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                           NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                                           NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                                           ACCOUNT_ENSURE_TOKEN(error_code, error_msg);
                                           
                                           NSDictionary *extra = responseObject[@"extra"];
                                           if ([error_code errorCodeSuccess]) {
                                               NSArray *data = extra[@"data"];
                                               for (NSDictionary *item in data) {
//                                                   [[FollowDataSource sharedClient] addFriendUser:item[@"uid"] byUser:YUCLOUD_ACCOUNT_USERID];
                                                   //更新好友的同时更新好友的个人信息
                                                   [self updateUserInfoWithId:item[@"uid"]];
                                               }
                                               
                                               completion(YES, @{@"next_id" : extra[@"next_id"]});
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

- (void)updateUserInfoWithId:(NSString *)userid {
    Class UserClass = NSClassFromString(@"UserManager");
    if (UserClass && [UserClass respondsToSelector:@selector(shareManager)]) {
        Class manager = [UserClass performSelector:@selector(shareManager)];
        if (manager && [manager respondsToSelector:@selector(requestUserInfoWithUserid:forceRefresh:localholder:completion:)]) {
            CommonBlock block = ^(BOOL success, NSDictionary * _Nullable info) {
                if(success) {
                    id userData = [info valueForKey:@"user"];
                    // 更新用户信息
                    if ([manager respondsToSelector:@selector(addUserData:)]) {
                        [manager performSelector:@selector(addUserData:) withObject:userData];
                    }
                }
            };
            
            [manager performSelectorWithArgs:@selector(requestUserInfoWithUserid:forceRefresh:localholder:completion:), userid, @YES, nil, block];
        }
    }
    
//    [[UserManager shareManager] requestUserInfoWithUserid:userid forceRefresh:YES localholder:nil completion:^(BOOL success, NSDictionary * _Nullable info) {
//        if(success) {
//            UserData *user = [info valueForKey:@"user"];
//            [[UserManager shareManager] addUserData:user];
//        }
//    }];
}

- (void)startListTimer {
    [self stopListTimer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.7
                                                  target:self
                                                selector:@selector(listTimerFire:)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)stopListTimer {
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    
    self.timer = nil;
}

- (void)listTimerFire:(NSTimer *)timer {
    self.listing = NO;
    [self requestContactsWithCompletion:nil];
}



@end
