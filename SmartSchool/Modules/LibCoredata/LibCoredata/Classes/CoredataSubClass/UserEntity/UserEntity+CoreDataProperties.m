//
//  UserEntity+CoreDataProperties.m
//  
//
//  Created by 唐琦 on 2019/12/30.
//
//

#import "UserEntity+CoreDataProperties.h"

@implementation UserEntity (CoreDataProperties)

+ (NSFetchRequest<UserEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UserEntity"];
}

@dynamic avatarUrl;
@dynamic im_id;
@dynamic name;
@dynamic nickname;
@dynamic school;
@dynamic userid;
@dynamic relation;
@dynamic followed_count;
@dynamic follower_count;
@dynamic topic_count;
@dynamic refreshKey;
@dynamic loginid;

@end
