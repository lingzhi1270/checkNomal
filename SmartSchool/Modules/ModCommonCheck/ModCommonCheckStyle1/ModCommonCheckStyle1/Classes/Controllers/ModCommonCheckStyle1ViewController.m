//
//  ModCommonCheckStyle1ViewController.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/7.
//

#import "ModCommonCheckStyle1ViewController.h"
#import "CommonCheckCell.h"
#import "BannerCell.h"
#import "CheckCenterCell.h"
#import "CollectionViewSectionHeaderView.h"
#import "CommonCheckResultViewController.h"
#import "CheckSelectClassViewController.h"
#import <ModCommonCheckBase/CommonCheckManager.h>
#import <ModLoginBase/AccountManager.h>
#import <LibDataModel/CommonCheckData.h>
#import "PersonCheckinRegisterViewController.h"
#import <ModScanBase/ScanManager.h>
#import <LibDataModel/CheckClassData.h>
#import "CheckGradeViewController.h"
typedef enum : NSUInteger {
    CheckDataTypeBanner,
    CheckDataTypeApps,
    CheckDataTypeItems,
} HomeDataType;


typedef enum : NSInteger {
    Sunday = 1,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,
} WeekDayType;



#define KBannerViewHeight   ((SCREENWIDTH-15*2)*0.4+10)
#define KTopImageVieHeight  ((SCREENWIDTH-15*2)*0.4/2)
#define cellPading 16

@interface ModCommonCheckStyle1ViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,CheckCenterCellDelegate>
{
    CalendarData *_calendarDataModel;
    
    long mPastWeeksNum;
}

@property (nonatomic, strong) UIImageView           *topImageView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray               *data;

@property (nonatomic, strong)NSMutableArray *checkDataArray;
@end

@implementation ModCommonCheckStyle1ViewController

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
        [self.collectionView registerClass:[BannerCell class]
                forCellWithReuseIdentifier:@"BannerCell"];
        [self.collectionView registerClass:[CollectionViewSectionHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"CollectionViewSectionHeaderView"];
     
        [self.collectionView registerClass:[CheckCenterCell class]
                forCellWithReuseIdentifier:@"CheckCenterCell"];
        [self.collectionView registerClass:[CommonCheckCell class]
                forCellWithReuseIdentifier:@"CommonCheckCell"];
        [self.view addSubview:self.collectionView];
}

- (void)refreshWithReloadHeader
{
    [self dataRequestAction];
}

- (void)dataRequestAction
{
       [[CommonCheckManager shareManager] getCommonCheckInfoWithUserId:ACCOUNT_USERID deptCode:@"" gradeNo:@"" completion:^(BOOL success, NSDictionary * _Nullable info) {
           [self.collectionView.mj_header endRefreshing];
           if (success) {
                   [self.checkDataArray removeAllObjects];
                   for (NSDictionary *dataDic in info[@"data"]) {
                           CommonCheckData *model = [CommonCheckData modelWithDictionary:dataDic];
                           [self.checkDataArray addObject:model];
                   }
               [self.collectionView reloadData];
           }
           else
           {
            [MBProgressHUD showFinishHudOn:self.view
                                                   withResult:NO
                                                 labelText:info[@"error_msg"]
                                                 delayHide:YES
                                                 completion:nil];
           }
       }];
    
    [[CommonCheckManager shareManager] getSchoolCalendarCompletion:^(BOOL success, NSDictionary * _Nullable info) {
//        DDLog(@"%@",info);
        if (success) {
            _calendarDataModel = [CalendarData modelWithDictionary:info];
            NSString *schoolCalendar = [self calendarContentString:_calendarDataModel];
            [NSUserDefaults saveSchoolCalendar:schoolCalendar];
            [self.collectionView reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView.mj_header beginRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.checkDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.data = @[@(CheckDataTypeBanner), @(CheckDataTypeApps), @(CheckDataTypeItems)];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshWithReloadHeader)];
    [header setTitle:@"下拉即可刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"释放即可刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"正在加载" forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
//    header.lastUpdatedTimeLabel.textColor = [UIColor colorWithHexString:@"#999999"];
         
    header.stateLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    self.collectionView.mj_header = header;
}

#pragma mark -- UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.data.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSNumber *number = self.data[section];
    switch ([number integerValue]) {
           case CheckDataTypeBanner:
               return 1;
               
           case CheckDataTypeApps: {
               return 1;
           }
               
           case CheckDataTypeItems:
               return self.checkDataArray.count;
               
           default:
               return 0;
       }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *number = self.data[indexPath.section];
    switch ([number integerValue]) {
        case CheckDataTypeBanner:
        {
            BannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BannerCell" forIndexPath:indexPath];
               
               
            return cell;
        }
            
            break;
            
        case CheckDataTypeApps: {
            CheckCenterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CheckCenterCell" forIndexPath:indexPath];
                        
            cell.delegate = self;
            cell.teacherName = [NSString stringWithFormat:@"%@老师,您好",ACCOUNT_NAME];
            return cell;
        }
            break;
            
        case CheckDataTypeItems:
        {
            CommonCheckCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CommonCheckCell" forIndexPath:indexPath];
            
            cell.checkData = self.checkDataArray[indexPath.row];
            
            return cell;
        }
            break;
            
        default:
            break;
    }
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:@"CollectionViewSectionHeaderView"
                                                         forIndexPath:indexPath];
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        CollectionViewSectionHeaderView *headerView = (CollectionViewSectionHeaderView *)view;
        headerView.backgroundColor = [UIColor whiteColor];
        headerView.title = @"常规检查项";
        headerView.tailContent = [NSUserDefaults schoolCalendar];
    }
}

