//
//  NSUserDefaults+Unilife.m
//  Unilife
//
//  Created by 唐琦 on 2019/6/14.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "NSUserDefaults+Unilife.h"

@implementation NSUserDefaults (Unilife)

+ (instancetype)uniDefaults {
    static dispatch_once_t onceToken;
    static NSUserDefaults *defaults = nil;
    dispatch_once(&onceToken, ^{
#if UNILIFE_DEV_MODE
        defaults = [[NSUserDefaults alloc] initWithSuiteName:@"uniDevDefaults"];
#else
        defaults = [[NSUserDefaults alloc] initWithSuiteName:@"uniDefaults"];
#endif //
    });
    
    return defaults;
}

#define SPLASH_KEY @"splash.key"

+ (NSString *)splashKey {
    return [[NSUserDefaults uniDefaults] objectForKey:SPLASH_KEY];
}

+ (void)saveSplashKey:(NSString *)key {
    [[NSUserDefaults uniDefaults] setObject:key forKey:SPLASH_KEY];
}

#define USERID_KEY  @"userId.key"

+ (NSString *)userId {
    return [[NSUserDefaults uniDefaults] objectForKey:USERID_KEY];
}

+ (void)saveUserid:(NSString *)userId {
    [[NSUserDefaults uniDefaults] setObject:userId?:@"" forKey:USERID_KEY];
}

#define TOKEN_KEY   @"token.key"
#define TOKEN_DATE_KEY  @"token.date.key"

+ (NSString *)token {
    return [[NSUserDefaults uniDefaults] objectForKey:TOKEN_KEY];
}

+ (void)saveToken:(NSString *)token {
    [[NSUserDefaults uniDefaults] setObject:[NSDate date] forKey:TOKEN_DATE_KEY];
    [[NSUserDefaults uniDefaults] setObject:token?:@"" forKey:TOKEN_KEY];
}

+ (NSDate *)tokenDate {
    return [[NSUserDefaults uniDefaults] objectForKey:TOKEN_DATE_KEY];
}

#define NICK_NAME_KEY   @"nick.name.key"

+ (NSString *)nickName {
    return [[NSUserDefaults uniDefaults] objectForKey:NICK_NAME_KEY];
}

+ (void)saveNickName:(NSString *)nickName {
    [[NSUserDefaults uniDefaults] setObject:nickName forKey:NICK_NAME_KEY];
}

#define AVATAR_URL_KEY  @"avatar.url.key"
+ (NSString *)avatarUrl {
    return [[self uniDefaults] objectForKey:AVATAR_URL_KEY];
}

+ (void)saveAvatarUrl:(NSString *)avatarUrl {
    [[self uniDefaults] setObject:avatarUrl forKey:AVATAR_URL_KEY];
}

#define ACCOUNT_TYPE_KEY    @"account.type.key"
+ (NSString *)accountForType:(NSUInteger)type {
    NSString *key = [NSString stringWithFormat:@"%@-%lu", ACCOUNT_TYPE_KEY, (unsigned long)type];
    return [[self uniDefaults] objectForKey:key];
}

+ (void)saveAccount:(NSString *)account ForType:(NSUInteger)type {
    NSString *key = [NSString stringWithFormat:@"%@-%lu", ACCOUNT_TYPE_KEY, (unsigned long)type];
    [[self uniDefaults] setObject:account?:@"" forKey:key];
}

#define LOGIN_STYLE_KEY     @"login.style.key"
+ (NSInteger)loginStyle {
    NSNumber *number = [[self uniDefaults] objectForKey:LOGIN_STYLE_KEY];
    // 默认登录方式为Emis
    return number?[number integerValue] : 5;
}

+ (void)saveLoginStyle:(NSInteger)style {
    [[self uniDefaults] setObject:@(style) forKey:LOGIN_STYLE_KEY];
}

#define DB_HASH_KEY   @"db.hash.key"
+ (NSUInteger)databaseHash {
    NSNumber *number = [[self uniDefaults] objectForKey:DB_HASH_KEY];
    return [number unsignedIntegerValue];
}

+ (void)saveDatabaseHash:(NSUInteger)hash {    
    [[self uniDefaults] setObject:@(hash) forKey:DB_HASH_KEY];
}

#define SCHOOL_CALENDAR_KEY @"school.calendar.key"
+ (NSString *)schoolCalendar{
     return [[self uniDefaults] objectForKey:SCHOOL_CALENDAR_KEY];
}

+ (void)saveSchoolCalendar:(NSString *)schoolCalendar{
     [[self uniDefaults] setObject:schoolCalendar?:@"" forKey:SCHOOL_CALENDAR_KEY];
}

#define SCHOOL_ID_KEY @"school.id.key"
+ (NSString *)schoolId {
    return [[self uniDefaults] objectForKey:SCHOOL_ID_KEY];
}

+ (void)saveSchoolId:(NSString *)schoolId {
    [[self uniDefaults] setObject:schoolId?:@"" forKey:SCHOOL_ID_KEY];
}

#define SCHOOL_NAME_KEY @"school.name.key"
+ (NSString *)schoolName {
    return [[self uniDefaults] objectForKey:SCHOOL_NAME_KEY];
}

+ (void)saveSchoolName:(NSString *)schoolName {
    [[self uniDefaults] setObject:schoolName?:@"" forKey:SCHOOL_NAME_KEY];
}

#define SCHOOL_LOGO_KEY @"school.logo.key"
+ (NSString *)schoolLogo {
    return [[self uniDefaults] objectForKey:SCHOOL_LOGO_KEY];
}

+ (void)saveSchoolLogo:(NSString *)schoolLogo {
    [[self uniDefaults] setObject:schoolLogo?:@"" forKey:SCHOOL_LOGO_KEY];
}

#define THEME_ACTIVATED_KEY @"theme.activated.key"
+ (NSString *)activatedTheme {
    return [[self uniDefaults] objectForKey:THEME_ACTIVATED_KEY];
}

+ (void)saveActivatedTheme:(NSString *)name {
    [[self uniDefaults] setObject:name?:@"" forKey:THEME_ACTIVATED_KEY];
}

#define WEATHER_ICONS_KEY   @"weather.icons.key"
+ (NSDictionary *)weatherIcons {
    return [[self uniDefaults] objectForKey:WEATHER_ICONS_KEY];
}

+ (void)saveWeatherIcons:(NSDictionary *)icons {
    [[self uniDefaults] setObject:icons forKey:WEATHER_ICONS_KEY];
}

#define LOCAL_DISTRICT_KEY  @"local.district.key"
+ (NSString *)localDistrict {
    return [[self uniDefaults] objectForKey:LOCAL_DISTRICT_KEY];
}

+ (void)saveLocalDistrict:(NSString *)name {
    [[self uniDefaults] setObject:name?:@"" forKey:LOCAL_DISTRICT_KEY];
}

+ (id)objectForApp:(NSString *)appid key:(NSString *)key {
    NSString *string = [NSString stringWithFormat:@"%@-%@", appid, key];
    return [[self uniDefaults] objectForKey:string];
}

+ (void)saveObject:(id)object forApp:(NSString *)appid key:(NSString *)key {
    NSString *string = [NSString stringWithFormat:@"%@-%@", appid, key];
    [[self uniDefaults] setObject:object?:@"" forKey:string];
}

@end
