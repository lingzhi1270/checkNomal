//
//  ThemeEntity+CoreDataProperties.m
//  
//
//  Created by 唐琦 on 2019/12/30.
//
//

#import "ThemeEntity+CoreDataProperties.h"

@implementation ThemeEntity (CoreDataProperties)

+ (NSFetchRequest<ThemeEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"ThemeEntity"];
}

@dynamic name;
@dynamic sysDefault;
@dynamic coverUrl;
@dynamic detail;
@dynamic bundleUrl;
@dynamic screenUrl;
@dynamic fileName;
@dynamic timeOn;
@dynamic timeOff;
@dynamic loginid;

@end