- (NSString *)calendarContentString:(CalendarData *)calendarData
{
    // 得到当前时间（世界标准时间 UTC/GMT）
    NSDate *nowDate = [NSDate date];
    // 设置系统时区为本地时区
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    // 计算本地时区与 GMT 时区的时间差
    NSInteger interval = [zone secondsFromGMT];
    // 在 GMT 时间基础上追加时间差值，得到本地时间
    nowDate = [nowDate dateByAddingTimeInterval:interval];
    
    long long currentDateInterval = [nowDate timeIntervalSince1970]*1000;
    
    if (calendarData.start_time.length && calendarData.end_time.length) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *stateDate = [dateFormatter dateFromString:calendarData.start_time];
        NSDate *endDate = [dateFormatter dateFromString:calendarData.end_time];
        
        long long longStartInterval = [stateDate timeIntervalSince1970]*1000;
        long long longEndInterval = [endDate timeIntervalSince1970]*1000;
        
        long long pastTime = currentDateInterval - longStartInterval; //过去时间
        long long remainingTime =  longEndInterval - currentDateInterval;//剩余时间
        
        //“第几周”的样式允许在学期结束后几个星期内正常显示
        if (pastTime > 0 && remainingTime + 3 * 1000 * 60 * 60 * 24 * 7 > 0) {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
            [calendar setTimeZone:timeZone];
            NSCalendarUnit *calendarUnit = NSCalendarUnitWeekday;
            NSInteger startDayWeekNum = [calendar component:NSCalendarUnitWeekday fromDate:stateDate];
//            DDLog(@"%d",startDayWeekNum);
            
            double pastWeeks;
            if (startDayWeekNum == Monday) {//周一开学
                pastWeeks = (double) pastTime / (1000 * 60 * 60 * 24 * 7);
            }
            else if(startDayWeekNum == Sunday){//周日开学
                //以周日过后的一周为第一周
                pastTime = pastTime + 1;
                pastWeeks = (double)pastTime / (1000 * 60 * 60 * 24 * 7);
            }
            else{//周二到周六开学
                pastTime = pastTime - (Saturday - startDayWeekNum);
                pastWeeks = (double) pastTime / (1000 * 60 * 60 * 24 * 7) + 1;
            }
            mPastWeeksNum = (long long)pastWeeks;
            if (fmod (pastWeeks, 1) > 0) {//取余
                mPastWeeksNum += (long long)1;
            }
            
            return [NSString stringWithFormat:@"%@  第%ld周",[self currentDateToString:nowDate],mPastWeeksNum];
        }
    }
    return @"";
}

