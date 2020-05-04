//
//  CheckClassData.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/10.
//

#import "CheckClassData.h"

@implementation CheckSectionData
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"grades" : CheckGradesData.class};
}
@end

@implementation CheckGradesData

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"classes" : CheckClassData.class};
}

@end

@implementation CheckClassData
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"classId":@"id"};
}
@end

@implementation CheckResultData

@end

@implementation CheckTodayResultData
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"item_score" : CheckTodayResultSubData.class};
}
@end

@implementation CheckTodayResultSubData

@end

@implementation StudentInfoData
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"studentId":@"id"};
}
@end

@implementation AreaInfoData

@end
