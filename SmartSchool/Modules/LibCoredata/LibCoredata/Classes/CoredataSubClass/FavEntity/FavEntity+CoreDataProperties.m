//
//  FavEntity+CoreDataProperties.m
//  
//
//  Created by 唐琦 on 2020/1/2.
//
//

#import "FavEntity+CoreDataProperties.h"

@implementation FavEntity (CoreDataProperties)

+ (NSFetchRequest<FavEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"FavEntity"];
}

@dynamic uid;
@dynamic content;
@dynamic overview;
@dynamic imageUrl;
@dynamic title;
@dynamic type;
@dynamic loginid;

@end
