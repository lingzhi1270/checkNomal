//
//  CheckGradeViewController.h
//  AFNetworking
//
//  Created by lingzhi on 2020/1/13.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/CheckClassData.h>
NS_ASSUME_NONNULL_BEGIN

@interface CheckGradeViewController : BaseViewController
@property (nonatomic, copy)NSString *mainKeyId;

@property (nonatomic, assign)CheckGradeFromType cheackGradeFromType;//0-个人  1-班级  2-包干区

@property (nonatomic, strong)NSNumber *classId;//班级id

@property (nonatomic, strong)CheckGradesData *tipGradesData;//记录年级
@property (nonatomic, strong)CheckClassData *tipClassData;//记录班级

@property (nonatomic, strong)NSNumber *studentId;//个人学号

@property (nonatomic, strong)NSNumber *areaId;//个人学号


@end

NS_ASSUME_NONNULL_END
