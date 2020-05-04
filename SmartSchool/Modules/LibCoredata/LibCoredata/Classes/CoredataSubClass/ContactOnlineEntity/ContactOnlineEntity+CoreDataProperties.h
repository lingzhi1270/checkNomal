//
//  ContactOnlineEntity+CoreDataProperties.h
//  
//
//  Created by 唐琦 on 2020/1/8.
//
//

#import "ContactOnlineEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ContactOnlineEntity (CoreDataProperties)

+ (NSFetchRequest<ContactOnlineEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *avatarUrl;
@property (nullable, nonatomic, copy) NSString *category;
@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *givenName;
@property (nullable, nonatomic, copy) NSString *givenPinyin;
@property (nonatomic) int16_t index;
@property (nullable, nonatomic, copy) NSString *loginid;
@property (nullable, nonatomic, copy) NSString *note;
@property (nullable, nonatomic, copy) NSString *orgName;
@property (nullable, nonatomic, copy) NSString *orgNamePinyin;
@property (nullable, nonatomic, copy) NSString *phone;
@property (nullable, nonatomic, copy) NSString *pinyin;
@property (nullable, nonatomic, copy) NSString *placeholder;
@property (nonatomic) int16_t section;
@property (nullable, nonatomic, copy) NSString *sectionKey;
@property (nullable, nonatomic, copy) NSString *shengmu;
@property (nullable, nonatomic, copy) NSString *shortNo;
@property (nonatomic) int16_t status;
@property (nullable, nonatomic, copy) NSString *title;
@property (nonatomic) int16_t uid;
@property (nonatomic) int16_t refCount;

@end

NS_ASSUME_NONNULL_END
