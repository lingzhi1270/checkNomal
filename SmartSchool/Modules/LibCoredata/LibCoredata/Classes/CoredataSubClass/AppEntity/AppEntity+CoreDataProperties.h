//
//  AppEntity+CoreDataProperties.h
//  
//
//  Created by 唐琦 on 2019/12/30.
//
//

#import "AppEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AppEntity (CoreDataProperties)

+ (NSFetchRequest<AppEntity *> *)fetchRequest;

@property (nonatomic) BOOL admin;
@property (nonatomic) int32_t categoryId;
@property (nonatomic) int32_t categoryIndex;
@property (nullable, nonatomic, copy) NSString *categoryName;
@property (nonatomic) int32_t homeIndex;
@property (nullable, nonatomic, copy) NSString *homeUrl;
@property (nullable, nonatomic, copy) NSString *iconUrl;
@property (nullable, nonatomic, copy) NSString *loginid;
@property (nullable, nonatomic, copy) NSString *name_chs;
@property (nullable, nonatomic, copy) NSString *name_en;
@property (nullable, nonatomic, copy) NSString *qrKey;
@property (nonatomic) int16_t type;
@property (nullable, nonatomic, copy) NSString *uid;

@end

NS_ASSUME_NONNULL_END
