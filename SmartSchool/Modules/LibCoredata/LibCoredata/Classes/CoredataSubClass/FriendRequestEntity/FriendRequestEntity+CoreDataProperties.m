//
//  FriendRequestEntity+CoreDataProperties.m
//  
//
//  Created by 唐琦 on 2019/12/30.
//
//

#import "FriendRequestEntity+CoreDataProperties.h"

@implementation FriendRequestEntity (CoreDataProperties)

+ (NSFetchRequest<FriendRequestEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"FriendRequestEntity"];
}

@dynamic name;
@dynamic message;
@dynamic accepted;
@dynamic requestid;
@dynamic userid;
@dynamic avatarUrl;
@dynamic readStatus;
@dynamic date;
@dynamic type;
@dynamic loginid;

@end
