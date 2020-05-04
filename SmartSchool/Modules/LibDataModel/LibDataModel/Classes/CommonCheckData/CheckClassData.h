//
//  CheckClassData.h
//  AFNetworking
//
//  Created by lingzhi on 2020/1/10.
//

#import <LibComponentBase/ConfigureHeader.h>
NS_ASSUME_NONNULL_BEGIN

@class CheckGradesData;
@interface CheckSectionData : NSObject
@property (nullable, nonatomic, copy)  NSString         *name;
@property (nullable, nonatomic, strong)NSArray<CheckGradesData *>  *grades;
@property (nullable, nonatomic, copy)  NSString         *code;
@end

@class CheckClassData;
@interface CheckGradesData : NSObject
@property (nullable, nonatomic, strong)NSArray<CheckClassData *>  *classes;
@property (nullable, nonatomic, strong)NSNumber         *grade_no;
@property (nullable, nonatomic, copy)  NSString         *grade_name;
@end
@interface CheckClassData : NSObject
@property (nullable, nonatomic, strong)NSNumber         *classId;
@property (nullable, nonatomic, copy)  NSString         *name;
@property (nullable, nonatomic, strong)NSNumber         *grade_no;
@property (nullable, nonatomic, strong)NSNumber         *class_no;
@end

//检查项结果查询
@interface CheckResultData : NSObject
@property (nullable, nonatomic, copy)NSString           *class_name;
@property (nullable, nonatomic, copy)NSString           *score;
@property (nullable, nonatomic, strong)NSNumber         *grade_no;
@property (nullable, nonatomic, strong)NSNumber         *class_no;
@end

@class CheckTodayResultSubData;
@interface CheckTodayResultData : NSObject
@property (nullable, nonatomic, strong)NSNumber                   *score_total;
@property (nullable, nonatomic, strong)NSArray<CheckTodayResultSubData *>  *item_score;
@end

@interface CheckTodayResultSubData : NSObject
@property (nullable, nonatomic, copy)NSString           *name;
@property (nullable, nonatomic, strong)NSNumber         *score;
@end

//获取个人信息
@interface StudentInfoData : NSObject
@property (nullable, nonatomic, copy)NSString           *studentId;
@property (nullable, nonatomic, copy)NSString           *name;
@property (nullable, nonatomic, strong)NSNumber         *class_id;
@property (nullable, nonatomic, copy)NSString           *class_name;
@property (nullable, nonatomic, copy)NSString           *avatar;
@property (nullable, nonatomic, strong)NSNumber         *grade_no;
@property (nullable, nonatomic, strong)NSNumber         *class_no;

@end

//获取包干区信息
//获取个人信息
@interface AreaInfoData : NSObject
@property (nullable, nonatomic, strong)NSNumber           *area_id;
@property (nullable, nonatomic, copy)NSString             *area_name;
@property (nullable, nonatomic, strong)NSNumber           *class_id;
@property (nullable, nonatomic, copy)NSString             *class_name;
@property (nullable, nonatomic, strong)NSNumber           *grade_no;
@property (nullable, nonatomic, strong)NSNumber           *class_no;
@end

NS_ASSUME_NONNULL_END
