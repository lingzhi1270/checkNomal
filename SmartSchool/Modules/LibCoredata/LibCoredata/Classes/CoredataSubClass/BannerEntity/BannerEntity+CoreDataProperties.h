//
//  BannerEntity+CoreDataProperties.h
//  
//
//  Created by 唐琦 on 2020/1/2.
//
//

#import "BannerEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BannerEntity (CoreDataProperties)

+ (NSFetchRequest<BannerEntity *> *)fetchRequest;

@property (nonatomic) int64_t uid;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *mediaUrl;
@property (nullable, nonatomic, copy) NSString *targetType;
@property (nullable, nonatomic, copy) NSString *targetUrl;
@property (nullable, nonatomic, copy) NSString *loginid;

@end

NS_ASSUME_NONNULL_END
