//
//  CheckTodayResultListViewController.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/15.
//

#import "CheckTodayResultListViewController.h"
#import "ZFDataTableView.h"
#import "CheckClassCell.h"
#import "CheckClassTopCell.h"
#import "CheckClassCollectionViewSectionHeaderView.h"
#import <ModCommonCheckBase/CommonCheckManager.h>
#import <ModLoginBase/AccountManager.h>

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ItemWidth (ScreenWidth-20)/3
#define ItemHeight 48
@interface CheckTodayResultListViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UILabel *_selectClassLabel;
    CheckSectionData *_sectionModel;
    CheckGradesData  *_gradesModel;
    CheckClassData   *_classModel;
}

@property (nonatomic ,strong) UITableView *tableView;

@property (nonatomic, strong) UIView *headView;
/** x方向数据*/
@property (nonatomic, strong) NSArray *arrX;
/** y方向数据*/
@property (nonatomic, strong) NSMutableArray *arrY;

@property (nonatomic, strong) CommonSelectorView    *selectorView;

@property (nonatomic, strong)NSMutableArray *sectionDataArray;//年级数据源

@end

@implementation CheckTodayResultListViewController
- (void)loadView
{
    [super loadView];
       self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KTopViewHeight, SCREENWIDTH, SCREENHEIGHT-KTopViewHeight) style:UITableViewStylePlain];
       self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
       self.tableView.dataSource = self;
       self.tableView.delegate = self;
//       self.tableView.estimatedRowHeight = 100;
//       self.tableView.rowHeight = UITableViewAutomaticDimension;
       [self.view addSubview:self.tableView];
       
       self.tableView.tableHeaderView = [self tableViewHeadViewLayout];
    
       self.selectorView = [[CommonSelectorView alloc] initWithPickerMode:PickerModeMulti];
       self.selectorView.title = @"选择班级";
       [self.view addSubview:self.selectorView];
       
       WEAK(self, weakSelf);
       self.selectorView.multiBlock = ^(NSArray<NSNumber *> * _Nonnull indexs) {
//         DDLog(@"%@", indexs);
           
         _sectionModel = self.sectionDataArray[[indexs.firstObject intValue]];
         _gradesModel = _sectionModel.grades[[[indexs objectAtIndex:1] intValue]];
         _classModel = _gradesModel.classes[[indexs.lastObject intValue]];
         _selectClassLabel.text = _classModel.name ? [NSString stringWithFormat:@"%@",_classModel.name]:@"请选择班级";
        [self loadRequest];
       };
       
       [self.selectorView mas_makeConstraints:^(MASConstraintMaker *make) {
              make.edges.equalTo(self.view);
          }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView.mj_header beginRefreshing];
  
}

