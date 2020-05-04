//
//  CameraDetailViewController.m
//  Unilife
//
//  Created by 唐琦 on 2019/9/8.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "CameraDetailViewController.h"
#import "CameraPhotoEditViewController.h"
#import "CameraBrowseViewController.h"
#import "MainNavigationController.h"
#import "CameraManager.h"
#import "SourceManager.h"

@interface CameraPhotoCell : UITableViewCell

@property (nonatomic, strong) CameraPhotoData   *data;

@property (nonatomic, strong) UIImageView       *avatarView;
@property (nonatomic, strong) UILabel           *label;

@end

@implementation CameraPhotoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.avatarView = [UIImageView new];
        [CONTENT_VIEW addSubview:self.avatarView];
        CGFloat left = self.separatorInset.left;
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(left));
            make.top.equalTo(CONTENT_VIEW).offset(8);
            make.bottom.equalTo(CONTENT_VIEW).offset(-8);
            make.width.equalTo(self.avatarView.mas_height).multipliedBy(.62);
        }];
        
        self.label = [UILabel new];
        self.label.font = [UIFont systemFontOfSize:15];
        self.label.numberOfLines = 3;
        [CONTENT_VIEW addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarView.mas_right).offset(8);
            make.top.equalTo(CONTENT_VIEW);
            make.bottom.equalTo(CONTENT_VIEW);
            make.right.equalTo(CONTENT_VIEW);
        }];
    }
    
    return self;
}

- (void)setData:(CameraPhotoData *)data {
    if (data.image_url.length) {
        UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:data.image_url];
        if (image) {
            self.avatarView.image = image;
        }
        else {
            [self.avatarView sd_setImageWithURL:[NSURL URLWithString:data.image_url]
                               placeholderImage:nil
                                      completed:nil];
        }
    }
    else {
        self.avatarView.image = [UIImage imageNamed:@"ic_avatar_empty"];
    }
    
    NSString *stringName = [NSString stringWithFormat:@"姓名：%@", data.name];
    NSString *stringNumber = [NSString stringWithFormat:@"\n\n学号：%@", data.number?:@""];
    
    self.label.attributedText = [NSAttributedString attributedStringWithStrings:stringName, [UIFont boldSystemFontOfSize:15], THEME_TEXT_PRIMARY_COLOR,
                                 stringNumber, [UIFont systemFontOfSize:15], THEME_TEXT_PRIMARY_COLOR, nil];
}

@end

@interface CameraDetailViewController () < UITableViewDataSource, UITableViewDelegate >
@property (nonatomic, strong) CameraTaskData    *task;
@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, strong) NSArray           *dataArray;

@end

@implementation CameraDetailViewController

- (instancetype)initWithTask:(CameraTaskData *)task {
    if (self = [self init]) {
        self.task = task;
    }
    
    return self;
}

- (void)loadView {
    ThemeView *view = [ThemeView new];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    [view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.right.equalTo(view);
        make.top.equalTo(view).offset(64);
        make.bottom.equalTo(view);
    }];
    
    [tableView registerClass:[CameraPhotoCell class] forCellReuseIdentifier:[CameraPhotoCell reuseIdentifier]];
    tableView.tableFooterView = [UIView new];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = THEME_CONTENT_SEPARATOR_COLOR;
    tableView.backgroundColor = THEME_CONTENT_SEPARATOR_COLOR;
    
    self.tableView = tableView;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"采集进度";
    
    [[CameraManager shareManager] requestCameraPickWithAction:YuCloudDataList
                                                       taskid:(NSInteger)self.task.uid
                                                          uid:0
                                                     imageUrl:nil
                                                  originalUrl:nil
                                                   completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                       if (success) {
                                                           [[CameraManager shareManager] photosWithTask:self.task.uid completion:^(BOOL success, NSArray * _Nullable resultArray) {
                                                               self.dataArray = resultArray;
                                                               
                                                               dispatch_async_on_main_queue(^{
                                                                   [self.tableView reloadData];
                                                               });
                                                           }];
                                                       }
                                                   }];
}

