//
//  ModUserCenterStyle1ViewController.m
//  Unilife
//
//  Created by 唐琦 on 2019/6/13.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ModUserCenterStyle1ViewController.h"
#import <LibTheme/ThemeManager.h>
#import <ModLoginBase/AccountManager.h>
#import <ModLoginBase/UserManager.h>
#import "AccountCell.h"
#import <ModCommonCheckStyle1/ModCommonCheckStyle1ViewController.h>

typedef enum : NSUInteger {
    MeSchool,
    MeUser,
    MeFavourites,
    MeMoney,
    MeChoose,
    MeSettings,
    MeLogout,
} MeCellType;

@interface ModUserCenterStyle1ViewController () < UITableViewDataSource, UITableViewDelegate >
@property (nonatomic, strong) UITableView  *tableView;
@property (nonatomic, strong) NSArray    *data;

@end

@implementation ModUserCenterStyle1ViewController

- (void)loadView {
    [super loadView];
    
    [self hiddenBackButton];
        
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = THEME_CONTENT_SEPARATOR_COLOR;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = THEME_CONTENT_SEPARATOR_COLOR;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[UITableViewCell reuseIdentifier]];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.safeArea);
        make.bottom.equalTo(self.safeArea).offset(-kTabbarHeight);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AccountManager shareManager] addObserver:self
                                    forKeyPath:@"accountStatus"
                                       options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                       context:nil];
    
    self.data = @[@[@(MeSchool)],
                  @[@(MeUser), @(MeFavourites), @(MeMoney)],
                  @[@(MeChoose)],
                  @[@(MeSettings)],
                  @[@(MeLogout)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    MainTabController *tabController = (MainTabController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [tabController showTabbarView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (object == [AccountManager shareManager]) {
        if ([keyPath isEqualToString:@"accountStatus"]) {
            [self.tableView reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.data[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell reuseIdentifier]
                                                            forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.textColor = THEME_TEXT_PRIMARY_COLOR;
    
    NSNumber *number = self.data[indexPath.section][indexPath.row];
    switch ([number integerValue]) {
        case MeSchool: {
            cell.textLabel.text = [NSUserDefaults schoolName];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
            
        case MeUser: {
            cell.imageView.image = [UIImage imageNamed:@"ic_me_favourite" bundleName:@"ModUserCenterStyle1"];
            cell.textLabel.text = [NSString stringWithFormat:@"用户名ID:%@", ACCOUNT_USERID];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
            
        case MeFavourites: {
            cell.imageView.image = [UIImage imageNamed:@"ic_me_favourite" bundleName:@"ModUserCenterStyle1"];
            cell.textLabel.text = [NSString stringWithFormat:@"用户名:%@", ACCOUNT_NAME];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
            
        case MeMoney: {
            cell.imageView.image = [UIImage imageNamed:@"ic_me_paybill" bundleName:@"ModUserCenterStyle1"];
            cell.textLabel.text = [NSString stringWithFormat:@"手机号:%@", ACCOUNT_PHONE];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
            
        case MeChoose: {
            cell.imageView.image = [UIImage imageNamed:@"ic_me_settings" bundleName:@"ModUserCenterStyle1"];
            cell.textLabel.text = @"选择学校入口";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
            
        case MeSettings: {
            cell.imageView.image = [UIImage imageNamed:@"ic_me_settings" bundleName:@"ModUserCenterStyle1"];
            cell.textLabel.text = @"跳转常规检查";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
            
        case MeLogout: {
            cell.imageView.image = [UIImage imageNamed:@"ic_me_settings" bundleName:@"ModUserCenterStyle1"];
            cell.textLabel.text = @"退出登录";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *reuseIdentifier = @"tableViewHeader";
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
    if (!view) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:reuseIdentifier];
    }
    
    view.contentView.backgroundColor = THEME_CONTENT_SEPARATOR_COLOR;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return .01;
    }
    
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSNumber *number = self.data[indexPath.section][indexPath.row];
    switch ([number integerValue]) {
        case MeFavourites: {
            
        }
            break;
            
        case MeChoose: {
            // 选择学校入口
            Class chooseClass = NSClassFromString(@"ChooseSchoolViewController");
            if (chooseClass) {
                BaseViewController *chooseVC = [[chooseClass alloc] initWithTitle:@"选择学校" rightItem:nil];
                [chooseVC setValue:@(YES) forKey:@"changeSchool"];
                [self presentViewController:chooseVC animated:NO completion:nil];
            }
            
        }
            break;
            
        case MeSettings: {
            // 常规检查入口
            ModCommonCheckStyle1ViewController *vc = [[ModCommonCheckStyle1ViewController alloc] initWithTitle:[NSUserDefaults schoolName] rightItem:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case MeLogout: {
            [YuAlertViewController showAlertWithTitle:@"提示"
                                              message:@"是否确认退出登录？"
                                       viewController:self
                                              okTitle:YUCLOUD_STRING_OK
                                             okAction:^(UIAlertAction * _Nonnull action) {
                                                // 退出登录
                                                [[AccountManager shareManager] logoutWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                                                    // 弹出登录界面
                                                    [[AccountManager shareManager] validateLoginWithCompletion:nil];
                                                }];
                                            }
                                          cancelTitle:YUCLOUD_STRING_CANCEL
                                         cancelAction:nil
                                           completion:nil];
            
        }
            break;
            
        default:
            break;
    }
    
    
}

@end