- (void)loadRequest
{
    __block MBProgressHUD *hud = [MBProgressHUD showHudOn:self.view
                                                                   mode:MBProgressHUDModeIndeterminate
                                                                  image:nil
                                                                message:@""
                                                              delayHide:NO
                                                             completion:nil];
       [[CommonCheckManager shareManager] getCheckTodayResultWithUserId:ACCOUNT_USERID gradeNo:_gradesModel.grade_no classNo:_classModel.class_no date:@"" completion:^(BOOL success, NSDictionary * _Nullable info) {
           [hud hideAnimated:YES];
            if (success) {
                CheckTodayResultData *todayResultData = [CheckTodayResultData modelWithDictionary:info];
                //处理y方向数据
                [self.arrY removeAllObjects];
                [todayResultData.item_score enumerateObjectsUsingBlock:^(CheckTodayResultSubData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSMutableDictionary *datasourceYDic = [[NSMutableDictionary alloc] initWithCapacity:0];
                    [datasourceYDic setObject:_classModel.name forKey:@"date1"];
                    [datasourceYDic setObject:obj.name forKey:@"date2"];
                    [datasourceYDic setObject:[obj.score stringValue] forKey:@"date3"];
                    [self.arrY addObject:datasourceYDic];
                }];
               
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
                [dic removeAllObjects];
                [dic setObject:@"总计" forKey:@"date1"];
                [dic setObject:@"" forKey:@"date2"];
                [dic setObject:[todayResultData.score_total stringValue] forKey:@"date3"];
                [self.arrY addObject:dic];
                [self.tableView reloadData];
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

- (void)commonCheckClassRequst
{
    [[CommonCheckManager shareManager] getCommonCheckClassRequstCompletion:^(BOOL success, NSDictionary * _Nullable info) {
       [self.tableView.mj_header endRefreshing];
        if (success) {
                 [self.sectionDataArray removeAllObjects];
                   NSArray *dataArray = info[@"extra"];
            [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                 CheckSectionData *sectionModel = [CheckSectionData modelWithDictionary:obj];

                 [self.sectionDataArray addObject:sectionModel];
            }];
            
            _sectionModel = self.sectionDataArray.firstObject;
            _gradesModel = self.tipGradesData ? : _sectionModel.grades.firstObject;
            _classModel = self.tipClassData ? : _gradesModel.classes.firstObject;
            [self loadRequest];
            _selectClassLabel.text = _classModel.name ? [NSString stringWithFormat:@"%@",_classModel.name]:@"请选择班级";
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
}

- (void)viewDidLoad {
     [super viewDidLoad];
    //x方向数据
    self.arrX = @[@{@"name1": @"班级"},@{@"name2": @"检查项"},@{@"name3": @"分数"}];
    //y方向数据
    self.arrY = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.sectionDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    
     MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshWithReloadHeader)];
     [header setTitle:@"下拉即可刷新" forState:MJRefreshStateIdle];
     [header setTitle:@"释放即可刷新" forState:MJRefreshStatePulling];
     [header setTitle:@"正在加载" forState:MJRefreshStateRefreshing];
     header.lastUpdatedTimeLabel.hidden = YES;
//     header.lastUpdatedTimeLabel.textColor = [UIColor colorWithHexString:@"#999999"];
             
     header.stateLabel.textColor = [UIColor colorWithHexString:@"#999999"];
     self.tableView.mj_header = header;
}

- (void)refreshWithReloadHeader
{
    [self commonCheckClassRequst];
}

#pragma mark- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return ItemHeight*(_arrY.count+1) + 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
        UIView *footView = [UIView new];
       _headView = [[UIView alloc] initWithFrame:CGRectMake(10, 30, SCREENWIDTH-20, ItemHeight*(_arrY.count+1))];
       _headView.userInteractionEnabled = YES;
       [footView addSubview:_headView];
       for (int i = 0; i < _arrX.count; i++) {
           ZFDataTableView *tableView = [[ZFDataTableView alloc] initWithFrame:CGRectMake(ItemWidth*i, 0, ItemWidth, ItemHeight*(_arrY.count+1)) style:UITableViewStylePlain];

           //x方向 取出key对应的字符串名字
           NSString *xkey = [NSString stringWithFormat:@"name%d",i+1];
           NSString *xname = [_arrX[i] objectForKey:xkey];
           tableView.headerStr = xname;

           //y方向
           NSMutableArray *titleArr2 = [NSMutableArray array];
           for (int j=0; j<_arrY.count; j++) {
               NSString *ykey = [NSString stringWithFormat:@"date%d",i+1];
               NSString *yname = [_arrY[j] objectForKey:ykey];
               [titleArr2 addObject:yname];
           }
           tableView.titleArr = titleArr2;
           [tableView reloadData];
           [_headView addSubview:tableView];
       }
       return footView;
}

- (UIView *)tableViewHeadViewLayout
{
        UIView * headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 140)];
        headView.backgroundColor = [UIColor whiteColor];
    
         UILabel *checkPersonLabel = [[UILabel alloc] init];
         checkPersonLabel.layer.cornerRadius = 14;
         checkPersonLabel.layer.masksToBounds = YES;
         checkPersonLabel.text = [NSString stringWithFormat:@"检查人:%@",ACCOUNT_NAME];
         checkPersonLabel.textColor = [UIColor whiteColor];
         checkPersonLabel.textAlignment = NSTextAlignmentCenter;
         checkPersonLabel.font = [UIFont systemFontOfSize:16];
         checkPersonLabel.backgroundColor = [UIColor colorFromHex:0x6686FD];
         [headView addSubview:checkPersonLabel];
         
    
         UIView *selectBackView = [UIView new];
         selectBackView.userInteractionEnabled = YES;
         selectBackView.backgroundColor = [UIColor whiteColor];
         selectBackView.layer.borderWidth = 0.8;
         selectBackView.layer.borderColor = [UIColor colorFromHex:0x4D7BFD].CGColor;
         selectBackView.layer.cornerRadius = 14.8;
         selectBackView.layer.masksToBounds = YES;
         [headView addSubview:selectBackView];
    
         _selectClassLabel = [[UILabel alloc] init];
         _selectClassLabel.userInteractionEnabled = YES;
         _selectClassLabel.textAlignment = NSTextAlignmentLeft;
         _selectClassLabel.font = [UIFont systemFontOfSize:12];
         _selectClassLabel.text = _classModel.name ? [NSString stringWithFormat:@"%@",_classModel.name]:@"请选择班级";
         [selectBackView addSubview:_selectClassLabel];
         UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectClassAction)];
        [_selectClassLabel addGestureRecognizer:tapGes];
    
    
         UIImageView *iconClassImgV = [[UIImageView alloc] init];
         iconClassImgV.userInteractionEnabled = YES;
         iconClassImgV.contentMode = UIViewContentModeScaleAspectFill;
         iconClassImgV.image = [UIImage imageNamed:@"selectImageView" bundleName:@"ModCommonCheckStyle1"];
         [selectBackView addSubview:iconClassImgV];
    
         UIView *bottomLine = [UIView new];
         bottomLine.backgroundColor = [UIColor colorFromHex:0xDCDCDC];
         [headView addSubview:bottomLine];
         
         [checkPersonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.equalTo(headView.mas_left).offset(20);
             make.right.equalTo(headView.mas_right).offset(-20);
             make.top.equalTo(headView.mas_top).offset(20);
             make.height.equalTo(@37.5);
         }];
         
         [selectBackView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.top.equalTo(checkPersonLabel.mas_bottom).offset(20);
             make.centerX.equalTo(headView);
             make.height.equalTo(@32);
         }];
    
         [iconClassImgV mas_makeConstraints:^(MASConstraintMaker *make) {
             make.centerY.equalTo(selectBackView.mas_centerY);
             make.right.equalTo(selectBackView.mas_right).offset(-15);
             make.width.height.equalTo(@7);
         }];
    
         [_selectClassLabel mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.equalTo(selectBackView.mas_left).offset(14);
             make.top.bottom.equalTo(selectBackView);
             make.right.equalTo(iconClassImgV.mas_left).offset(-12);
         }];
         
         [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.equalTo(headView.mas_left).offset(20);
             make.right.equalTo(headView);
             make.bottom.equalTo(headView.mas_bottom).offset(-0.8);
             make.height.equalTo(@0.8);
         }];

    return headView;
}

- (void)selectClassAction
{
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.sectionDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CheckSectionData *sectionModel = self.sectionDataArray[idx];
            SelectorMultiModel *section = [SelectorMultiModel new];
            section.title = sectionModel.name;
           for (CheckGradesData *data in sectionModel.grades) {
                SelectorMultiModel *grade = [SelectorMultiModel new];
                grade.title = data.grade_name;
                     for (CheckClassData *class in data.classes) {
                            SelectorMultiModel *classModel = [SelectorMultiModel new];
                            classModel.title = class.name;
           
                            [grade.array addObject:classModel];
                        }
           
                [section.array addObject:grade];
            }
           [tempArr addObject:section];
    }];
        self.selectorView.multiDataSource = tempArr.modelCopy;
        self.selectorView.defaultFont = [UIFont systemFontOfSize:18];
        [self.selectorView showView];
}
@end
