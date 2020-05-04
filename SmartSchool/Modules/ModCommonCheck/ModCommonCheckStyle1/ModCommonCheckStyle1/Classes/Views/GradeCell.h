//
//  GradeCell.h
//  AFNetworking
//
//  Created by lingzhi on 2020/1/13.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/CheckGradeData.h>
NS_ASSUME_NONNULL_BEGIN

@protocol GradeCellDelegate <NSObject>
- (void)clickDeductionButton:(NSIndexPath *)indexPath;

- (void)clickAddButton:(NSIndexPath *)indexPath;

@end

@interface GradeCell : UITableViewCell
@property (nonatomic ,strong)UILabel *titleLabel;

@property (nonatomic ,strong)UIButton *addButton;

@property (nonatomic ,strong)UILabel *gradeLabel;

@property (nonatomic ,strong)NSNumber *subId;

@property (nonatomic, assign)id<GradeCellDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
