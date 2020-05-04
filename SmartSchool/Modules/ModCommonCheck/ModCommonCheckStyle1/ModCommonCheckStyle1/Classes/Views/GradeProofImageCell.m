//
//  GradeProofImageCell.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/16.
//

#import "GradeProofImageCell.h"
#import "ProofCollectionItem.h"
#import <LibDataModel/ACMediaModel.h>
@interface GradeProofImageCell()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ProofCollectionItemDelegate>
@property (nonatomic, strong) UICollectionView *photoCollectionView;

@end
@implementation GradeProofImageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.imageButton.layer.cornerRadius = 4;
        self.imageButton.layer.masksToBounds = YES;
        [self.imageButton setBackgroundImage:[UIImage imageNamed:@"checkPhotoImage" bundleName:@"ModCommonCheckStyle1"] forState:UIControlStateNormal];
        [self.imageButton addTarget:self action:@selector(photoButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [CONTENT_VIEW addSubview:self.imageButton];
        
        [self.imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW.mas_left).offset(20);
            make.top.equalTo(CONTENT_VIEW.mas_top).offset(10);
            make.width.height.equalTo(@55);
        }];
    
        [self configureCollectionView];//布局photoCollectionView和videoCollectionView
    }
    return self;
}

- (void)configureCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
       // 设置UICollectionView为横向滚动
       layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
       
       self.photoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
       self.photoCollectionView.backgroundColor = [UIColor whiteColor];
       self.photoCollectionView.showsVerticalScrollIndicator = NO;
       self.photoCollectionView.showsHorizontalScrollIndicator = NO;
       self.photoCollectionView.delegate = self;
       self.photoCollectionView.dataSource = self;
      
       
       [self.photoCollectionView registerClass:[ProofCollectionItem class] forCellWithReuseIdentifier:@"PhotoProofCollectionItem"];
       [self addSubview:self.photoCollectionView];
    
       [self.photoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(self.imageButton.mas_right).offset(10);
          make.height.centerY.equalTo(self.imageButton);
          make.right.equalTo(self);
       }];
}

#pragma mark- UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
        ProofCollectionItem *photoItem = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoProofCollectionItem" forIndexPath:indexPath];
        photoItem.delegate = self;
        ACMediaModel *model = self.imageDataArray[indexPath.row];
        [photoItem showIconWithUrlString:nil image:model.image];
        [photoItem deleteButtonWithImage:nil show:YES];
        return photoItem;
}
// 设置UIcollectionView整体的内边距（这样item不贴边显示）
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);//（上、左、下、右）
}

// 设置cell大小 itemSize：可以给每一个cell指定不同的尺寸
- (CGSize)collectionView:(VICollectionView *)collectionView
                  layout:(UICollectionViewFlowLayout *)layout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat ItemHight = CGRectGetHeight(collectionView.bounds);
   
    return CGSizeMake(ItemHight, ItemHight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewFlowLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
  
    return CGSizeMake(0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
  
    return 0.f;

}
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
   
    return 10.f;
            
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)photoButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordImageDataSourceCount)]) {
        [self.delegate recordImageDataSourceCount];
    }
}

#pragma mark- ProofCollectionItemDelegate
- (void)ClickCellDeleteButton:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ClickCellImageDeleteButton:)]) {
         [self.delegate ClickCellImageDeleteButton:indexPath];
    }
}

- (void)setImageDataArray:(NSMutableArray *)imageDataArray
{
    _imageDataArray = imageDataArray;
    [self.photoCollectionView reloadData];
}
@end

