//
//  NewsEntity+CoreDataProperties.h
//  
//
//  Created by 唐琦 on 2020/1/2.
//
//

#import "NewsEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface NewsEntity (CoreDataProperties)

+ (NSFetchRequest<NewsEntity *> *)fetchRequest;

@property (nonatomic) int16_t uid;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *overview;
@property (nullable, nonatomic, copy) NSString *originalImageUrl;
@property (nullable, nonatomic, copy) NSString *targetUrl;
@property (nullable, nonatomic, copy) NSString *shareUrl;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *loginid;
@property (nullable, nonatomic, copy) NSString *cachedImage;

@end

NS_ASSUME_NONNULL_END
