//
//  UserEntity+CoreDataProperties.h
//  
//
//  Created by 唐琦 on 2019/12/30.
//
//

#import "UserEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UserEntity (CoreDataProperties)

+ (NSFetchRequest<UserEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *avatarUrl;
@property (nullable, nonatomic, copy) NSString *im_id;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *nickname;
@property (nullable, nonatomic, copy) NSString *school;
@property (nullable, nonatomic, copy) NSString *userid;
@property (nullable, nonatomic, copy) NSString *relation;
@property (nonatomic) int16_t followed_count;
@property (nonatomic) int16_t follower_count;
@property (nonatomic) int16_t topic_count;
@property (nullable, nonatomic, copy) NSString *refreshKey;
@property (nullable, nonatomic, copy) NSString *loginid;

@end

NS_ASSUME_NONNULL_END
