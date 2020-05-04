//
//  GradeProofImageCell.h
//  AFNetworking
//
//  Created by lingzhi on 2020/1/16.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN
@protocol GradeProofImageCellDelegate <NSObject>

- (void)recordImageDataSourceCount;

- (void)ClickCellImageDeleteButton:(NSIndexPath *)indexPath;

@end
@interface GradeProofImageCell : UITableViewCell
@property (nonatomic ,strong)UIButton *imageButton;

@property (nonatomic ,strong)NSMutableArray *imageDataArray;
@property (nonatomic ,assign)id<GradeProofImageCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
