//
//  NSUserDefaults+Unilife.h
//  Unilife
//
//  Created by 唐琦 on 2019/6/14.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSUserDefaults (Unilife)

+ (NSString *)splashKey;
+ (void)saveSplashKey:(NSString *)key;

+ (NSString *)userId;
+ (void)saveUserid:(nullable NSString *)userId;

+ (NSString *)token;
+ (void)saveToken:(nullable NSString *)token;
+ (NSDate *)tokenDate;

+ (NSString *)nickName;
+ (void)saveNickName:(NSString *)nickName;

+ (NSString *)avatarUrl;
+ (void)saveAvatarUrl:(NSString *)avatarUrl;

+ (NSString *)accountForType:(NSUInteger)type;
+ (void)saveAccount:(NSString *)account ForType:(NSUInteger)type;

+ (NSInteger)loginStyle;
+ (void)saveLoginStyle:(NSInteger)style;

+ (NSUInteger)databaseHash;
+ (void)saveDatabaseHash:(NSUInteger)hash;

+ (NSString *)schoolCalendar;
+ (void)saveSchoolCalendar:(NSString *)schoolCalendar;

+ (NSString *)schoolId;
+ (void)saveSchoolId:(NSString *)schoolId;

+ (NSString *)schoolName;
+ (void)saveSchoolName:(NSString *)schoolName;

+ (NSString *)schoolLogo;
+ (void)saveSchoolLogo:(NSString *)schoolLogo;

+ (NSString *)activatedTheme;
+ (void)saveActivatedTheme:(NSString *)name;

+ (NSDictionary *)weatherIcons;
+ (void)saveWeatherIcons:(NSDictionary *)icons;

+ (NSString *)localDistrict;
+ (void)saveLocalDistrict:(NSString *)name;

+ (id)objectForApp:(NSString *)appid key:(NSString *)key;
+ (void)saveObject:(id)object forApp:(NSString *)appid key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
