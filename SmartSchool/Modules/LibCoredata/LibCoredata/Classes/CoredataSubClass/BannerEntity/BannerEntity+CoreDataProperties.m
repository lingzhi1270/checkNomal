//
//  BannerEntity+CoreDataProperties.m
//  
//
//  Created by 唐琦 on 2020/1/2.
//
//

#import "BannerEntity+CoreDataProperties.h"

@implementation BannerEntity (CoreDataProperties)

+ (NSFetchRequest<BannerEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"BannerEntity"];
}

@dynamic uid;
@dynamic title;
@dynamic mediaUrl;
@dynamic targetType;
@dynamic targetUrl;
@dynamic loginid;

@end
