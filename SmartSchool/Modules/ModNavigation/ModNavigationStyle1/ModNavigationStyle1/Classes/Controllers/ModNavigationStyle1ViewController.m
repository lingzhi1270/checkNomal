//
//  ModNavigationStyle1ViewController.m
//  Module_demo
//
//  Created by 唐琦 on 2019/9/3.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "ModNavigationStyle1ViewController.h"
#import "NavigationManager.h"
#import "NaviModel.h"
#import "RouteTypeSegmentView.h"
#import "RouteSelectorView.h"

@interface ModNavigationStyle1ViewController () <MAMapViewDelegate, NavigationManagerDelegate, RouteTypeSegmentViewDelegate, RouteSelectorViewDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) RouteTypeSegmentView *segmentView;
@property (nonatomic, strong) RouteSelectorView *routeSelectorView;

@property (nonatomic, strong) NSDictionary *naviRoutes;
@property (nonatomic, strong) NSMutableArray *routeArray;
@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;
@property (nonatomic, assign) NSInteger currentRouteID;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ModNavigationStyle1ViewController

- (void)loadView {
    [super loadView];
    
    self.segmentView = [[RouteTypeSegmentView alloc] init];
    self.segmentView.delegate = self;
    [self.view addSubview:self.segmentView];
    
    self.mapView = [[MAMapView alloc] init];
    self.mapView.tag = 10010;
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.showsUserLocation = YES;
    self.mapView.showTraffic = YES;
    self.mapView.allowsBackgroundLocationUpdates = YES;
    self.mapView.zoomLevel = 14;
    [self.view insertSubview:self.mapView belowSubview:self.topView];
    
    self.routeSelectorView = [[RouteSelectorView alloc] init];
    self.routeSelectorView.delegate = self;
    self.routeSelectorView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.routeSelectorView];
    
    [self.segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.safeArea);
        make.height.equalTo(@(kRouteTypeSegmentViewHeight));
    }];
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.routeSelectorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.safeArea);
        make.bottom.equalTo(self.safeArea).offset(kRouteSelectorViewHeight);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [NavigationManager shareManager].delegate = self;
    self.currentRouteID = -1;
    self.routeArray = [NSMutableArray arrayWithCapacity:0];
}

- (void)startNaviRoutePlanWithStartPoint:(NSString *)startPointString
                                endPoint:(NSString *)endPointString {
    CGPoint endPoint = CGPointFromString(endPointString);
    self.endPoint = [AMapNaviPoint locationWithLatitude:endPoint.y longitude:endPoint.x];
    
    self.hud = [MBProgressHUD showHudOn:self.view
                                   mode:MBProgressHUDModeIndeterminate
                                  image:nil
                                message:@"规划路线中..."
                              delayHide:NO
                             completion:nil];
    
    if (startPointString.length) {
        CGPoint startPoint = CGPointFromString(startPointString);
        self.startPoint = [AMapNaviPoint locationWithLatitude:startPoint.y longitude:startPoint.x];
        
        [[NavigationManager shareManager] startRoutePlanWithStartPoint:self.startPoint
                                                              endPoint:self.endPoint];
    }
    else {
        [[NavigationManager shareManager] startRoutePlanWithEndPoint:self.endPoint];
    }
    
    
}

#pragma mark - 操作地图
// 清空地图覆盖物
- (void)clearMapView {
    self.currentRouteID = -1;
    self.naviRoutes = nil;
    [self.routeArray removeAllObjects];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    self.routeSelectorView.data = self.routeArray;
    [UIView animateWithDuration:0.3 animations:^{
        [self.routeSelectorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.safeArea).offset(kRouteSelectorViewHeight);
        }];
        
        [self.view layoutIfNeeded];
    }];
}

// 增加地图覆盖物
- (void)editMapView{
    [self initAnnotations];
    [self showNaviRoutes];
}

#pragma mark - 绘制起点和终点
- (void)initAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];

    MAPointAnnotation *beginAnnotation = [[MAPointAnnotation alloc] init];
    if (self.startPoint) {
        [beginAnnotation setCoordinate:CLLocationCoordinate2DMake(self.startPoint.latitude, self.startPoint.longitude)];
    }
    else {
        [beginAnnotation setCoordinate:self.mapView.userLocation.coordinate];
    }
    beginAnnotation.title = @"起始点";

    MAPointAnnotation *endAnnotation = [[MAPointAnnotation alloc] init];
    [endAnnotation setCoordinate:CLLocationCoordinate2DMake(self.endPoint.latitude, self.endPoint.longitude)];
    endAnnotation.title = @"终点";
    
    [self.mapView addAnnotation:beginAnnotation];
    [self.mapView addAnnotation:endAnnotation];
}

