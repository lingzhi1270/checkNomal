//
//  PayOrderEntity+CoreDataProperties.m
//  
//
//  Created by 唐琦 on 2019/12/30.
//
//

#import "PayOrderEntity+CoreDataProperties.h"

@implementation PayOrderEntity (CoreDataProperties)

+ (NSFetchRequest<PayOrderEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"PayOrderEntity"];
}


@end
