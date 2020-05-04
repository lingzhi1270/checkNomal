//
//  FriendRequestViewController.m
//  Unilife
//
//  Created by 唐琦 on 2019/7/13.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "FriendRequestViewController.h"
#import "FriendRequestInfoViewController.h"
#import <ModLoginBase/UserManager.h>
#import <ModContactBase/ContactManager.h>
#import <LibTheme/ThemeManager.h>

@protocol FriendRequestCellDelegate <NSObject>

- (void)acceptRequestWithRequest:(FriendRequestData *)data;
- (void)viewConnectInfo:(FriendRequestData *)data;

@end

@interface FriendRequestCell : UITableViewCell

@property (nonatomic, weak) id<FriendRequestCellDelegate>   delegate;

@property (nonatomic, strong) FriendRequestData *data;

@property (nonatomic, strong) UIImageView   *avatarView;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel       *messageLabel;

@property (nonatomic, strong) UIButton      *btnAction;

@end

@implementation FriendRequestCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.avatarView = [UIImageView new];
        [CONTENT_VIEW addSubview:self.avatarView];
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(self.separatorInset.left);
            make.top.equalTo(CONTENT_VIEW).offset(8);
            make.bottom.equalTo(CONTENT_VIEW).offset(-8);
            make.height.equalTo(@40);
            make.width.equalTo(self.avatarView.mas_height);
        }];
        CALayer *layer = self.avatarView.layer;
        layer.cornerRadius = 6;
        layer.masksToBounds = YES;
        layer.borderColor = [UIColor colorWithRGB:0xe0e0e0].CGColor;
        layer.borderWidth = .5;
        
        self.nameLabel = [UILabel new];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:15];
        self.nameLabel.textColor = [UIColor grayColor];
        [CONTENT_VIEW addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarView.mas_right).offset(8);
            make.bottom.equalTo(self.avatarView.mas_centerY);
        }];
        
        self.messageLabel = [UILabel new];
        self.messageLabel.font = [UIFont systemFontOfSize:15];
        self.messageLabel.textColor = [UIColor grayColor];
        [CONTENT_VIEW addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel);
            make.top.equalTo(self.avatarView.mas_centerY);
            make.bottom.equalTo(self.avatarView);
        }];
        
        self.btnAction = [UIButton buttonWithTitleColor:THEME_BUTTON_FOREGROUND_COLOR
                                        backgroundColor:THEME_BUTTON_BACKGROUND_COLOR
                                            cornerRadii:CGSizeMake(6, 6)];
        [self.btnAction addTarget:self
                           action:@selector(touchActionButton)
                 forControlEvents:UIControlEventTouchUpInside];
        
        self.btnAction.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.btnAction setTitle:@"同意" forState:UIControlStateNormal];
        [CONTENT_VIEW addSubview:self.btnAction];
        [self.btnAction mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(CONTENT_VIEW);
            make.left.equalTo(self.nameLabel.mas_right).offset(8);
            make.left.equalTo(self.messageLabel.mas_right).offset(8);
            make.right.equalTo(CONTENT_VIEW).offset(-8);
            make.height.equalTo(@22);
            make.width.equalTo(@58);
        }];
    }
    
    return self;
}

- (void)setData:(FriendRequestData *)data {
    _data = data;
    
    __block void (^setUser)(UserData *user) = ^(UserData *user){
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:user.avatarUrl]
                           placeholderImage:[[UIImage imageNamed:@"ic_user_default_avatar"] imageMaskedWithColor:THEME_BUTTON_BACKGROUND_COLOR]
                                  completed:nil];
        
        self.nameLabel.text = user.nickname;
    };
    
    UserData *user = [[UserManager shareManager] userWithUserid:data.userid];
    if (user) {
        setUser(user);
    }
    
    [[UserManager shareManager] requestUserInfoWithUserid:data.userid
                                             forceRefresh:NO
                                              localholder:^(BOOL success, NSDictionary * _Nullable info) {
                                                  UserData *user = info[@"user"];
                                                  setUser(user);
                                              }
                                               completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                   UserData *user = info[@"user"];
                                                   setUser(user);
                                               }];
    
    self.messageLabel.text = data.message;
    if (data.accepted) {
        [self.btnAction setTitle:@"已同意" forState:UIControlStateNormal];
    }
    else {
        [self.btnAction setTitle:@"同意" forState:UIControlStateNormal];
    }
    self.btnAction.enabled = !data.accepted;
}

