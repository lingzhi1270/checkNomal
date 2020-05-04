//
//  FavEntity+CoreDataProperties.h
//  
//
//  Created by 唐琦 on 2020/1/2.
//
//

#import "FavEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface FavEntity (CoreDataProperties)

+ (NSFetchRequest<FavEntity *> *)fetchRequest;

@property (nonatomic) int16_t uid;
@property (nullable, nonatomic, copy) NSString *content;
@property (nullable, nonatomic, copy) NSString *overview;
@property (nullable, nonatomic, copy) NSString *imageUrl;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *loginid;

@end

NS_ASSUME_NONNULL_END
