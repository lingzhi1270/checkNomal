//
//  CheckGradeData.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/14.
//

#import "CheckGradeData.h"

@implementation CheckGradeData
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"sub_items" : CheckGradeSubItemData.class};
}
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"gradeId":@"id"};
}
@end

@implementation CheckGradeSubItemData
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"subId":@"id"};
}
@end
