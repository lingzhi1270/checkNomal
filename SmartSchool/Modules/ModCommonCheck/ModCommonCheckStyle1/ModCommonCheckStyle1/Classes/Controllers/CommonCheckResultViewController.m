//
//  CommonCheckResultViewController.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/9.
//

#import "CommonCheckResultViewController.h"
#import "CommonCheckResultCell.h"
#import "CheckResultQureyListViewController.h"
#import <ModCommonCheckBase/CommonCheckManager.h>
#import <LibDataModel/CommonCheckData.h>
#import <LibDataModel/CheckClassData.h>
#import "CheckTodayResultListViewController.h"
#import <ModLoginBase/AccountManager.h>
@interface CommonCheckResultViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UILabel *_selectClassLabel;
    UILabel *_selectTimeLabel;
}
@property (nonatomic ,strong)UITableView *tableView;

@property (nonatomic, strong) NSMutableArray        *sectionDataArray;
@end

@implementation CommonCheckResultViewController

- (void)loadView
{
    [super loadView];
       self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KTopViewHeight, SCREENWIDTH, SCREENHEIGHT-KTopViewHeight) style:UITableViewStylePlain];
       self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
       self.tableView.dataSource = self;
       self.tableView.delegate = self;
       [self.tableView registerClass:[CommonCheckResultCell class] forCellReuseIdentifier:@"CommonCheckResultCell"];
       [self.view addSubview:self.tableView];
       
       self.tableView.tableHeaderView = [self tableViewHeadViewLayout];
}

- (void)refreshWithReloadHeader
{
    [[CommonCheckManager shareManager] getCommonCheckInfoWithUserId:ACCOUNT_USERID deptCode:@"" gradeNo:@"" completion:^(BOOL success, NSDictionary * _Nullable info) {
              [self.tableView.mj_header endRefreshing];
              if (success) {
                      [self.dataArray removeAllObjects];
                      for (NSDictionary *dataDic in info[@"data"]) {
                              CommonCheckData *model = [CommonCheckData modelWithDictionary:dataDic];
                              [self.dataArray addObject:model];
                      }
                  [self.tableView reloadData];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sectionDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    
     MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshWithReloadHeader)];
        [header setTitle:@"下拉即可刷新" forState:MJRefreshStateIdle];
        [header setTitle:@"释放即可刷新" forState:MJRefreshStatePulling];
        [header setTitle:@"正在加载" forState:MJRefreshStateRefreshing];
    //    header.lastUpdatedTimeLabel.hidden = YES;
        header.lastUpdatedTimeLabel.textColor = [UIColor colorWithHexString:@"#999999"];
             
        header.stateLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        self.tableView.mj_header = header;
}

#pragma mark- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommonCheckResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommonCheckResultCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.contentLabel.text = @"当日汇总表";
    }
    else
    {
        CommonCheckData *model = self.dataArray[indexPath.row - 1];
        cell.contentLabel.text = model.name;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableViewHeadViewLayout
{
        UIView * headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 80)];
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
 
         UIView *bottomLine = [UIView new];
         bottomLine.backgroundColor = [UIColor colorFromHex:0xDCDCDC];
         [headView addSubview:bottomLine];
    
         [checkPersonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.equalTo(headView.mas_left).offset(25);
             make.right.equalTo(headView.mas_right).offset(-20);
             make.top.equalTo(headView.mas_top).offset(20);
             make.height.equalTo(@37.5);
         }];

       [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView.mas_left).offset(20);
        make.right.equalTo(headView);
        make.bottom.equalTo(headView.mas_bottom).offset(-0.8);
        make.height.equalTo(@0.8);
      }];

    return headView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
            CheckTodayResultListViewController *checkTodayResultListVC = [[CheckTodayResultListViewController alloc] initWithTitle:@"当日汇总表" rightItem:nil];
           [self.navigationController pushViewController:checkTodayResultListVC animated:YES];
    }
    else
    {
            CommonCheckData *model = self.dataArray[indexPath.row - 1];
            CheckResultQureyListViewController *checkResultQureyListVC = [[CheckResultQureyListViewController alloc] initWithTitle:model.name rightItem:nil];
            checkResultQureyListVC.mainKeyId = model.mainKeyId;
            [self.navigationController pushViewController:checkResultQureyListVC animated:YES];
    }
}

@end
