//
//  NewsEntity+CoreDataProperties.m
//  
//
//  Created by 唐琦 on 2020/1/2.
//
//

#import "NewsEntity+CoreDataProperties.h"

@implementation NewsEntity (CoreDataProperties)

+ (NSFetchRequest<NewsEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"NewsEntity"];
}

@dynamic uid;
@dynamic title;
@dynamic overview;
@dynamic originalImageUrl;
@dynamic targetUrl;
@dynamic shareUrl;
@dynamic date;
@dynamic loginid;
@dynamic cachedImage;

@end
