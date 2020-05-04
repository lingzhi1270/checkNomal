//
//  UserManager.h
//  Unilife
//
//  Created by 唐琦 on 2019/7/15.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/UserData.h>
#import <LibCoredata/CacheDataSource.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserManager : BaseManager

@property (nonatomic, readonly) NSString        *refreshKey;

- (void)addUserData:(UserData *)data;

- (UserData *)userWithUserid:(NSString *)userid;

- (UserData *)userWithImid:(NSString *)imid;

- (void)requestUserInfoWithUserid:(NSString *)userid
                     forceRefresh:(BOOL)refresh
                      localholder:(nullable CommonBlock)localholder
                       completion:(nullable CommonBlock)completion;

- (void)requestUserInfoWithImid:(NSString *)userid
                   forceRefresh:(BOOL)refresh
                    localholder:(nullable CommonBlock)localholder
                     completion:(nullable CommonBlock)completion;

@end

NS_ASSUME_NONNULL_END
