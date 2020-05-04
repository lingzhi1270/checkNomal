//
//  GradeProofVideoCell.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/16.
//

#import "GradeProofVideoCell.h"
#import "ProofCollectionItem.h"
#import <LibDataModel/ACMediaModel.h>

@interface GradeProofVideoCell()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ProofCollectionItemDelegate>
@property (nonatomic, strong) UICollectionView *videoCollectionView;
@end

@implementation GradeProofVideoCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.videoButton.layer.cornerRadius = 4;
        self.videoButton.layer.masksToBounds = YES;
        [self.videoButton setBackgroundImage:[UIImage imageNamed:@"checkVideoImage" bundleName:@"ModCommonCheckStyle1"] forState:UIControlStateNormal];
        [self.videoButton addTarget:self action:@selector(videoButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [CONTENT_VIEW addSubview:self.videoButton];
        
        [self.videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
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
    
    self.videoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    self.videoCollectionView.backgroundColor = [UIColor whiteColor];
    self.videoCollectionView.showsVerticalScrollIndicator = NO;
    self.videoCollectionView.showsHorizontalScrollIndicator = NO;
    self.videoCollectionView.delegate = self;
    self.videoCollectionView.dataSource = self;
    
    [self.videoCollectionView registerClass:[ProofCollectionItem class] forCellWithReuseIdentifier:@"VideoProofCollectionItem"];
    [self addSubview:self.videoCollectionView];

    [self.videoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.videoButton.mas_right).offset(10);
        make.height.centerY.equalTo(self.videoButton);
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
  return self.videoDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
        ProofCollectionItem *videoItem = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoProofCollectionItem" forIndexPath:indexPath];
        videoItem.delegate = self; 
        ACMediaModel *model = self.videoDataArray[indexPath.row];
        [videoItem showIconWithUrlString:nil image:model.image];
        [videoItem videoImage:nil show:YES];
        [videoItem deleteButtonWithImage:nil show:YES];
        return videoItem;
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

- (void)videoButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordVideoDataSourceCount)]) {
        [self.delegate recordVideoDataSourceCount];
    }
}

#pragma mark- ProofCollectionItemDelegate
- (void)ClickCellDeleteButton:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCellVideoDeleteButton:)]) {
        [self.delegate clickCellVideoDeleteButton:indexPath];
    }
}

- (void)setVideoDataArray:(NSMutableArray *)videoDataArray
{
    _videoDataArray = videoDataArray;
    [self.videoCollectionView reloadData];
}
@end
