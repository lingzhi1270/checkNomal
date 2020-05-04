//
//  CommonCheckManager.h
//  AFNetworking
//
//  Created by lingzhi on 2020/1/7.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonCheckManager : BaseManager
//获取校历
- (void)getSchoolCalendarCompletion:(CommonBlock)completion;

//获取顶级检查项目(常规检查首页面)
- (void)getCommonCheckInfoWithUserId:(NSString *)userId deptCode:(NSString *)deptCode gradeNo:(NSString *)gradeNo completion:(CommonBlock)completion;

//获取学校部门、年级、班级 (传inspectId)
- (void)getCommonCheckClassRequstWithInspectId:(NSNumber *)inspectId Completion:(CommonBlock)completion;
//获取学校部门、年级、班级（不传inspectId）
- (void)getCommonCheckClassRequstCompletion:(CommonBlock)completion;

//根据学号获取个人信息
- (void)getStudentCheckProjectWithStudentId:(NSString *)studentId completion:(CommonBlock)completion;

//获取包干区信息
- (void)getEachareaCheckProjectWithCode:(NSString *)code completion:(CommonBlock)completion;

//获取二级和三级检查项目(获取学校部门、年级、班级)
- (void)getChildClassCheckProjectWithParentId:(NSString *)parentId completion:(CommonBlock)completion;

//检查项结果查询
- (void)getCheckResultWithParentId:(NSString *)parentId gradeNo:(NSNumber *)gradeNo date:(NSString *)date completion:(CommonBlock)completion;

//当日汇总结果查询
- (void)getCheckTodayResultWithUserId:(NSString *)userId gradeNo:(NSNumber *)gradeNo classNo:(NSNumber *)classNo date:(NSString *)date completion:(CommonBlock)completion;

//提交检查信息(班级)
-(void)commitCheckClassResultInfoWithFromType:(NSInteger)type classId:(NSNumber *)targetClassId studentId:(NSString *)studentId areaId:(NSNumber *)areaId imagesIds:(NSString *)imagesIds videoIds:(NSString *)videoIds comment:(NSString *)comment reportUserNo:(NSString *)reportUserNo items:(NSArray*)items completion:(CommonBlock)completion;

@end
NS_ASSUME_NONNULL_END
