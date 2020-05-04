//
//  WeatherOptionsViewController.m
//  Unilife
//
//  Created by 唐琦 on 2019/7/2.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "WeatherOptionsViewController.h"
#import <ModWeatherBase/WeatherManager.h>
#import <LibTheme/ThemeManager.h>
#import <LibCoredata/CacheDataSource.h>

@interface WeatherCityResultsController : UIViewController < UITableViewDataSource, UITableViewDelegate >

@property (nonatomic, copy) NSArray<CityData *> *cities;
@property (nonatomic, copy) NSString            *searchText;

@property (nonatomic, strong) UITableView       *tableView;

@end

@implementation WeatherCityResultsController

- (void)loadView {
    UIView *view = [UIView new];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [tableView registerClass:[UITableViewCell class]
      forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    
    tableView.separatorColor = [UIColor colorWithRGB:0xAEAEAE];
    
    [view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.right.equalTo(view);
        make.top.equalTo(view).offset(64);
        make.bottom.equalTo(view);
    }];
    
    self.tableView = tableView;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
}

- (void)setSearchText:(NSString *)searchText {
    _searchText = searchText.copy;
    
    self.cities = [[WeatherManager shareManager] citiesWithName:searchText
                                                       selected:-1].mutableCopy;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cities.count > 0?1:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    CityData *data = self.cities[indexPath.row];
    
    NSString *result = data.district;
    if (![result isEqualToString:data.city]) {
        result = [NSString stringWithFormat:@"%@ - %@", data.city, result];
    }
    
    if (![data.city isEqualToString:data.province]) {
        result = [NSString stringWithFormat:@"%@ - %@", data.province, result];
    }
    
    cell.textLabel.text = result;
    cell.textLabel.textColor = THEME_TEXT_PRIMARY_COLOR;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CityData *city = self.cities[indexPath.row];
    dispatch_block_t addCity = ^() {
        NSArray *resultArray = [[WeatherManager shareManager] allCitiesWithSelected:YES];
        NSInteger index = -1;
        for (CityData *item in resultArray) {
            index = MAX(item.selectedIndex, index);
        }
        
        city.selectedIndex = index + 1;
        [[WeatherManager shareManager] addCity:city completion:^(BOOL success, NSDictionary * _Nullable info) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showFinishHudOn:[UIApplication sharedApplication].keyWindow
                                        withResult:YES
                                         labelText:@"添加成功"
                                         delayHide:YES
                                        completion:^{
                                            [self setSearchText:self.searchText];
                                        }];
                });
            }
        }];
    };
    
    if (!city.weather) {
        [[WeatherManager shareManager] requestWeatherWithCity:city completion:^(BOOL success, NSDictionary * _Nullable info) {
            if (success) {
                addCity();
            }
            else {
                [MBProgressHUD showFinishHudOn:[UIApplication sharedApplication].keyWindow
                                    withResult:NO
                                     labelText:nil
                                     delayHide:YES
                                    completion:^{
                                        [[CacheDataSource sharedClient] deleteObject:city];
                                    }];
            }
        }];
    }
    else {
        addCity();
    }
}

@end

@interface WeatherOptionsViewController () < UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate >

@property (nonatomic, strong) UITableView                       *tableView;
@property (nonatomic, strong) UISearchController                *searchController;
@property (nonatomic, strong) WeatherCityResultsController      *resultsController;
@property (nonatomic, strong) NSArray                           *dataArray;

@end

@implementation WeatherOptionsViewController

- (void)loadView {
    UIView *view = [UIView new];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [tableView registerClass:[UITableViewCell class]
      forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    
    tableView.separatorColor = [UIColor colorWithRGB:0xAEAEAE];
    
    [view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.right.equalTo(view);
        make.top.equalTo(view).offset(64);
        make.bottom.equalTo(view);
    }];
    
    self.tableView = tableView;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"城市管理";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:YUCLOUD_STRING_EDIT
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(touchCityEdit)];
    
    self.resultsController = [[WeatherCityResultsController alloc] init];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    [self.searchController.searchBar sizeToFit];
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.searchBar.delegate = self;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.tableFooterView = [UIView new];
    
    self.definesPresentationContext = YES;
}

- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeTop;
}

- (void)touchCityEdit {
    [self.tableView setEditing:YES animated:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:YUCLOUD_STRING_DONE
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(touchEditDone)];
}

- (void)touchEditDone {
    [self.tableView setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:YUCLOUD_STRING_EDIT
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(touchCityEdit)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    CityData *data = self.dataArray[indexPath.row];
    cell.textLabel.text = data.district;
    cell.textLabel.textColor = THEME_TEXT_PRIMARY_COLOR;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CityData *data = self.dataArray[indexPath.row];
    [self.delegate weatherSelectCity:data];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CityData *city = self.dataArray[indexPath.row];
        city.selectedIndex = -1;
        [[WeatherManager shareManager] addCity:city completion:^(BOOL success, NSDictionary * _Nullable info) {
            if (success) {
//                DDLog(@"更新城市信息成功");
                [self.delegate weatherSelectCity:nil];
            }
            else {
//                DDLog(@"更新城市信息失败");
            }
        }];
    }
}

#pragma mark - UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    self.resultsController.searchText = searchController.searchBar.text;
}

@end
