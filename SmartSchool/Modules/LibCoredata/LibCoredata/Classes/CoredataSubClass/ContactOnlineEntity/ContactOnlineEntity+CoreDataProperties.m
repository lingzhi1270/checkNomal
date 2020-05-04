//
//  ContactOnlineEntity+CoreDataProperties.m
//  
//
//  Created by 唐琦 on 2020/1/8.
//
//

#import "ContactOnlineEntity+CoreDataProperties.h"

@implementation ContactOnlineEntity (CoreDataProperties)

+ (NSFetchRequest<ContactOnlineEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"ContactOnlineEntity"];
}

@dynamic avatarUrl;
@dynamic category;
@dynamic email;
@dynamic givenName;
@dynamic givenPinyin;
@dynamic index;
@dynamic loginid;
@dynamic note;
@dynamic orgName;
@dynamic orgNamePinyin;
@dynamic phone;
@dynamic pinyin;
@dynamic placeholder;
@dynamic section;
@dynamic sectionKey;
@dynamic shengmu;
@dynamic shortNo;
@dynamic status;
@dynamic title;
@dynamic uid;
@dynamic refCount;

@end