#pragma mark - 绘制路线并默认选中第一条路线
- (void)showNaviRoutes {
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.routeArray removeAllObjects];
    
    if (self.naviRoutes.allKeys.count) {
        self.currentRouteID = [self.naviRoutes.allKeys.firstObject integerValue];
    }
    
    for (NSNumber *aRouteID in self.naviRoutes.allKeys) {
        AMapNaviRoute *aRoute = [self.naviRoutes objectForKey:aRouteID];
        RouteInfo *info = [RouteInfo routeWithNaviRoute:aRoute];
        info.naviType = [NavigationManager shareManager].naviType;
        info.routeID = aRouteID.integerValue;
        
        CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(aRoute.routeCoordinates.count * sizeof(CLLocationCoordinate2D));

        for (AMapNaviPoint *naviPoint in aRoute.routeCoordinates) {
            NSInteger index = [aRoute.routeCoordinates indexOfObject:naviPoint];
            
            coords[index].latitude = naviPoint.latitude;
            coords[index].longitude = naviPoint.longitude;
        }
        
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coords
                                                             count:aRoute.routeCoordinates.count];
        NaviOverlay *overlay = [[NaviOverlay alloc] initWithOverlay:polyline];
        overlay.routeID = aRouteID.integerValue;
        if (self.currentRouteID == aRouteID.integerValue) {
            info.selected = YES;
            overlay.selected = YES;
        }
        else {
            info.selected = NO;
            overlay.selected = NO;
        }
        //在地图上添加折线对象
        [self.mapView addOverlay:overlay];
        [self.routeArray addObject:info];
        
        free(coords);
    }
    
    self.routeSelectorView.data = self.routeArray;
    [self.mapView showOverlays:self.mapView.overlays
                   edgePadding:UIEdgeInsetsMake(50+KTopViewHeight+kRouteTypeSegmentViewHeight, 40, 50+kRouteSelectorViewHeight, 40)
                      animated:YES];
    [self changeOverlayLevel];
}

// 将选中的路线显示在最上层
- (void)changeOverlayLevel {
    [self.mapView.overlays enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id<MAOverlay> overlay, NSUInteger idx, BOOL *stop) {
        if ([overlay isKindOfClass:[NaviOverlay class]]) {
            NaviOverlay *currentOverlay = overlay;
            /* 获取overlay对应的renderer. */
            MAPolylineRenderer *overlayRenderer = (MAPolylineRenderer *)[self.mapView rendererForOverlay:currentOverlay];
            
            NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"AMapNavi" ofType:@"bundle"]];
            UIImage *selectedImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"custtexture_green"
                                                                                       ofType:@"png"
                                                                                  inDirectory:@"nibs"]];
            UIImage *unSelectedimage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"custtexture_green_unselected"
                                                                                         ofType:@"png"
                                                                                    inDirectory:@"nibs"]];
            
            if ([NavigationManager shareManager].naviType != NavigationTypeDrive) {
                selectedImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"custtexture_no"
                                                                                  ofType:@"png"
                                                                             inDirectory:@"nibs"]];
                unSelectedimage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"custtexture_no_unselected"
                                                                                    ofType:@"png"
                                                                               inDirectory:@"nibs"]];
            }
            
            if (currentOverlay.routeID == self.currentRouteID) {
                currentOverlay.selected = YES;
                overlayRenderer.strokeImage = selectedImage;
                /* 修改overlay覆盖的顺序. */
                [self.mapView exchangeOverlayAtIndex:idx withOverlayAtIndex:self.mapView.overlays.count - 1];
            }
            else {
                currentOverlay.selected = NO;
                overlayRenderer.strokeImage = unSelectedimage;
            }
        }
    }];
}

#pragma mark - RouteTypeSegmentViewDelegate
- (void)didSelectedTypeWithIndex:(NSInteger)index {
    if ([NavigationManager shareManager].naviType == index) {
        return;
    }
    
    [NavigationManager shareManager].naviType = index;
    // 清除旧数据
    [self clearMapView];
    // 请求对应类型的路径规划
    self.hud = [MBProgressHUD showHudOn:self.view
                                   mode:MBProgressHUDModeIndeterminate
                                  image:nil
                                message:@"规划路线中..."
                              delayHide:NO
                             completion:nil];
    
    if (self.startPoint) {
        [[NavigationManager shareManager] startRoutePlanWithStartPoint:self.startPoint
                                                              endPoint:self.endPoint];
    }
    else {
        [[NavigationManager shareManager] startRoutePlanWithEndPoint:self.endPoint];
    }
}

#pragma mark - RouteSelectorViewDelegate
- (void)didSelectedRouteWithRouteID:(NSInteger)routeID {
    self.currentRouteID = routeID;
    [self changeOverlayLevel];
    [[NavigationManager shareManager] selectNaviRouteWithRouteID:routeID];
    
    NaviOverlay *currentOverlay = nil;
    for (NaviOverlay *overlay in self.mapView.overlays) {
        if (overlay.routeID == routeID) {
            currentOverlay = overlay;
            break;
        }
    }
    
    if (currentOverlay) {
        [self.mapView showOverlays:@[currentOverlay]
                       edgePadding:UIEdgeInsetsMake(50+KTopViewHeight+kRouteTypeSegmentViewHeight, 40, 50+kRouteSelectorViewHeight, 40)
                          animated:YES];
    }
}