- (NSString *)currentDateToString:(NSDate *)currentDate
{
       NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
       [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
       [formatter setDateFormat:@"yyyy年MM月dd日"];
       NSString *dateString = [formatter stringFromDate:currentDate];
    
       NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
       NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
       [calendar setTimeZone:timeZone];
       NSCalendarUnit *calendarUnit = NSCalendarUnitWeekday;
       NSInteger theWeekday = [calendar component:calendarUnit fromDate:[formatter dateFromString:dateString]];
    
      NSString *weekString;
      switch (theWeekday) {
        case 1:
            weekString = @"周日";
            break;
        case 2:
            weekString = @"周一";
            break;
        case 3:
            weekString = @"周二";
            break;
        case 4:
            weekString = @"周三";
            break;
        case 5:
            weekString = @"周四";
            break;
        case 6:
            weekString = @"周五";
            break;
        case 7:
           weekString = @"周六";
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"%@%@",dateString,weekString];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    NSNumber *number = self.data[section];
       switch ([number integerValue]) {
  
           case CheckDataTypeItems:
           {
              return UIEdgeInsetsMake(12, 30, 0, 30);
           }
           default:
              return UIEdgeInsetsMake(0, 30, 0, 30);//（上、左、下、右）
       }
}

- (CGSize)collectionView:(VICollectionView *)collectionView
                  layout:(UICollectionViewFlowLayout *)layout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    NSNumber *number = self.data[indexPath.section];
    switch ([number integerValue]) {
        case CheckDataTypeBanner:
            return CGSizeMake(width, KBannerViewHeight);
            
        case CheckDataTypeApps: {
            return CGSizeMake(width, (KBannerViewHeight/3)*2);
        }
            
        case CheckDataTypeItems:
        {
            CGFloat itemWith = (width-90)/2;
            return CGSizeMake(itemWith, (itemWith/3)*2);
        }
        default:
            break;
    }
    
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewFlowLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    NSNumber *number = self.data[section];
    switch ([number integerValue]) {
        case CheckDataTypeItems:
            return CGSizeMake(.1, 65);

        default:
            return CGSizeMake(0, 0);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    NSNumber *number = self.data[section];
    switch ([number integerValue]){
        case CheckDataTypeItems:
            return 24;
            
        default:
            return 0;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    NSNumber *number = self.data[section];
    switch ([number integerValue]){
   
        case CheckDataTypeItems:
            return 24;
            
        default:
            return 0;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSNumber *number = self.data[indexPath.section];
    switch ([number integerValue]) {
        case CheckDataTypeApps: {
           
        }
            break;
        case CheckDataTypeItems: {
            CommonCheckData *model = self.checkDataArray[indexPath.row];
            
            if ([[model.object stringValue] isEqualToString:@"0"]) {//个人
                PersonCheckinRegisterViewController *studentCheckinVC = [[PersonCheckinRegisterViewController alloc] initWithTitle:self.title rightItem:nil];
                studentCheckinVC.mainKeyId = [model.mainKeyId stringValue];
                studentCheckinVC.cheackGradeFromType = [model.object integerValue];
                [self.navigationController pushViewController:studentCheckinVC animated:YES];
                
            }
            else if ([[model.object stringValue] isEqualToString:@"1"]) {//年级
                CheckSelectClassViewController *selectClassVC = [[CheckSelectClassViewController alloc] initWithTitle:self.title rightItem:nil];
                selectClassVC.mainKeyId = [model.mainKeyId stringValue];
                selectClassVC.cheackGradeFromType = [model.object integerValue];
                [self.navigationController pushViewController:selectClassVC animated:YES];
            }
            else if ([[model.object stringValue] isEqualToString:@"2"]) {//包干区
                [[ScanManager shareManager] startCodeScanWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
//                    DDLog(@"%@",info);
                    if (success) {
                        [[CommonCheckManager shareManager] getEachareaCheckProjectWithCode:info[@"result"] completion:^(BOOL success, NSDictionary * _Nullable info) {
//                            DDLog(@"%@",info);
                            AreaInfoData *areaInfoData = [AreaInfoData modelWithDictionary:info];
                            CheckGradeViewController *checkGradeVC = [[CheckGradeViewController alloc] initWithTitle:self.title rightItem:nil];
                            checkGradeVC.mainKeyId = [model.mainKeyId stringValue];
                            checkGradeVC.areaId = areaInfoData.area_id;
                            checkGradeVC.classId = areaInfoData.class_id;
                            checkGradeVC.cheackGradeFromType = [model.object integerValue];
                            CheckGradesData *tipGradesData = [CheckGradesData new];
                            tipGradesData.grade_no = areaInfoData.grade_no;
                            checkGradeVC.tipGradesData = tipGradesData;
                            
                            CheckClassData *tipClassData = [CheckClassData new];
                            tipClassData.class_no = areaInfoData.class_no;
                            tipClassData.name = areaInfoData.class_name;
                            checkGradeVC.tipClassData = tipClassData;
                            [self.navigationController pushViewController:checkGradeVC animated:YES];
                        }];
                    }
                }];
            }
            else
            {
                
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark- CheckCenterCellDelegate
- (void)checkResultButtonClick
{
    CommonCheckResultViewController *checkResultVC = [[CommonCheckResultViewController alloc] initWithTitle:@"常规检查结果" rightItem:nil];
    checkResultVC.dataArray = self.checkDataArray;
    [self.navigationController pushViewController:checkResultVC animated:YES];
}
@end
