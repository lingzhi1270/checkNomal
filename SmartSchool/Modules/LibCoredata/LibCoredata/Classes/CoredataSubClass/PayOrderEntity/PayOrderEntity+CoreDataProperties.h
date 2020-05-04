//
//  PayOrderEntity+CoreDataProperties.h
//  
//
//  Created by 唐琦 on 2019/12/30.
//
//

#import "PayOrderEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PayOrderEntity (CoreDataProperties)

+ (NSFetchRequest<PayOrderEntity *> *)fetchRequest;


@end

NS_ASSUME_NONNULL_END
