//
//  FriendRequestEntity+CoreDataProperties.h
//  
//
//  Created by 唐琦 on 2019/12/30.
//
//

#import "FriendRequestEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface FriendRequestEntity (CoreDataProperties)

+ (NSFetchRequest<FriendRequestEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *message;
@property (nonatomic) BOOL accepted;
@property (nullable, nonatomic, copy) NSString *requestid;
@property (nullable, nonatomic, copy) NSString *userid;
@property (nullable, nonatomic, copy) NSString *avatarUrl;
@property (nullable, nonatomic, copy) NSString *loginid;
@property (nonatomic) BOOL readStatus;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nonatomic) int16_t type;

@end

NS_ASSUME_NONNULL_END
