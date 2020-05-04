//
//  LocationViewController.m
//  ViroyalFireWarning_iOS
//
//  Created by 唐琦 on 2019/6/12.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "LocationViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface LocationViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MAMapViewDelegate, AMapSearchDelegate>
@property (nonatomic, strong) UIImageView           *lineImageView;
@property (nonatomic, strong) UIView                *searchBarBgView;
@property (nonatomic, strong) UIButton              *searchBarMaskView;
@property (nonatomic, strong) UISearchBar           *searchBar;

@property (nonatomic, strong) MAMapView             *mapView;
@property (nonatomic, strong) UIImageView           *pinImageView;
@property (nonatomic, strong) UIButton              *locateButton;
@property (nonatomic, strong) UITableView           *tableView;

@property (nonatomic, strong) NSArray               *dataArray;
@property (nonatomic, strong) NSArray               *searchArray;
@property (nonatomic, strong) NSMutableArray        *selectedArray;

@property (nonatomic, strong) MBProgressHUD         *hud;
@property (nonatomic, strong) AMapSearchAPI         *searchAPI;

@property (nonatomic, assign) BOOL                  isLocated;
@property (nonatomic, assign) BOOL                  isZoom;
@property (nonatomic, assign) BOOL                  isSearching;

@property (nonatomic, strong) CLLocationManager     *locationManager;

@end

@implementation LocationViewController

