//
//  CityEntity+CoreDataProperties.m
//  
//
//  Created by 唐琦 on 2020/1/2.
//
//

#import "CityEntity+CoreDataProperties.h"

@implementation CityEntity (CoreDataProperties)

+ (NSFetchRequest<CityEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"CityEntity"];
}

@dynamic uuid;
@dynamic province;
@dynamic city;
@dynamic district;
@dynamic selectedIndex;
@dynamic weather;
@dynamic weather_date;
@dynamic loginid;

@end
