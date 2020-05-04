//
//  AdEntity+CoreDataProperties.h
//  
//
//  Created by 唐琦 on 2020/1/3.
//
//

#import "AdEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AdEntity (CoreDataProperties)

+ (NSFetchRequest<AdEntity *> *)fetchRequest;

@property (nonatomic) int16_t uid;
@property (nonatomic) int16_t type;
@property (nonatomic) int16_t cycle;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *mediaUrl;
@property (nonatomic) BOOL mediaVideo;
@property (nullable, nonatomic, copy) NSString *targetType;
@property (nullable, nonatomic, copy) NSString *targetUrl;
@property (nullable, nonatomic, copy) NSDate *timeOn;
@property (nullable, nonatomic, copy) NSDate *timeOff;
@property (nullable, nonatomic, copy) NSDate *timeLast;
@property (nonatomic) int16_t duration;

@end

NS_ASSUME_NONNULL_END
