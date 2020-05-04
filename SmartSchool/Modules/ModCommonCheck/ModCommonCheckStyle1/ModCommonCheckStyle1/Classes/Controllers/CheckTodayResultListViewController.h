//
//  CheckTodayResultListViewController.h
//  AFNetworking
//
//  Created by lingzhi on 2020/1/15.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/CheckClassData.h>
NS_ASSUME_NONNULL_BEGIN
@interface CheckTodayResultListViewController : BaseViewController

@property (nonatomic, strong)CheckGradesData *tipGradesData;//记录年级
@property (nonatomic, strong)CheckClassData *tipClassData;//记录班级
@end

NS_ASSUME_NONNULL_END
