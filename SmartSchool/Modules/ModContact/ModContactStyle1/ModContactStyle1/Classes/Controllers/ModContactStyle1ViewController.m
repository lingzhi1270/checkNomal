//
//  ModContactStyle1ViewController.m
//  Unilife
//
//  Created by 唐琦 on 2018/3/15.
//  Copyright © 2018年 南京远御网络科技有限公司. All rights reserved.
//

#import "ModContactStyle1ViewController.h"
#import <ModContactBase/ContactManager.h>
#import "ContactCell.h"
#import "ContactInfoViewController.h"
#import <GFPopover/PopoverView.h>
#import <ModLoginBase/AccountManager.h>

@interface ModContactStyle1ViewController () < UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, PopoverDatasource, PopoverDelegate >
@property (nonatomic, copy)   NSString          *category;
@property (nonatomic, assign) BOOL                  grouped;

@property (nonatomic, strong) UITableView           *tableView;
@property (nonatomic, strong) NSArray               *listArray;
@property (nonatomic, strong) NSArray               *searchResultArray;

@property (nonatomic, strong) UIView                *searchBarBgView;
@property (nonatomic, strong) UIButton              *searchBarMaskView;
@property (nonatomic, strong) UISearchBar           *searchBar;
@property (nonatomic, assign) BOOL                  isSearching;

@end

@implementation ModContactStyle1ViewController

- (instancetype)initWithCategory:(NSString *)category grouped:(BOOL)grouped {
    if (self = [super initWithTitle:NSLocalizedString(@"Contacts", nil) rightItem:nil]) {
        self.category = category;
        self.grouped = grouped;
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    UIButton *backButton = [self.topView viewWithTag:KTopViewBackButtonTag];
    backButton.hidden = YES;
    
    self.searchBarBgView = [[UIView alloc] init];
    self.searchBarBgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.searchBarBgView];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.backgroundColor = [UIColor whiteColor];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.placeholder = @"搜索";
    [self.searchBarBgView addSubview:self.searchBar];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[ContactCell class] forCellReuseIdentifier:[ContactCell reuseIdentifier]];
    [self.view addSubview:self.tableView];
    
    self.searchBarMaskView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchBarMaskView.backgroundColor = [UIColor blackColor];
    self.searchBarMaskView.alpha = 0.0;
    [self.searchBarMaskView addTarget:self action:@selector(searchBarEndEditing) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.searchBarMaskView];
    
    [self.searchBarBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.right.equalTo(self.safeArea);
        make.height.equalTo(@60);
    }];
    
    [self.searchBarMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBarBgView.mas_bottom);
        make.left.right.bottom.equalTo(self.safeArea);
    }];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.searchBarBgView);
        make.centerY.equalTo(self.searchBarBgView);
        make.height.equalTo(@36);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBarBgView.mas_bottom);
        make.left.right.equalTo(self.safeArea);
        make.bottom.equalTo(self.safeArea).offset(-KBottomSafeHeight);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isSearching = NO;
    
    if (self.category.length) {
        [self updateNaviBarWithTitle:self.category];
    }
    
    if (self.delegate) {
        UIButton *rightButton = [UIButton new];
        [rightButton setTitle:YUCLOUD_STRING_CANCEL forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(selectContactCancel) forControlEvents:UIControlEventTouchUpInside];
        [self addRightButton:rightButton];
    }
    
    [[AccountManager shareManager] addObserver:self
                                    forKeyPath:@"accountStatus"
                                       options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                       context:nil];
    
    [[ContactManager shareManager] addObserver:self
                                    forKeyPath:@"statusMenu"
                                       options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                       context:nil];
    
    [[ContactManager shareManager] addObserver:self
                                    forKeyPath:@"myStatus"
                                       options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                       context:nil];
    
    [self updateMyStatus];
    
//    self.listArray = [[ContactManager shareManager] allSortOnlineContacts];
    [self.tableView reloadData];
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

- (void)selectContactCancel {
    [self.delegate contactSelectCanceled];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"accountStatus"]) {
        [self.tableView reloadData];
    }
    else if ([keyPath isEqualToString:@"statusMenu"] || [keyPath isEqualToString:@"myStatus"]) {
        [self updateMyStatus];
    }
}