- (void)startTakingAvatar:(CameraPhotoData *)data {
    [[CameraManager shareManager] taskWithId:data.taskid completion:^(BOOL success, NSDictionary * _Nullable info) {
        CameraTaskData *task = info[@"data"];
        
        if ([task.dateEnd compare:[NSDate date]] == NSOrderedAscending) {
            [YuAlertViewController showAlertWithTitle:nil
                                              message:@"采集任务已经结束，不能再修改"
                                       viewController:self
                                              okTitle:YUCLOUD_STRING_OK
                                             okAction:nil
                                          cancelTitle:nil
                                         cancelAction:nil
                                           completion:nil];
            return;
        }
        
        [[SourceManager shareManager] getSourcesWithLimit:1
                                                     type:PHAssetMediaTypeImage
                                           viewController:self
                                                     crop:NO
                                                   upload:NO
                                                uploadKey:nil
                                            uploadQuality:0.9
                                          fileLengthLimit:0
                                           withCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                                               if (success) {
                                                   NSArray *arr = info[@"images"];
                                                   NSDictionary *item = arr.firstObject;
                                                   UIImage *image = item[@"image"];
                                                   
                                                   CameraPhotoEditViewController *photo = [[CameraPhotoEditViewController alloc] initWithPhoto:data
                                                                                                                                         image:image];
                                                   [self presentViewController:[[MainNavigationController alloc] initWithRootViewController:photo]
                                                                      animated:YES
                                                                    completion:nil];
                                               }
                                               else {
                                                   // 可能是选择失败，也可能是用户取消了
                                               }
                                           }];

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[CameraPhotoCell reuseIdentifier] forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    CameraPhotoData *data = self.dataArray[section];
    if (data.image_url.length) {
        return @"已采集";
    }
    else {
        return @"未采集";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *reuseIdentifier = @"tableViewHeader";
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
    if (!view) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:reuseIdentifier];
        view.textLabel.textColor = THEME_TEXT_PRIMARY_COLOR;
    }
    
    view.contentView.backgroundColor = THEME_CONTENT_SEPARATOR_COLOR;
    return view;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(CameraPhotoCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.data = self.dataArray[indexPath.section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CameraPhotoData *data = self.dataArray[indexPath.section];
    
    if (data.image_url.length) {
        CameraBrowseViewController *browse = [[CameraBrowseViewController alloc] initWithTask:data.taskid photo:data.uid];
        [self.navigationController pushViewController:browse animated:YES];
    }
    else {
        [self startTakingAvatar:data];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.task.dateEnd compare:[NSDate date]] == NSOrderedAscending) {
        return NO;
    }
    
    CameraPhotoData *data = self.dataArray[indexPath.section];
    return data.image_url.length > 0;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    CameraPhotoData *data = self.dataArray[indexPath.section];
    UITableViewRowAction *replace = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Replace", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self startTakingAvatar:data];
        [tableView reloadData];
    }];
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:YUCLOUD_STRING_DELETE handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        MBProgressHUD *hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                                 mode:MBProgressHUDModeIndeterminate
                                                image:nil
                                              message:YUCLOUD_STRING_PLEASE_WAIT
                                            delayHide:NO
                                           completion:nil];
        
        [[CameraManager shareManager] requestCameraPickWithAction:YuCloudDataEdit
                                                           taskid:(NSInteger)data.taskid
                                                              uid:(NSInteger)data.uid
                                                         imageUrl:@""
                                                      originalUrl:nil
                                                       completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                           [tableView reloadData];
                                                           [MBProgressHUD finishHudWithResult:success
                                                                                          hud:hud
                                                                                    labelText:[info errorMsg:success]
                                                                                   completion:^{
                                                                                       
                                                                                   }];
                                                       }];
    }];
    
    return @[delete, replace];
}

@end
