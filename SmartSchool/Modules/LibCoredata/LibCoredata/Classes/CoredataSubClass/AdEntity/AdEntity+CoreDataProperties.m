//
//  AdEntity+CoreDataProperties.m
//  
//
//  Created by 唐琦 on 2020/1/3.
//
//

#import "AdEntity+CoreDataProperties.h"

@implementation AdEntity (CoreDataProperties)

+ (NSFetchRequest<AdEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"AdEntity"];
}

@dynamic uid;
@dynamic type;
@dynamic cycle;
@dynamic title;
@dynamic mediaUrl;
@dynamic mediaVideo;
@dynamic targetType;
@dynamic targetUrl;
@dynamic timeOn;
@dynamic timeOff;
@dynamic timeLast;
@dynamic duration;

@end
