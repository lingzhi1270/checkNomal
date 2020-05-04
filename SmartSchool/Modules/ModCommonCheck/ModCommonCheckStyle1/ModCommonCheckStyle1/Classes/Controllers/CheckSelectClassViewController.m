//
//  CheckSelectClassViewController.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/10.
//

#import "CheckSelectClassViewController.h"
#import "CheckClassCell.h"
#import "CheckClassTopCell.h"
#import "CheckClassCollectionViewSectionHeaderView.h"
#import <ModCommonCheckBase/CommonCheckManager.h>
#import <LibDataModel/CheckClassData.h>

#import "CheckGradeViewController.h"

@interface CheckSelectClassViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    CheckGradesData *_tipGradesData;//记录年级
}

@property (nonatomic, strong) UICollectionView      *collectionView;

@property (nonatomic, strong) NSMutableArray        *dataArray;

@property (nonatomic, strong) CommonSelectorView    *selectorView;

@property (nonatomic, strong) NSMutableArray        *classArray;

@property (nonatomic, strong) NSMutableArray        *classIdArray;

@property (nonatomic, strong) NSMutableArray        *tipClassNOArray;//记录班级
@end

@implementation CheckSelectClassViewController

- (void)loadView
{
       [super loadView];
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, KTopViewHeight, SCREENWIDTH, SCREENHEIGHT-KTopViewHeight) collectionViewLayout:layout];

        self.collectionView = collectionView;
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.alwaysBounceVertical = YES;
        [self.collectionView registerClass:[CheckClassTopCell class] forCellWithReuseIdentifier:@"CheckClassTopCell"];
        [self.collectionView registerClass:[CheckClassCell class]
                forCellWithReuseIdentifier:@"CheckClassCell"];
        [self.collectionView registerClass:[CheckClassCollectionViewSectionHeaderView class]
             forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                    withReuseIdentifier:@"CheckClassCollectionViewSectionHeaderView"];

        [self.view addSubview:self.collectionView];
    
    self.selectorView = [[CommonSelectorView alloc] initWithPickerMode:PickerModeSingle];
    self.selectorView.title = @"选择班级";
    [self.view addSubview:self.selectorView];
    
    WEAK(self, weakSelf);
       self.selectorView.singleBlock = ^(NSInteger index) {
//           DDLog(@"选中第%d个", (int)index);
        
           CheckGradeViewController *gradeVC = [[CheckGradeViewController alloc] initWithTitle:self.title rightItem:nil];
           gradeVC.mainKeyId = self.mainKeyId;
           gradeVC.classId = self.classIdArray[index];
           gradeVC.tipGradesData = _tipGradesData;
           gradeVC.tipClassData = self.tipClassNOArray[index];
           gradeVC.cheackGradeFromType = self.cheackGradeFromType;
           [self.navigationController pushViewController:gradeVC animated:YES];
       };
    
    [self.selectorView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.edges.equalTo(self.view);
       }];
        
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __block MBProgressHUD *hud = [MBProgressHUD showHudOn:self.view
                                                       mode:MBProgressHUDModeIndeterminate
                                                      image:nil
                                                    message:@""
                                                  delayHide:NO
                                                 completion:nil];
    
    [[CommonCheckManager shareManager] getCommonCheckClassRequstWithInspectId:self.mainKeyId Completion:^(BOOL success, NSDictionary * _Nullable info) {
        [hud hideAnimated:YES];
             if (success) {
                 [self.dataArray removeAllObjects];
                 NSArray *dataArray = info[@"extra"];
                    for (NSDictionary *dic in dataArray) {
                        CheckSectionData *sectionModel = [CheckSectionData modelWithDictionary:dic];
                        [self.dataArray addObject:sectionModel];
                    }
                    [self.collectionView reloadData];
             }
             else
             {
                 hud = [MBProgressHUD showFinishHudOn:self.view
                                           withResult:NO
                                         labelText:info[@"error_msg"]
                                         delayHide:YES
                                         completion:nil];
             }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.classArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.classIdArray = [[NSMutableArray alloc] initWithCapacity:0];

    self.tipClassNOArray = [[NSMutableArray alloc] initWithCapacity:0];
}

#pragma mark -- UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataArray.count + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else
    {
       CheckSectionData *sectionData = (CheckSectionData *)self.dataArray[section - 1];
       return sectionData.grades.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        CheckClassTopCell *topCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CheckClassTopCell" forIndexPath:indexPath];
        return topCell;
    }
    else
    {
        CheckSectionData *sectionData = (CheckSectionData *)self.dataArray[indexPath.section-1];
        CheckClassCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CheckClassCell" forIndexPath:indexPath];
        
        CheckGradesData *gradesData = (CheckGradesData *)sectionData.grades[indexPath.row];
        cell.classNameTitle = gradesData.grade_name;
        return cell;
    }
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:@"CheckClassCollectionViewSectionHeaderView"
                                                         forIndexPath:indexPath];
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        CheckSectionData *sectionData = (CheckSectionData *)self.dataArray[indexPath.section-1];
         if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
               CheckClassCollectionViewSectionHeaderView *headerView = (CheckClassCollectionViewSectionHeaderView *)view;
               headerView.backgroundColor = [UIColor whiteColor];
               headerView.title = sectionData.name;
           }
    }
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (section == 0)
    {
         return UIEdgeInsetsMake(0, 0, 0, 0);//（上、左、下、右）
    }
    return UIEdgeInsetsMake(0, 30, 0, 30);//（上、左、下、右）
}

- (CGSize)collectionView:(VICollectionView *)collectionView
                  layout:(UICollectionViewFlowLayout *)layout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.bounds);
   
    if (indexPath.section == 0) {
         return CGSizeMake(width, ((SCREENWIDTH-15*2)*0.4+30));
    }
    else
    {
        CGFloat itemWith = (width-120)/3;
        return CGSizeMake(itemWith, (itemWith/5)*2);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewFlowLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
 
    if (section == 0) {
         return CGSizeMake(0, 0);
    }
    else{
        return CGSizeMake(.1, 65);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    switch (section) {
        case 0:
             return 0;

        default:
             return 20;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {

    switch (section) {
           case 0:
                return 0;

           default:
                return 30;
       }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section != 0) {
       CheckSectionData *sectionData = self.dataArray[indexPath.section-1];
       CheckGradesData *gradesData = sectionData.grades[indexPath.row];
        _tipGradesData = gradesData;
        [self.classArray removeAllObjects];
        [self.classIdArray removeAllObjects];
        [self.tipClassNOArray removeAllObjects];
        [gradesData.classes enumerateObjectsUsingBlock:^(CheckClassData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CheckClassData *classData = gradesData.classes[idx];
            [self.classArray addObject:classData.name];
            [self.classIdArray addObject:classData.classId];
            [self.tipClassNOArray addObject:classData];
        }];
        
        self.selectorView.singleDataSource = self.classArray;
        self.selectorView.defaultFont = [UIFont systemFontOfSize:18];
        [self.selectorView showView];
    }
}
@end