- (void)loadView {
    [super loadView];
    
//    self.lineView.hidden = YES;

    UIButton *backButton = [self.topView viewWithTag:KTopViewBackButtonTag];
    [backButton setImage:nil forState:UIControlStateNormal];
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.backgroundColor = MainColor;
    rightButton.layer.cornerRadius = 3;
    rightButton.layer.masksToBounds = YES;
    [rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addRightButton:rightButton];
    [rightButton sizeToFit];
    
    [rightButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topView).offset(-15);
        make.top.equalTo(self.topView.mas_top).offset(KStatusBarHeight+(44-30)/2);
        make.width.equalTo(@(CGRectGetWidth(rightButton.frame)+10));
        make.height.equalTo(@30.f);
    }];
    
    self.searchBarBgView = [[UIView alloc] init];
    self.searchBarBgView.backgroundColor = MainColor;
    [self.view addSubview:self.searchBarBgView];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.backgroundImage = [UIImage imageWithColor:MainColor size:CGSizeMake(1, 1) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(0, 0)];
    self.searchBar.placeholder = @"搜索";
    [self.searchBarBgView addSubview:self.searchBar];
    
    self.mapView = [[MAMapView alloc] init];
    self.mapView.delegate = self;
    self.mapView.zoomLevel = 17;
    self.mapView.showsUserLocation = YES;
    self.mapView.showsCompass = NO;
    self.mapView.runLoopMode = NSDefaultRunLoopMode;
    [self.view addSubview:self.mapView];
    
    NSString *strResourcesBundle = [[NSBundle mainBundle] pathForResource:@"AMap" ofType:@"bundle"];
    NSString *imagePath = [[NSBundle bundleWithPath:strResourcesBundle] pathForResource:@"redPin" ofType:@"png" inDirectory:@"images"];
    UIImage *pinImage = [UIImage imageWithContentsOfFile:imagePath];
    
    self.pinImageView = [[UIImageView alloc] initWithImage:pinImage];
    [self.mapView addSubview:self.pinImageView];
    
    self.locateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.locateButton.backgroundColor = [UIColor whiteColor];
    self.locateButton.layer.cornerRadius = 25;
    self.locateButton.layer.borderWidth = 0.2;
    self.locateButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.locateButton setImage:[UIImage imageNamed:@"ic_map_locate"] forState:UIControlStateNormal];
    [self.locateButton addTarget:self action:@selector(locateButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.locateButton];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.allowsSelectionDuringEditing = YES;
    [self.view addSubview:self.tableView];
    
    self.lineImageView = [[UIImageView alloc] init];
    self.lineImageView.backgroundColor = [UIColor colorWithRGB:0xEEEEEE];
    [self.view addSubview:self.lineImageView];
    self.lineImageView.hidden = YES;
    
    self.searchBarMaskView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchBarMaskView.backgroundColor = [UIColor blackColor];
    self.searchBarMaskView.alpha = 0.0;
    [self.searchBarMaskView addTarget:self action:@selector(searchBarEndEditing) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.searchBarMaskView];
    
    [self.searchBarBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.safeArea);
        make.height.equalTo(@KTopViewHeight);
    }];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBarBgView).offset((KTopViewHeight-36)/2);
        make.left.right.equalTo(self.searchBarBgView);
        make.height.equalTo(@36);
    }];
    
    [self.lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(KTopViewHeight);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@0.5);
    }];
    
    [self.searchBarMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBarBgView.mas_bottom);
        make.left.right.bottom.equalTo(self.safeArea);
    }];
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBarBgView.mas_bottom);
        make.left.right.equalTo(self.safeArea);
        make.height.equalTo(@(SCREENHEIGHT*0.5));
    }];
    
    [self.pinImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.mapView);
    }];
    
    [self.locateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mapView).offset(-10);
        make.bottom.equalTo(self.mapView).offset(-15);
        make.width.height.equalTo(@50.f);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mapView.mas_bottom);
        make.left.bottom.right.equalTo(self.safeArea);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchAPI = [[AMapSearchAPI alloc] init];
    self.searchAPI.delegate = self;
    self.isLocated = NO;
    self.isZoom = NO;
    self.selectedArray = [NSMutableArray arrayWithCapacity:0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            [self.locationManager requestAlwaysAuthorization];
            [self.locationManager requestWhenInUseAuthorization];
            
            break;
        }
        case kCLAuthorizationStatusRestricted: {
            [YuAlertViewController showAlertWithTitle:@"您的手机不支持定位功能"
                                              message:nil
                                       viewController:self
                                              okTitle:@"确定"
                                             okAction:nil
                                          cancelTitle:@"取消"
                                         cancelAction:nil
                                           completion:nil];
            break;
        }
        case kCLAuthorizationStatusDenied: {
            if ([CLLocationManager locationServicesEnabled]) {
                [YuAlertViewController showAlertWithTitle:@"温馨提示"
                                                  message:@"我们检测到您的位置访问授权尚未开启，这将导致您后续无法使用位置搜索、导航等服务，您可以稍后前往系统（设置-御云-位置）自行开启"
                                           viewController:self
                                                  okTitle:@"好的"
                                                 okAction:^(UIAlertAction * _Nonnull action) {
                                                     [self closeView];
                                                 }
                                              cancelTitle:nil
                                             cancelAction:nil
                                               completion:nil];
            } else {
                [YuAlertViewController showAlertWithTitle:@"手机定位服务关闭,不可用(可前往设置-隐私,打开定位服务)"
                                                  message:nil
                                           viewController:self
                                                  okTitle:@"设置"
                                                 okAction:^(UIAlertAction * _Nonnull action) {
                                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                                                        options:@{}
                                                                              completionHandler:nil];
                                                     
                                                     [self closeView];
                                                 }
                                              cancelTitle:@"取消"
                                             cancelAction:nil
                                               completion:nil];
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            
            break;
            
        default:
            break;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.locationManager.delegate = nil;
    self.locationManager = nil;
}

- (void)rightButtonClick {
    if (self.block) {
        AMapPOI *poi = self.selectedArray.firstObject;
        CGPoint locationPoint = CGPointMake(poi.location.longitude, poi.location.latitude);
        
        self.block(poi.name, poi.address, NSStringFromCGPoint(locationPoint));
        
        [self closeView];
    }
}

- (void)closeView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)locateButtonClick {
    self.isSearching = NO;
    
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    [self pinImageViewAnimation];
    // 周边搜索
    [self aroundSearchWithLatitude:self.mapView.userLocation.coordinate.latitude
                         longitude:self.mapView.userLocation.coordinate.longitude];
}

#pragma mark - 周边搜索
- (void)aroundSearchWithLatitude:(double)latitude longitude:(double)longitude {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
    
    [self.searchAPI cancelAllRequests];
    [self.searchAPI AMapPOIAroundSearch:request];
}

- (void)pinImageViewAnimation {
    __block CGPoint point = self.pinImageView.center;
    __block CGPoint tempPoint = point;
    tempPoint.y -= 15;
    [UIView animateWithDuration:0.3 animations:^{
        [self.pinImageView setCenter:tempPoint];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.pinImageView.center = point;
        }];
    }];
}

