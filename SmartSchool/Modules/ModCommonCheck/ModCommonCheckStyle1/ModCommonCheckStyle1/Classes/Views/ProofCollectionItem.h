//
//  ProofCollectionItem.h
//  AFNetworking
//
//  Created by lingzhi on 2020/1/14.
//

#import <LibComponentBase/ConfigureHeader.h>
NS_ASSUME_NONNULL_BEGIN
@protocol ProofCollectionItemDelegate <NSObject>

- (void)ClickCellDeleteButton:(NSIndexPath *)indexPath;

@end
@interface ProofCollectionItem : UICollectionViewCell

/** 点击删除按钮的回调block */
@property (nonatomic, assign)id<ProofCollectionItemDelegate> delegate;


- (void)showIconWithUrlString: (NSString *)urlString image: (UIImage *)image;

- (void)deleteButtonWithImage: (UIImage *)deleteImage show: (BOOL)show;

- (void)videoImage: (UIImage *)videoImage show: (BOOL)show;

@end

NS_ASSUME_NONNULL_END
