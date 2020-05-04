//
//  CityEntity+CoreDataProperties.h
//  
//
//  Created by 唐琦 on 2020/1/2.
//
//

#import "CityEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CityEntity (CoreDataProperties)

+ (NSFetchRequest<CityEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *uuid;
@property (nullable, nonatomic, copy) NSString *province;
@property (nullable, nonatomic, copy) NSString *city;
@property (nullable, nonatomic, copy) NSString *district;
@property (nonatomic) int16_t selectedIndex;
@property (nullable, nonatomic, retain) NSData *weather;
@property (nullable, nonatomic, copy) NSDate *weather_date;
@property (nullable, nonatomic, copy) NSString *loginid;

@end

NS_ASSUME_NONNULL_END
