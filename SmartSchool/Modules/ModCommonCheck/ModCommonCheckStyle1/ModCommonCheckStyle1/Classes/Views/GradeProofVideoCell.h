//
//  GradeProofVideoCell.h
//  AFNetworking
//
//  Created by lingzhi on 2020/1/16.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GradeProofVideoCellDelegate <NSObject>

- (void)recordVideoDataSourceCount;

- (void)clickCellVideoDeleteButton:(NSIndexPath *)indexPath;
@end

@interface GradeProofVideoCell : UITableViewCell

@property (nonatomic ,strong)UIButton *videoButton;
@property (nonatomic ,strong)NSMutableArray *videoDataArray;
@property (nonatomic ,assign)id<GradeProofVideoCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
