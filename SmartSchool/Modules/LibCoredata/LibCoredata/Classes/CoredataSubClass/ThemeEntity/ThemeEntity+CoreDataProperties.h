//
//  ThemeEntity+CoreDataProperties.h
//  
//
//  Created by 唐琦 on 2019/12/30.
//
//

#import "ThemeEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ThemeEntity (CoreDataProperties)

+ (NSFetchRequest<ThemeEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) BOOL sysDefault;
@property (nullable, nonatomic, copy) NSString *coverUrl;
@property (nullable, nonatomic, copy) NSString *detail;
@property (nullable, nonatomic, copy) NSString *bundleUrl;
@property (nullable, nonatomic, copy) NSString *screenUrl;
@property (nullable, nonatomic, copy) NSString *fileName;
@property (nullable, nonatomic, copy) NSString *timeOn;
@property (nullable, nonatomic, copy) NSString *timeOff;
@property (nullable, nonatomic, copy) NSString *loginid;

@end

NS_ASSUME_NONNULL_END
