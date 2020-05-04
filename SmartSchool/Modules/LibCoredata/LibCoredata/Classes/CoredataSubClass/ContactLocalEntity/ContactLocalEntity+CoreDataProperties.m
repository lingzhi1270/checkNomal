//
//  ContactLocalEntity+CoreDataProperties.m
//  
//
//  Created by 唐琦 on 2019/12/30.
//
//

#import "ContactLocalEntity+CoreDataProperties.h"

@implementation ContactLocalEntity (CoreDataProperties)

+ (NSFetchRequest<ContactLocalEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"ContactLocalEntity"];
}

@dynamic pinyin;
@dynamic title;
@dynamic sectionKey;
@dynamic shengmu;
@dynamic givenName;
@dynamic givenPinyin;
@dynamic orgName;
@dynamic orgNamePinyin;
@dynamic loginid;
@dynamic uid;
@dynamic phone;

@end