#pragma mark - MapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    [self.hud hideAnimated:YES];
    
    if (!updatingLocation) {
        return ;
    }

    if (userLocation.location.horizontalAccuracy < 0) {
        return ;
    }

    // only the first locate used.
    if (!self.isLocated) {
        self.isLocated = YES;
        [self.mapView setCenterCoordinate:userLocation.coordinate];
        self.mapView.userTrackingMode = MAUserTrackingModeFollow;
        // 周边搜索
        [self aroundSearchWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
    }
}

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    [self.hud hideAnimated:YES];
    
    NSString *centerLatitude = [NSString stringWithFormat:@"%.3f", mapView.centerCoordinate.latitude];
    NSString *centerlongitude = [NSString stringWithFormat:@"%.3f", mapView.centerCoordinate.longitude];
    NSString *locationLatitude = [NSString stringWithFormat:@"%.3f", mapView.userLocation.coordinate.latitude];
    NSString *locationlongitude = [NSString stringWithFormat:@"%.3f", mapView.userLocation.coordinate.longitude];
    if ([centerLatitude isEqualToString:locationLatitude] &&
        [centerlongitude isEqualToString:locationlongitude]) {
        [self.locateButton setImage:[UIImage imageNamed:@"ic_map_locate"] forState:UIControlStateNormal];
    }
    else {
        [self.locateButton setImage:[UIImage imageNamed:@"ic_map_locate_none"] forState:UIControlStateNormal];
    }
    
    if (wasUserAction) {        
        // 周边搜索
        [self aroundSearchWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    }
}

- (void)mapViewRequireLocationAuth:(CLLocationManager *)locationManager {
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
}

#pragma mark - AMapSearchDelegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    [self.hud hideAnimated:YES];

    if (self.isSearching) {
        self.searchArray = response.pois;
        [self.tableView reloadData];
    }
    else {
        self.dataArray = response.pois;
        [self.tableView reloadData];
        
        if (response.pois.count) {
            [self.selectedArray removeAllObjects];
            [self.selectedArray addObject:response.pois.firstObject];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom
                                              animated:YES];
            });
        }
    }
}


#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return self.searchArray.count;
    }
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSearching) {
        static NSString *searchCellReuseID = @"LocationSearchCellReuseIdentifier";

        UITableViewCell *searchCell = [tableView dequeueReusableCellWithIdentifier:searchCellReuseID];
        if (nil == searchCell) {
            searchCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:searchCellReuseID];
        }
        
        if (indexPath.row < self.searchArray.count) {
            AMapPOI *poi = self.searchArray[indexPath.row];
            searchCell.textLabel.font = [UIFont systemFontOfSize:16];
            searchCell.textLabel.text = poi.name;
            
            searchCell.detailTextLabel.textColor = [UIColor lightGrayColor];
            searchCell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@%@%@", poi.province, poi.city, poi.district, poi.address];
        }
        
        return searchCell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];

        if (nil == cell) {
            if (indexPath.row == 0) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(UITableViewCell.class)];
            }
            else {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass(UITableViewCell.class)];
            }
        }
        
        if (indexPath.row < self.dataArray.count) {
            AMapPOI *poi = self.dataArray[indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.text = poi.name;
            
            if (indexPath.row != 0) {
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@%@%@", poi.province, poi.city, poi.district, poi.address];
            }
            
            BOOL isSelected = NO;
            for (AMapPOI *selectPoi in self.selectedArray) {
                if (selectPoi.uid == poi.uid) {
                    isSelected = YES;
                    break;
                }
            }
            if (isSelected) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        return cell;
    }
    
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSearching) {
        if (indexPath.row < self.searchArray.count) {
            AMapPOI *poi = self.searchArray[indexPath.row];
            
            [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude)];
            [self searchBarCancelButtonClicked:self.searchBar];
            // 周边搜索
            [self aroundSearchWithLatitude:poi.location.latitude longitude:poi.location.longitude];
        }
    }
    else {
        if (indexPath.row < self.dataArray.count) {
            AMapPOI *poi = self.dataArray[indexPath.row];

            if (self.selectedArray.count) {
                [self.selectedArray removeAllObjects];
            }
            
            [self.selectedArray addObject:poi];
            
            [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude)
                                     animated:YES];
            
            [self.tableView reloadData];
        }
    }
}