- (void)updateMyStatus {
    NSArray *menu = [ContactManager shareManager].statusMenu;
    if (menu.count) {
        ContactStatusData *data = [[ContactManager shareManager] statusWithUid:[ContactManager shareManager].myStatus];
        NSString *title = [@" " stringByAppendingString:data?data.title:@"状态"];
        
        UIButton *rightButton = [UIButton new];
        rightButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [rightButton setTitle:title forState:UIControlStateNormal];
        [rightButton setImage:[UIImage imageNamed:@"ic_contacts_dropdown"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(touchMenuButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addRightButton:rightButton];
    }
    else {
        UIButton *backButton = [self.topView viewWithTag:KTopViewRightButtonTag];
        backButton.hidden = YES;
    }
}

- (void)touchMenuButton:(UIButton *)btn {
    PopoverView *popoverView = [PopoverView popoverView];
    popoverView.showShade = YES;
    popoverView.dataSource = self;
    popoverView.delegate = self;
    [popoverView showToView:btn];
}

- (void)touchMenuItem:(UIBarButtonItem *)item {
    PopoverView *popoverView = [PopoverView popoverView];
    popoverView.showShade = YES;
    popoverView.dataSource = self;
    popoverView.delegate = self;
    
    UIView *view = [item valueForKey:@"view"];
    [popoverView showToView:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSearching) {
        return self.searchResultArray.count;
    }
    else {
        return self.listArray.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        NSDictionary *dict = self.searchResultArray[section];
        return [dict[kContactListKey] count];
    }
    else {
        NSDictionary *dict = self.listArray[section];
        return [dict[kContactListKey] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[ContactCell reuseIdentifier]
                                           forIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.grouped) {
        NSString *sectionName = nil;
        ContactData *contact = nil;
        if (self.isSearching) {
            NSDictionary *dict = self.searchResultArray[section];
            sectionName = dict[kContactSectionKey];
            contact = [dict[kContactListKey] firstObject];
        }
        else {
            NSDictionary *dict = self.listArray[section];
            sectionName = dict[kContactSectionKey];
            contact = [dict[kContactListKey] firstObject];
        }
        
        if (contact.section == 1) {
            return @"★";
        }
        else if (contact.section == 3) {
            return @"科室";
        }
        else {
            return sectionName;
        }
    }
    
    return nil;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.grouped) {
        NSMutableArray *arr = [NSMutableArray new];
        NSInteger count = 0;
        if (self.isSearching) {
            count = self.searchResultArray.count;
        }
        else {
            count = self.listArray.count;
        }
        
        for (int section = 0; section < count; section++) {
            NSString *string = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
            if (string.length > 0) {
                string = [string substringWithRange:NSMakeRange(0, 1)];
                [arr addObject:string];
            }
        }
        
        return arr.copy;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(ContactCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactData *contact = nil;
    if (self.isSearching) {
        NSDictionary *dict = self.searchResultArray[indexPath.section];
        NSArray *array = dict[kContactListKey];
        contact = array[indexPath.row];
    }
    else {
        NSDictionary *dict = self.listArray[indexPath.section];
        NSArray *array = dict[kContactListKey];
        contact = array[indexPath.row];
    }
    
    cell.contact = contact;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ContactData *contact = nil;
    if (self.isSearching) {
        NSDictionary *dict = self.searchResultArray[indexPath.section];
        NSArray *array = dict[kContactListKey];
        contact = array[indexPath.row];
    }
    else {
        NSDictionary *dict = self.listArray[indexPath.section];
        NSArray *array = dict[kContactListKey];
        contact = array[indexPath.row];
    }
    
    if (contact.section == 3) {
        ModContactStyle1ViewController *vc = [[ModContactStyle1ViewController alloc] initWithCategory:contact.title grouped:NO];
        vc.delegate = self.delegate;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (self.delegate) {
        [self.delegate contactSelected:contact];
    }
    else {
        ContactInfoViewController *vc = [[ContactInfoViewController alloc] initWithContact:contact];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - PopoverDatasource, PopoverDelegate
- (NSInteger)numberOfRowsInMenu:(PopoverView *)view {
    return [ContactManager shareManager].statusMenu.count;
}

- (PopoverAction *)actionForRow:(NSInteger)row {
    ContactStatusData *data = [ContactManager shareManager].statusMenu[row];
    return [PopoverAction actionWithImage:nil title:data.title handler:nil];
}

- (void)popover:(PopoverView *)view didSelectRow:(NSInteger)row {
    ContactStatusData *data = [ContactManager shareManager].statusMenu[row];
    MBProgressHUD *hud = [MBProgressHUD showHudOn:[UIApplication sharedApplication].keyWindow
                                             mode:MBProgressHUDModeIndeterminate
                                            image:nil
                                          message:YUCLOUD_STRING_PLEASE_WAIT
                                        delayHide:NO
                                       completion:nil];
    
    [[ContactManager shareManager] requestMyStatusWithAction:YuCloudDataEdit
                                                      status:data.uid
                                                  completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                      [MBProgressHUD finishHudWithResult:success
                                                                                     hud:hud
                                                                               labelText:[info errorMsg:success]
                                                                              completion:nil];
                                                  }];
    
}

#pragma mark - ButtonClick
- (void)searchBarEndEditing {
    [self.searchBar resignFirstResponder];
}

- (void)startSearch {
    self.isSearching = YES;
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self hideNavigationBarAnimate];
    
    if (self.searchBar.text.length) {
        self.searchBarMaskView.alpha = 0.0;
    }else {
        self.searchBarMaskView.alpha = 0.2;
    }
}

- (void)stopSearch {
    self.isSearching = NO;
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self showNavigationBarAnimate];
    self.searchBarMaskView.alpha = 0.0;
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self startSearch];
    
    // 修改取消按钮字色
    UIButton *cancleBtn = [self.searchBar valueForKey:@"cancelButton"];
    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //隐藏maskView
    self.searchBarMaskView.alpha = 0.0;
    
    if (searchBar.text.length) {
        self.isSearching = YES;
        
        self.searchResultArray = [[ContactManager shareManager] onlineContactsWithSearchText:searchText];
        [self.tableView reloadData];
    }else {
        [self stopSearch];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (!searchBar.text.length) {
        [self stopSearch];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // 隐藏遮盖层
    [UIView animateWithDuration:0.2 animations:^{
        self.searchBarMaskView.alpha = 0.0;
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    
    [self stopSearch];
}

#pragma mark - 动画
- (void)showNavigationBarAnimate {
    [UIView animateWithDuration:0.3 animations:^{
        //修改搜索框背景View的背景色
        self.searchBarBgView.backgroundColor = [UIColor whiteColor];
        //修改搜索框背景色
        self.searchBar.backgroundColor = [UIColor whiteColor];
        //搜索框字体颜色
        UITextField *textField = [self.searchBar valueForKey:@"searchField"];
        textField.textColor = [UIColor blackColor];
        //提示语字体颜色
        UILabel *placeholderLabel = [textField valueForKey:@"placeholderLabel"];
        placeholderLabel.textColor = [UIColor colorWithRGB:0x8E8E8E];
        //修改搜索框背景View高度
        [self.searchBarBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@60);
        }];
        //修改搜索框位置
        [self.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.searchBarBgView);
        }];
        //显示导航栏
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.superview);
        }];
        
        [self.topView.superview layoutIfNeeded];
    }];
}

- (void)hideNavigationBarAnimate {
    [UIView animateWithDuration:0.3 animations:^{
        //修改搜索框背景View的背景色
        self.searchBarBgView.backgroundColor = MAIN_COLOR;
        //修改搜索框背景色
        self.searchBar.backgroundColor = MAIN_COLOR;
        //搜索框字体颜色
        UITextField *textField = [self.searchBar valueForKey:@"searchField"];
        textField.textColor = [UIColor whiteColor];
        //提示语字体颜色
        UILabel *placeholderLabel = [textField valueForKey:@"placeholderLabel"];
        placeholderLabel.textColor = [UIColor lightTextColor];
        //修改搜索框背景View高度
        [self.searchBarBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(KTopViewHeight));
        }];
        //修改搜索框位置
        [self.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.searchBarBgView).offset(10);
        }];
        //隐藏导航栏
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.superview).offset(-KTopViewHeight);
        }];
        
        [self.topView.superview layoutIfNeeded];
    }];
}

@end
