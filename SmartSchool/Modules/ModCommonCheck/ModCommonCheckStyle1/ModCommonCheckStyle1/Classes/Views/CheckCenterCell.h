//
//  CheckCenterCell.h
//  AFNetworking
//
//  Created by lingzhi on 2020/1/8.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CheckCenterCellDelegate <NSObject>

- (void)checkResultButtonClick;

@end
@interface CheckCenterCell : UICollectionViewCell
@property (nonatomic, assign) id<CheckCenterCellDelegate>     delegate;

@property (nonatomic, copy) NSString *teacherName;

@end

NS_ASSUME_NONNULL_END