- (void)didSelectNavigation {
    [UIView animateWithDuration:0.3 animations:^{
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(-(KTopViewHeight+kRouteTypeSegmentViewHeight));
        }];
        
        [self.routeSelectorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(kRouteSelectorViewHeight);
        }];
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [[NavigationManager shareManager] startEmulatorNaviWithViewController:self];
    }];
    
    
    [self clearMapView];
}

#pragma mark - MAMapViewDelegate
- (void)mapViewRequireLocationAuth:(CLLocationManager *)locationManager {
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        return nil;
        
    }
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *annotationIdentifier = @"NaviPointAnnotationIdentifier";
        
        MAPinAnnotationView *pointAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (pointAnnotationView == nil) {
            pointAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        }
        
        pointAnnotationView.animatesDrop   = NO;
        pointAnnotationView.canShowCallout = YES;
        pointAnnotationView.draggable      = NO;
        
        if ([annotation.title isEqualToString:@"起始点"]) {
            pointAnnotationView.image = [UIImage imageNamed:@"ic_route_start"];
        }
        else if ([annotation.title isEqualToString:@"终点"]) {
            pointAnnotationView.image = [UIImage imageNamed:@"ic_route_end"];
        }
        
        return pointAnnotationView;
    }
    
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay {
    if ([overlay isKindOfClass:[NaviOverlay class]]) {
        NaviOverlay * selectableOverlay = (NaviOverlay *)overlay;
        id<MAOverlay> actualOverlay = selectableOverlay.overlay;

        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"AMapNavi" ofType:@"bundle"]];
        UIImage *selectedImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"custtexture_green"
                                                                                   ofType:@"png"
                                                                              inDirectory:@"nibs"]];
        UIImage *unSelectedimage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"custtexture_green_unselected"
                                                                                     ofType:@"png"
                                                                                inDirectory:@"nibs"]];
        
        if ([NavigationManager shareManager].naviType != NavigationTypeDrive) {
            selectedImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"custtexture_no"
                                                                              ofType:@"png"
                                                                         inDirectory:@"nibs"]];
            unSelectedimage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"custtexture_no_unselected"
                                                                                ofType:@"png"
                                                                           inDirectory:@"nibs"]];
        }
        
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:actualOverlay];
        polylineRenderer.lineWidth = 30;
        polylineRenderer.lineJoinType = kMALineJoinRound;
        polylineRenderer.lineCapType = kMALineCapRound;
        polylineRenderer.strokeImage = selectableOverlay.isSelected ? selectedImage : unSelectedimage;
        
        return polylineRenderer;
    }
    
    return nil;
}

#pragma mark - NavigationManagerDelegate
// 路线规划成功
- (void)calculateRouteSuccess:(AMapNaviBaseManager *)naviManager {
    [self.hud hideAnimated:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.routeSelectorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.safeArea);
        }];
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if ([naviManager isKindOfClass:[AMapNaviDriveManager class]]) {
            AMapNaviDriveManager *driveManager = (AMapNaviDriveManager *)naviManager;
            self.naviRoutes = driveManager.naviRoutes;
        }
        else if ([naviManager isKindOfClass:[AMapNaviRideManager class]]) {
            AMapNaviRideManager *rideManager = (AMapNaviRideManager *)naviManager;
            self.naviRoutes = @{@(0):rideManager.naviRoute};
        }
        else {
            AMapNaviWalkManager *walkManager = (AMapNaviWalkManager *)naviManager;
            self.naviRoutes = @{@(0):walkManager.naviRoute};
        }
        // 绘制路线
        [self editMapView];
    }];
}

// 路线规划失败
- (void)calculateRouteFailure:(AMapNaviBaseManager *)naviManager error:(NSError *)error {
    [self.hud hideAnimated:YES];
    
    self.hud = [MBProgressHUD showFinishHudOn:self.view
                                   withResult:NO
                                    labelText:error.domain
                                    delayHide:YES
                                   completion:nil];
}

// 开始导航
- (void)naviManagerDidStartNavi {
    
}

// 模拟导航到达终点
- (void)naviManagerFinishEmulatorNavi {
    
}
// 实际导航到达终点
- (void)naviManagerFinishGPSNavi {
    
}
// 关闭导航
- (void)naviManagerDidStopNavi {
    self.mapView.hidden = NO;
    self.mapView.alpha = 0.0;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.mapView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3 animations:^{
                             [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
                                 make.top.equalTo(self.view);
                             }];
                             
                             [self.view layoutIfNeeded];
                         }];
                         
                         UIView *naviView = [self.view viewWithTag:10086];
                         [naviView removeFromSuperview];
                         naviView = nil;
                     }];
    
    [[NavigationManager shareManager] startRoutePlanWithEndPoint:self.endPoint];
}

// 点击关闭按钮
- (void)naviViewClickCloseAction {
    self.mapView.hidden = NO;
    self.mapView.alpha = 0.0;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.mapView.alpha = 1.0;
                     }];
}

// 点击更多按钮
- (void)naviViewClickMoreAction {
    
}

@end