- (void)touchActionButton {
    [self.delegate acceptRequestWithRequest:self.data];
}

@end

#pragma mark - FriendRequestViewController

@interface FriendRequestViewController () < UITableViewDataSource, UITableViewDelegate, FriendRequestCellDelegate >
@property (nonatomic, strong) VITableView   *tableView;
@property (nonatomic, strong) NSArray       *dataArray;

@end

@implementation FriendRequestViewController

- (instancetype)init {
    if (self = [super initWithTitle:@"新的朋友" rightItem:nil]) {
        
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    VITableView *tableView = [[VITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [tableView registerClass:[FriendRequestCell class]
      forCellReuseIdentifier:[FriendRequestCell reuseIdentifier]];
    
    tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.safeArea);
    }];
    
    self.tableView = tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray =  [[ContactManager shareManager] allFriendRequest];
    [self.tableView reloadData];
}

- (UIView *)emptyViewWithTitle:(NSString *)title image:(NSString *)imageStr {
    UIView  *emptyView = [[UIView alloc] init];
    emptyView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageStr?imageStr:@"icon_commu_noData"]];
    [emptyView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor colorWithRGB:0xcccccc];
    label.text = title;
    label.font = [UIFont systemFontOfSize:14];
    [emptyView addSubview:label];
    
    UIView *superView = emptyView;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(superView.mas_centerX);
        make.centerY.equalTo(superView.mas_centerY).offset(-80);
    }];
    
    [label sizeToFit];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(20);
        make.centerX.equalTo(superView.mas_centerX);
    }];
    
    return emptyView;
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
    NSInteger num = self.dataArray.count;
    if (!num) {
        tableView.backgroundView = [self emptyViewWithTitle:@"暂无新朋友哦"
                                                      image:@"icon_commu_noData"];
    }
    else {
        tableView.backgroundView = nil;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[FriendRequestCell reuseIdentifier] forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(FriendRequestCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:cell atIndexPath:indexPath];
}

- (void)configureCell:(FriendRequestCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.delegate = self;
    cell.data = self.dataArray[indexPath.row];
}

- (CGFloat)tableView:(VITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.5f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FriendRequestData *data = self.dataArray[indexPath.row];
    FriendRequestInfoViewController *info = [[FriendRequestInfoViewController alloc] initWithRequest:data];
    [self.navigationController pushViewController:info animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                  editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendRequestData *data = self.dataArray[indexPath.row];
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:YUCLOUD_STRING_DELETE  handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[ContactManager shareManager] deleteFriendRequestData:data];
        
        [self.tableView reloadData];
    }];
    
    UITableViewRowAction *reject = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Reject", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        MBProgressHUD *hud = [MBProgressHUD showHudOn:[UIApplication sharedApplication].keyWindow
                                                 mode:MBProgressHUDModeIndeterminate
                                                image:nil
                                              message:YUCLOUD_STRING_PLEASE_WAIT
                                            delayHide:NO
                                           completion:nil];
        
        [[ContactManager shareManager] respondFriendRequestWith:data.requestid
                                                         accept:NO
                                                     completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                         [tableView endEditing:YES];
                                                         [self.tableView reloadData];
                                                         [MBProgressHUD finishHudWithResult:success
                                                                                        hud:hud
                                                                                  labelText:[info errorMsg:success]
                                                                                 completion:nil];
                                                     }];
    }];
    
    return @[delete, reject];
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - FriendRequestCellDelegate
- (void)acceptRequestWithRequest:(FriendRequestData *)data {
    MBProgressHUD *hud = [MBProgressHUD showHudOn:[UIApplication sharedApplication].keyWindow
                                             mode:MBProgressHUDModeIndeterminate
                                            image:nil
                                          message:YUCLOUD_STRING_PLEASE_WAIT
                                        delayHide:NO
                                       completion:nil];
    
    [[ContactManager shareManager] respondFriendRequestWith:data.requestid
                                                     accept:YES
                                                 completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                     [MBProgressHUD finishHudWithResult:success
                                                                                    hud:hud
                                                                              labelText:[info errorMsg:success]
                                                                             completion:nil];
                                                     [self.tableView reloadData];
                                                 }];
}

- (void)viewConnectInfo:(FriendRequestData *)data {
    FriendRequestInfoViewController *connect = [[FriendRequestInfoViewController alloc] initWithRequest:data];
    [self.navigationController pushViewController:connect animated:YES];
}

@end
