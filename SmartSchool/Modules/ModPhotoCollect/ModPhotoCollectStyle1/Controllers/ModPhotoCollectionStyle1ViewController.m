//
//  ModPhotoCollectionStyle1ViewController.m
//  Unilife
//
//  Created by 唐琦 on 2019/9/7.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ModPhotoCollectionStyle1ViewController.h"
#import "CameraManager.h"
#import "CameraDetailViewController.h"
#import <MJRefresh/MJRefresh.h>

@interface CameraTaskCell : UITableViewCell

@property (nonatomic, strong) CameraTaskData        *task;
@property (nonatomic, strong) UIView                *backView;
@property (nonatomic, strong) UIView                *progressView;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *progressLabel;
@property (nonatomic, strong) UIImageView           *avatarView;
@property (nonatomic, strong) UILabel               *timeLabel;

@end

@implementation CameraTaskCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSInteger padding = 8;
        self.backView = [UIView new];
        [CONTENT_VIEW addSubview:self.backView];
        [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(padding);
            make.right.equalTo(CONTENT_VIEW).offset(-padding);
            make.top.equalTo(CONTENT_VIEW).offset(padding);
            make.bottom.equalTo(CONTENT_VIEW).offset(-padding);
        }];
        self.backView.layer.cornerRadius = padding;
        self.backView.layer.masksToBounds = YES;
        
        self.progressView = [UIView new];
        [self.backView addSubview:self.progressView];
        
        self.avatarView = [UIImageView new];
        [CONTENT_VIEW addSubview:self.avatarView];
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backView).offset(16);
            make.centerY.equalTo(CONTENT_VIEW);
        }];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:19];
        self.titleLabel.textColor = [UIColor whiteColor];
        [CONTENT_VIEW addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarView.mas_right).offset(16);
            make.centerY.equalTo(CONTENT_VIEW);
        }];
        
        self.progressLabel = [UILabel new];
        self.progressLabel.textAlignment = NSTextAlignmentCenter;
        self.progressLabel.numberOfLines = 2;
        [CONTENT_VIEW addSubview:self.progressLabel];
        [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backView);
            make.bottom.equalTo(self.backView);
            make.left.greaterThanOrEqualTo(self.titleLabel.mas_right);
            make.right.equalTo(self.backView).offset(-8);
            make.centerY.equalTo(self.backView);
        }];
        
        self.timeLabel = [UILabel new];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.font = [UIFont systemFontOfSize:14];
        [CONTENT_VIEW addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(self.titleLabel.mas_right);
            make.right.equalTo(self.backView).offset(-8);
            make.bottom.equalTo(self.backView).offset(-8);
        }];
    }
    
    return self;
}

- (void)setTask:(CameraTaskData *)task {
    CGFloat progress = (CGFloat)task.finished / task.total;
    [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backView);
        make.bottom.equalTo(self.backView);
        make.left.equalTo(self.backView);
        make.width.equalTo(self.backView).multipliedBy(progress);
    }];
    
    [self layoutIfNeeded];
    
    self.titleLabel.text = task.name;
    NSString *string = [NSString stringWithFormat:@"\n%ld / %ld", (long)task.finished, (long)task.total];
    self.progressLabel.attributedText = [NSAttributedString attributedStringWithString:@"已采集" font:[UIFont systemFontOfSize:15] color:[UIColor whiteColor]
                                                                                string:string font:[UIFont systemFontOfSize:17] color:[UIColor whiteColor]];
    string = [NSString stringWithFormat:@"%ld月%ld日", (long)task.dateEnd.month, (long)task.dateEnd.day];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ 截止", string];
    
    NSArray *colors = [CameraManager shareManager].taskColors;
    NSInteger index = task.uid % colors.count;
    NSDictionary *color = colors[index];
    self.backView.backgroundColor = color[@"total"];
    self.progressView.backgroundColor = color[@"finished"];
    
    if (task.total == 1) {
        self.avatarView.image = [UIImage imageNamed:@"ic_avatar_person"];
    }
    else {
        self.avatarView.image = [UIImage imageNamed:@"ic_avatar_people"];
    }
}

@end

@interface ModPhotoCollectionStyle1ViewController () < UITableViewDataSource, UITableViewDelegate >
@property (nonatomic, strong) NSMutableArray    *data;
@property (nonatomic, strong) VITableView       *tableView;
@property (nonatomic, strong) NSArray           *dataArray;

@end

@implementation ModPhotoCollectionStyle1ViewController

- (void)loadView {
    ThemeView *view = [ThemeView new];
    
    VITableView *tableView = [[VITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [tableView setEmptyImage:[UIImage imageNamed:@"ic_data_empty"] emptyString:@"暂无采集任务"];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.right.equalTo(view);
        make.top.equalTo(view).offset(64);
        make.bottom.equalTo(view);
    }];
    
    [tableView registerClass:[CameraTaskCell class] forCellReuseIdentifier:[CameraTaskCell reuseIdentifier]];
    tableView.tableFooterView = [UIView new];
    
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                           refreshingAction:@selector(pullToRefresh:)];
    
    self.tableView = tableView;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[CameraManager shareManager] updateExtraInfo];
}

- (void)pullToRefresh:(MJRefreshNormalHeader *)header {
    [[CameraManager shareManager] requestCameraTaskWithAction:YuCloudDataList
                                                       taskid:0
                                                         info:nil
                                                   completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                       [header endRefreshing];
                                                       DDLog(@"%@", NSTemporaryDirectory());
                                                       self.dataArray = [[CameraManager shareManager] allTask];
                                                       [[CameraManager shareManager] allTaskWithCompletion:^(BOOL success, NSArray * _Nullable resultArray) {
                                                           self.dataArray = resultArray;

                                                           dispatch_async_on_main_queue(^{
                                                               [self.tableView reloadData];
                                                           });
                                                       }];
                                                   }];
}

- (void)showAppMenu {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 刷新界面
    [self.tableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[CameraTaskCell reuseIdentifier] forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(CameraTaskCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:cell atIndexPath:indexPath];
}

- (void)configureCell:(CameraTaskCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.task = self.dataArray[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CameraTaskData *task = self.dataArray[indexPath.row];
    CameraDetailViewController *detail = [[CameraDetailViewController alloc] initWithTask:task];
    [self.navigationController pushViewController:detail animated:YES];
}

@end
