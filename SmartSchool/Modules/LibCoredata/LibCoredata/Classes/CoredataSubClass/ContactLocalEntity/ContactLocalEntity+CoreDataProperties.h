//
//  ContactLocalEntity+CoreDataProperties.h
//  
//
//  Created by 唐琦 on 2019/12/30.
//
//

#import "ContactLocalEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ContactLocalEntity (CoreDataProperties)

+ (NSFetchRequest<ContactLocalEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *pinyin;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *sectionKey;
@property (nullable, nonatomic, copy) NSString *shengmu;
@property (nullable, nonatomic, copy) NSString *givenName;
@property (nullable, nonatomic, copy) NSString *givenPinyin;
@property (nullable, nonatomic, copy) NSString *orgName;
@property (nullable, nonatomic, copy) NSString *orgNamePinyin;
@property (nullable, nonatomic, copy) NSString *loginid;
@property (nonatomic) int16_t uid;
@property (nullable, nonatomic, copy) NSString *phone;

@end

NS_ASSUME_NONNULL_END