#pragma mark - UIScrollDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isSearching && scrollView == self.tableView) {
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY > 20 && !self.isZoom) {
            self.isZoom = YES;
            
            [UIView animateWithDuration:0.3 animations:^{
                [self.mapView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@(SCREENHEIGHT*0.2));
                }];
                
                [self.view layoutIfNeeded];
            }];
            
        }
        else if (offsetY < -20 && self.isZoom) {
            self.isZoom = NO;
            [UIView animateWithDuration:0.3 animations:^{
                [self.mapView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@(SCREENHEIGHT*0.5));
                }];
                
                [self.view layoutIfNeeded];
            }];
        }
    }
}

#pragma mark - ButtonClick
- (void)searchBarEndEditing {
    [self stopSearch];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mapView.mas_bottom);
        make.left.bottom.right.equalTo(self.safeArea);
    }];
}

- (void)startSearch {
    self.isSearching = YES;
    self.tableView.tableHeaderView = nil;
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self hideNavigationBarAnimate];
    
    if (self.searchBar.text.length) {
        self.searchBarMaskView.alpha = 0.0;
    }else {
        self.searchBarMaskView.alpha = 0.2;
    }
    
    [self.tableView reloadData];
}

- (void)stopSearch {
    self.isSearching = NO;
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self showNavigationBarAnimate];
    self.searchBarMaskView.alpha = 0.0;
    self.searchArray = nil;
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
        self.lineImageView.hidden = NO;
        self.isSearching = YES;
        
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBarBgView.mas_bottom);
            make.left.bottom.right.equalTo(self.safeArea);
        }];
        
        // 先取消之前未完成的查询
        [self.hud hideAnimated:YES];
        [self.searchAPI cancelAllRequests];
        // 关键字查询
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
        request.keywords = searchBar.text;
        [self.searchAPI AMapPOIKeywordsSearch:request];
    }else {
        [self stopSearch];
        
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mapView.mas_bottom);
            make.left.bottom.right.equalTo(self.safeArea);
        }];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (!searchBar.text.length) {
        self.lineImageView.hidden = YES;
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
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mapView.mas_bottom);
        make.left.bottom.right.equalTo(self.safeArea);
    }];
}

#pragma mark - 动画
- (void)showNavigationBarAnimate {
    [UIView animateWithDuration:0.3 animations:^{
        //修改搜索框背景View高度
        self.searchBarBgView.frame = CGRectMake(0, KTopViewHeight, SCREENWIDTH, KTopViewHeight);
        //修改搜索框位置
        [self.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBarBgView).offset((KTopViewHeight-36)/2);
        }];
        //显示导航栏
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.superview);
        }];
        
        [self.topView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideNavigationBarAnimate {
    [UIView animateWithDuration:0.3 animations:^{
        //修改搜索框背景View高度
        self.searchBarBgView.frame = CGRectMake(0, 0, SCREENWIDTH, KTopViewHeight);
        //修改搜索框位置
        [self.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBarBgView).offset(KStatusBarHeight);
        }];
        //隐藏导航栏
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.superview).offset(-KTopViewHeight);
        }];
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - CLLocationManagerDelegate
/** 定位服务状态改变时调用*/
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied: {
            [YuAlertViewController showAlertWithTitle:@"温馨提示"
                                              message:@"我们检测到您的位置访问授权尚未开启，这将导致您后续无法使用位置搜索、导航等服务，您可以稍后前往系统（设置-隐私）自行开启，或者即刻跳转到隐私页面开启"
                                       viewController:self
                                              okTitle:@"设置"
                                             okAction:^(UIAlertAction * _Nonnull action) {
                                                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                                                    options:@{}
                                                                          completionHandler:nil];
                                                 
                                                 [self closeView];
                                             }
                                          cancelTitle:@"取消"
                                         cancelAction:^(UIAlertAction * _Nonnull action) {
                                             [self closeView];
                                         }
                                           completion:nil];
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            [self locateButtonClick];
        }
            break;
            
        default:
            break;
    }
}

@end
