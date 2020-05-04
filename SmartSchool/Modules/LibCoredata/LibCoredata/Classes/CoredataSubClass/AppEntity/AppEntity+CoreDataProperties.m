//
//  AppEntity+CoreDataProperties.m
//  
//
//  Created by 唐琦 on 2019/12/30.
//
//

#import "AppEntity+CoreDataProperties.h"

@implementation AppEntity (CoreDataProperties)

+ (NSFetchRequest<AppEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"AppEntity"];
}

@dynamic admin;
@dynamic categoryId;
@dynamic categoryIndex;
@dynamic categoryName;
@dynamic homeIndex;
@dynamic homeUrl;
@dynamic iconUrl;
@dynamic loginid;
@dynamic name_chs;
@dynamic name_en;
@dynamic qrKey;
@dynamic type;
@dynamic uid;

@end
