//
//  NavigationManager.m
//  Module_demo
//
//  Created by 唐琦 on 2019/9/2.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "NavigationManager.h"
#import <AMapFoundationKit/AMapFoundationKit.h>

#define kDrivingStrategyKey     @"com.viroyal.drivingStrategy"

@interface NavigationManager () <AMapNaviDriveManagerDelegate, AMapNaviDriveViewDelegate, AMapNaviRideManagerDelegate, AMapNaviRideViewDelegate, AMapNaviWalkManagerDelegate, AMapNaviWalkViewDelegate>
// 驾车导航
@property (nonatomic, strong) AMapNaviDriveManager *driveManager;
@property (nonatomic, strong) AMapNaviDriveView *driveView;
@property (nonatomic, assign) AMapNaviDrivingStrategy drivingStrategy;
// 骑行导航
@property (nonatomic, strong) AMapNaviRideManager *rideManager;
@property (nonatomic, strong) AMapNaviRideView *rideView;
// 步行导航
@property (nonatomic, strong) AMapNaviWalkManager *walkManager;
@property (nonatomic, strong) AMapNaviWalkView *walkView;
// 导航状态下非锁车模式定时器
@property (nonatomic, strong) NSTimer *lockedTimer;

@end

@implementation NavigationManager

#pragma mark - 懒加载
- (AMapNaviDriveManager *)driveManager {
    if (!_driveManager) {
        _driveManager = [AMapNaviDriveManager sharedInstance];
        _driveManager.delegate = self;
        _driveManager.allowsBackgroundLocationUpdates = YES;
        _driveManager.isUseInternalTTS = YES;
    }
    
    return _driveManager;
}

- (AMapNaviRideManager *)rideManager {
    if (!_rideManager) {
        _rideManager = [[AMapNaviRideManager alloc] init];
        _rideManager.delegate = self;
        _rideManager.allowsBackgroundLocationUpdates = YES;
        _rideManager.isUseInternalTTS = YES;
    }
    
    return _rideManager;
}

- (AMapNaviWalkManager *)walkManager {
    if (!_walkManager) {
        _walkManager = [[AMapNaviWalkManager alloc] init];
        _walkManager.delegate = self;
        _walkManager.allowsBackgroundLocationUpdates = YES;
        _walkManager.isUseInternalTTS = YES;
    }
    
    return _walkManager;
}

- (AMapNaviDriveView *)driveView {
    if (!_driveView) {
        _driveView = [[AMapNaviDriveView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _driveView.tag = 10086;
        _driveView.delegate = self;
        _driveView.showGreyAfterPass = YES;
        _driveView.mapViewModeType = AMapNaviViewMapModeTypeDayNightAuto;
    }
    
    return _driveView;
}

- (AMapNaviRideView *)rideView {
    if (!_rideView) {
        _rideView = [[AMapNaviRideView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _rideView.tag = 10086;
        _rideView.delegate = self;
    }
    
    return _rideView;
}

- (AMapNaviWalkView *)walkView {
    if (!_walkView) {
        _walkView = [[AMapNaviWalkView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _walkView.tag = 10086;
        _walkView.delegate = self;
    }
    
    return _walkView;
}

#pragma mark - 单例初始化
+ (instancetype)shareManager {
    static NavigationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NavigationManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
        NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
        NSDictionary *platformInfo = infoDic[@"PlatformInfo"];
        if (platformInfo.count) {
            NSString *amapApiKey = platformInfo[@"AmapApiKey"];
            
            if (!amapApiKey.length) {
                NSAssert(NO, @"info.plist未配置高德地图AppKey!");
            }
            
            // 高德
            [AMapServices sharedServices].apiKey = amapApiKey;
        }
        else {
            NSAssert(NO, @"info.plist未配置第三方信息!");
        }
        
        NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:kDrivingStrategyKey];
        if (!number) {
            number = @(AMapNaviDrivingStrategyMultipleDefault);
        }
        
        self.drivingStrategy = number.integerValue;
    }
    
    return self;
}

- (void)showNavigationControllerWithStartPoint:(NSString *)startPoint endPoint:(NSString *)endPoint {
    Class naviClass = NSClassFromString(@"ModNavigationStyle1ViewController");
    if (naviClass) {
        BaseViewController *naviVC = [[naviClass alloc] initWithTitle:@"导航界面" rightItem:nil];
        [NavigationController pushViewController:naviVC animated:YES];
        
        [naviVC performSelectorWithArgs:@selector(startNaviRoutePlanWithStartPoint:endPoint:), startPoint, endPoint];
    }
}

- (void)updateDrivingStrategy:(BOOL)multipleRoute
              avoidCongestion:(BOOL)avoidCongestion
                 avoidHighway:(BOOL)avoidHighway
                    avoidCost:(BOOL)avoidCost
            prioritiseHighway:(BOOL)prioritiseHighway {
    self.drivingStrategy = ConvertDrivingPreferenceToDrivingStrategy(multipleRoute, avoidCongestion, avoidHighway, avoidCost, prioritiseHighway);
    // 保存驾车导航策略
    [[NSUserDefaults standardUserDefaults] setObject:@(self.drivingStrategy) forKey:kDrivingStrategyKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (AMapNaviDrivingStrategy)getDrivingStrategy {
    return self.drivingStrategy;
}

- (void)startRoutePlanWithStartPoint:(AMapNaviPoint *)startPoint
                            endPoint:(AMapNaviPoint *)endPoint {
    switch (self.naviType) {
        case NavigationTypeDrive:
            [self.driveManager calculateDriveRouteWithStartPoints:@[startPoint]
                                                        endPoints:@[endPoint]
                                                        wayPoints:nil
                                                  drivingStrategy:self.drivingStrategy];
            
            break;
            
        case NavigationTypeRide:
            [self.rideManager calculateRideRouteWithStartPoint:startPoint
                                                      endPoint:endPoint];
            
            break;
            
        case NavigationTypeWalk:
            [self.walkManager calculateWalkRouteWithStartPoints:@[startPoint]
                                                      endPoints:@[endPoint]];
            
            break;
            
        default:
            break;
    }
}

- (void)startRoutePlanWithEndPoint:(AMapNaviPoint *)endPoint {
    switch (self.naviType) {
        case NavigationTypeDrive:
            [self.driveManager calculateDriveRouteWithEndPoints:@[endPoint]
                                                        wayPoints:nil
                                                  drivingStrategy:self.drivingStrategy];
            
            break;
            
        case NavigationTypeRide:
            [self.rideManager calculateRideRouteWithEndPoint:endPoint];
            
            break;
            
        case NavigationTypeWalk:
            [self.walkManager calculateWalkRouteWithEndPoints:@[endPoint]];
            
            break;
            
        default:
            break;
    }
}

- (void)selectNaviRouteWithRouteID:(NSInteger)routeID {
    switch (self.naviType) {
        case NavigationTypeDrive:
            [self.driveManager selectNaviRouteWithRouteID:routeID];
            
            break;
            
        case NavigationTypeRide:
//            [self.rideManager selectNaviRouteWithRouteID:routeID];
            
            break;
            
        case NavigationTypeWalk:
//            [self.walkManager selectNaviRouteWithRouteID:routeID];
            
            break;
            
        default:
            break;
    }
}

- (void)startEmulatorNaviWithViewController:(UIViewController *)viewController {
    switch (self.naviType) {
        case NavigationTypeDrive: {
            [self.driveManager setEmulatorNaviSpeed:120];
            [self.driveManager startEmulatorNavi];
            [self.driveManager addDataRepresentative:self.driveView];
            
            MAMapView *mapView = [viewController.view viewWithTag:10010];
            [viewController.view insertSubview:self.driveView belowSubview:mapView];
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 mapView.alpha = 0.0;
                             } completion:^(BOOL finished) {
                                 mapView.hidden = YES;
                             }];
        }
            break;
            
        case NavigationTypeRide: {
            [self.rideManager setEmulatorNaviSpeed:35];
            [self.rideManager startEmulatorNavi];
            [self.rideManager addDataRepresentative:self.rideView];
    
            MAMapView *mapView = [viewController.view viewWithTag:10010];
            [viewController.view insertSubview:self.rideView belowSubview:mapView];
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 mapView.alpha = 0.0;
                             } completion:^(BOOL finished) {
                                 mapView.hidden = YES;
                             }];
        }
            break;
            
        case NavigationTypeWalk: {
            [self.walkManager setEmulatorNaviSpeed:10];
            [self.walkManager startEmulatorNavi];
            [self.walkManager addDataRepresentative:self.walkView];
    
            MAMapView *mapView = [viewController.view viewWithTag:10010];
            [viewController.view insertSubview:self.walkView belowSubview:mapView];
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 mapView.alpha = 0.0;
                             } completion:^(BOOL finished) {
                                 mapView.hidden = YES;
                             }];
        }
            break;
            
        default:
            break;
    }
}

- (void)startGPSNaviWithViewController:(UIViewController *)viewController {
    switch (self.naviType) {
        case NavigationTypeDrive:
            [self.driveManager startGPSNavi];
            
            [self.driveManager addDataRepresentative:self.driveView];
            [viewController.view insertSubview:self.driveView belowSubview:[viewController.view viewWithTag:10001]];
        
            break;
            
        case NavigationTypeRide:
            [self.rideManager startGPSNavi];
            
            [self.rideManager addDataRepresentative:self.rideView];
            [viewController.view insertSubview:self.driveView belowSubview:[viewController.view viewWithTag:10001]];
        
            break;
            
        case NavigationTypeWalk:
            [self.walkManager startGPSNavi];
            
            [self.walkManager addDataRepresentative:self.walkView];
            [viewController.view insertSubview:self.driveView belowSubview:[viewController.view viewWithTag:10001]];

    
            break;
            
        default:
            break;
    }
}

- (void)stopNavi {
    switch (self.naviType) {
        case NavigationTypeDrive:
            [self.driveManager stopNavi];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(naviManagerDidStopNavi)]) {
                [self.delegate naviManagerDidStopNavi];
            }

            [self performSelector:@selector(destroyDriveManager) withObject:nil afterDelay:1.0];
            
            break;
            
        case NavigationTypeRide:
            [self.rideManager stopNavi];
            [self.rideManager removeDataRepresentative:self.rideView];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(naviManagerDidStopNavi)]) {
                [self.delegate naviManagerDidStopNavi];
            }

            break;
            
        case NavigationTypeWalk:
            [self.walkManager stopNavi];
            [self.walkManager removeDataRepresentative:self.walkView];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(naviManagerDidStopNavi)]) {
                [self.delegate naviManagerDidStopNavi];
            }

            break;
            
        default:
            break;
    }
}

- (void)destroyDriveManager {
    [self.driveManager removeDataRepresentative:self.driveView];
    self.driveManager.delegate = nil;
    self.driveManager = nil;

    BOOL success = [AMapNaviDriveManager destroyInstance];
//    DDLog(@"单例是否销毁成功 : %d",success);
}

#pragma mark - AMapNaviDriveManagerDelegate
// 发生错误时,会调用代理的此方法
- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(calculateRouteFailure:error:)]) {
        [self.delegate calculateRouteFailure:driveManager error:error];
    }
}

// 驾车路径规划成功后的回调函数 since 6.1.0
- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteSuccessWithType:(AMapNaviRoutePlanType)type {
    if (self.delegate && [self.delegate respondsToSelector:@selector(calculateRouteSuccess:)]) {
        [self.delegate calculateRouteSuccess:driveManager];
    }
}

// 驾车路径规划失败后的回调函数. since 6.1.0
- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error routePlanType:(AMapNaviRoutePlanType)type {
    if (self.delegate && [self.delegate respondsToSelector:@selector(calculateRouteFailure:error:)]) {
        [self.delegate calculateRouteFailure:driveManager error:error];
    }
}

// 启动导航后回调函数
- (void)driveManager:(AMapNaviDriveManager *)driveManager didStartNavi:(AMapNaviMode)naviMode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(naviManagerDidStartNavi)]) {
        [self.delegate naviManagerDidStartNavi];
    }
}

// 出现偏航需要重新计算路径时的回调函数.偏航后将自动重新路径规划,该方法将在自动重新路径规划前通知您进行额外的处理.
- (void)driveManagerNeedRecalculateRouteForYaw:(AMapNaviDriveManager *)driveManager {
    
}

// 前方遇到拥堵需要重新计算路径时的回调函数.拥堵后将自动重新路径规划,该方法将在自动重新路径规划前通知您进行额外的处理.
- (void)driveManagerNeedRecalculateRouteForTrafficJam:(AMapNaviDriveManager *)driveManager {
    
}

//// 开发者请根据实际情况返回是否正在播报语音，如果正在播报语音，请返回YES, 如果没有在播报语音，请返回NO
//// 如一直返回YES，SDK内部会认为外界一直在播报，"-driveManager:playNaviSoundString:soundStringType" 就会一直不触发，导致无文字吐出; 如一直返回NO，文字吐出的频率可能会过快，会出现语句打断情况，所以请根据实际情况返回。
//- (BOOL)driveManagerIsNaviSoundPlaying:(AMapNaviDriveManager *)driveManager {
//
//}

/**
 * @brief 导航播报信息回调函数,此回调函数需要和driveManagerIsNaviSoundPlaying:配合使用
 * @param driveManager 驾车导航管理类
 * @param soundString 播报文字
 * @param soundStringType 播报类型,参考 AMapNaviSoundType. 注意：since 6.0.0 AMapNaviSoundType 只返回 AMapNaviSoundTypeDefault
 */
- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType {
    
}

// 模拟导航到达目的地后的回调函数
- (void)driveManagerDidEndEmulatorNavi:(AMapNaviDriveManager *)driveManager {
    [self stopNavi];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(naviManagerFinishEmulatorNavi)]) {
        [self.delegate naviManagerFinishEmulatorNavi];
    }
}

// GPS导航到达目的地后的回调函数
- (void)driveManagerOnArrivedDestination:(AMapNaviDriveManager *)driveManager {
    [self stopNavi];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(naviManagerFinishGPSNavi)]) {
        [self.delegate naviManagerFinishGPSNavi];
    }
}

// 导航(巡航)过程中播放提示音的回调函数. since 5.4.0
- (void)driveManager:(AMapNaviDriveManager *)driveManager onNaviPlayRing:(AMapNaviRingType)ringType {
    
}

// GPS信号强弱回调函数. since 5.5.0
- (void)driveManager:(AMapNaviDriveManager *)driveManager updateGPSSignalStrength:(AMapNaviGPSSignalStrength)gpsSignalStrength {
    
}

#pragma mark - AMapNaviDriveViewDelegate
// 驾车导航界面关闭按钮点击时的回调函数
- (void)driveViewCloseButtonClicked:(AMapNaviDriveView *)driveView {
    [YuAlertViewController showAlertWithTitle:@"退出导航"
                                      message:@"是否确认退出导航"
                               viewController:TopViewController
                                      okTitle:@"退出导航"
                                     okAction:^(UIAlertAction * _Nonnull action) {
                                         [self stopNavi];
                                         if (self.delegate && [self.delegate respondsToSelector:@selector(naviViewClickCloseAction)]) {
                                             [self.delegate naviViewClickCloseAction];
                                         }

                                     }
                                  cancelTitle:@"取消"
                                 cancelAction:nil
                                   completion:nil];
    
}

// 驾车导航界面更多按钮点击时的回调函数
- (void)driveViewMoreButtonClicked:(AMapNaviDriveView *)driveView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(naviViewClickMoreAction)]) {
        [self.delegate naviViewClickMoreAction];
    }
}

// 驾车导航界面显示模式改变后的回调函数
- (void)driveView:(AMapNaviDriveView *)driveView didChangeShowMode:(AMapNaviDriveViewShowMode)showMode {
    if (showMode != AMapNaviDriveViewShowModeCarPositionLocked) {
        static int time = 0;

        if ([self.lockedTimer isValid]) {
            [self.lockedTimer invalidate];
            self.lockedTimer = nil;
            time = 0;
        }

        self.lockedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             block:^(NSTimer * _Nonnull timer) {
                                                                 time++;
//                                                                 DDLog(@"切换为锁车模式倒计时 %d...", (6-time));
                                                                 
                                                                 if (time > 5) {
                                                                     [timer invalidate];
                                                                     timer = nil;
                                                                     time = 0;
                                                                     // 切换显示模式为锁车模式
                                                                     driveView.showMode = AMapNaviDriveViewShowModeCarPositionLocked;
                                                                 }
                                                             }
                                                           repeats:YES];
    }
}

#pragma mark - AMapNaviRideManagerDelegate
/**
 * @brief 发生错误时,会调用代理的此方法
 * @param rideManager 骑行导航管理类
 * @param error 错误信息
 */
- (void)rideManager:(AMapNaviRideManager *)rideManager error:(NSError *)error {
    
}

/**
 * @brief 骑行路径规划成功后的回调函数
 * @param rideManager 骑行导航管理类
 */
- (void)rideManagerOnCalculateRouteSuccess:(AMapNaviRideManager *)rideManager {
    if (self.delegate && [self.delegate respondsToSelector:@selector(calculateRouteSuccess:)]) {
        [self.delegate calculateRouteSuccess:rideManager];
    }
}

/**
 * @brief 骑行路径规划失败后的回调函数. 从6.1.0版本起,算路失败后导航SDK只对外通知算路失败,SDK内部不再执行停止导航的相关逻辑.因此,当算路失败后,不会收到 driveManager:updateNaviMode: 回调; AMapNaviRideManager.naviMode 不会切换到 AMapNaviModeNone 状态, 而是会保持在 AMapNaviModeGPS or AMapNaviModeEmulator 状态
 * @param rideManager 骑行导航管理类
 * @param error 错误信息,error.code参照AMapNaviCalcRouteState
 */
- (void)rideManager:(AMapNaviRideManager *)rideManager onCalculateRouteFailure:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(calculateRouteFailure:error:)]) {
        [self.delegate calculateRouteFailure:rideManager error:error];
    }
}

/**
 * @brief 启动导航后回调函数
 * @param rideManager 骑行导航管理类
 * @param naviMode 导航类型，参考AMapNaviMode
 */
- (void)rideManager:(AMapNaviRideManager *)rideManager didStartNavi:(AMapNaviMode)naviMode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(naviManagerDidStartNavi)]) {
        [self.delegate naviManagerDidStartNavi];
    }
}

/**
 * @brief 出现偏航需要重新计算路径时的回调函数.偏航后将自动重新路径规划,该方法将在自动重新路径规划前通知您进行额外的处理.
 * @param rideManager 骑行导航管理类
 */
- (void)rideManagerNeedRecalculateRouteForYaw:(AMapNaviRideManager *)rideManager {
    
}

/**
 * @brief 导航播报信息回调函数
 * @param rideManager 骑行导航管理类
 * @param soundString 播报文字
 * @param soundStringType 播报类型,参考 AMapNaviSoundType. 注意：since 6.0.0 AMapNaviSoundType 只返回 AMapNaviSoundTypeDefault
 */
- (void)rideManager:(AMapNaviRideManager *)rideManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType {
    
}

/**
 * @brief 模拟导航到达目的地停止导航后的回调函数
 * @param rideManager 骑行导航管理类
 */
- (void)rideManagerDidEndEmulatorNavi:(AMapNaviRideManager *)rideManager {
    [self stopNavi];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(naviManagerFinishEmulatorNavi)]) {
        [self.delegate naviManagerFinishEmulatorNavi];
    }
}

/**
 * @brief 导航到达目的地后的回调函数
 * @param rideManager 骑行导航管理类
 */
- (void)rideManagerOnArrivedDestination:(AMapNaviRideManager *)rideManager {
    [self stopNavi];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(naviManagerFinishGPSNavi)]) {
        [self.delegate naviManagerFinishGPSNavi];
    }
}

#pragma mark - AMapNaviRideViewDelegate
// 骑行导航界面关闭按钮点击时的回调函数
- (void)rideViewCloseButtonClicked:(AMapNaviRideView *)rideView {
    [YuAlertViewController showAlertWithTitle:@"退出导航"
                                      message:@"是否确认退出导航"
                               viewController:TopViewController
                                      okTitle:@"退出导航"
                                     okAction:^(UIAlertAction * _Nonnull action) {
                                         [self stopNavi];
                                         if (self.delegate && [self.delegate respondsToSelector:@selector(naviViewClickCloseAction)]) {
                                             [self.delegate naviViewClickCloseAction];
                                         }
                                     }
                                  cancelTitle:@"取消"
                                 cancelAction:nil
                                   completion:nil];
    
    
}

// 骑行导航界面更多按钮点击时的回调函数
- (void)rideViewMoreButtonClicked:(AMapNaviRideView *)rideView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(naviViewClickMoreAction)]) {
        [self.delegate naviViewClickMoreAction];
    }
}

// 骑行界面显示模式改变后的回调函数
- (void)rideView:(AMapNaviRideView *)rideView didChangeShowMode:(AMapNaviRideViewShowMode)showMode {
    if (showMode != AMapNaviRideViewShowModeCarPositionLocked) {
        static int time = 0;
        
        if ([self.lockedTimer isValid]) {
            [self.lockedTimer invalidate];
            self.lockedTimer = nil;
            time = 0;
        }
        
        self.lockedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             block:^(NSTimer * _Nonnull timer) {
                                                                 time++;
//                                                                 DDLog(@"切换为锁车模式倒计时 %d...", (5-time));
                                                                 
                                                                 if (time > 5) {
                                                                     [timer invalidate];
                                                                     timer = nil;
                                                                     time = 0;
                                                                     rideView.showMode = AMapNaviRideViewShowModeCarPositionLocked;
                                                                 }
                                                             }
                                                           repeats:YES];
    }
}

#pragma mark - AMapNaviWalkManagerDelegate
/**
 * @brief 发生错误时,会调用代理的此方法
 * @param walkManager 步行导航管理类
 * @param error 错误信息
 */
- (void)walkManager:(AMapNaviWalkManager *)walkManager error:(NSError *)error {
    
}

/**
 * @brief 步行路径规划成功后的回调函数
 * @param walkManager 步行导航管理类
 */
- (void)walkManagerOnCalculateRouteSuccess:(AMapNaviWalkManager *)walkManager {
    if (self.delegate && [self.delegate respondsToSelector:@selector(calculateRouteSuccess:)]) {
        [self.delegate calculateRouteSuccess:walkManager];
    }
}

/**
 * @brief 步行路径规划失败后的回调函数. 从6.1.0版本起,算路失败后导航SDK只对外通知算路失败,SDK内部不再执行停止导航的相关逻辑.因此,当算路失败后,不会收到 driveManager:updateNaviMode: 回调; AMapNaviWalkManager.naviMode 不会切换到 AMapNaviModeNone 状态, 而是会保持在 AMapNaviModeGPS or AMapNaviModeEmulator 状态
 * @param walkManager 步行导航管理类
 * @param error 错误信息,error.code参照AMapNaviCalcRouteState
 */
- (void)walkManager:(AMapNaviWalkManager *)walkManager onCalculateRouteFailure:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(calculateRouteFailure:error:)]) {
        [self.delegate calculateRouteFailure:walkManager error:error];
    }
}

/**
 * @brief 启动导航后回调函数
 * @param walkManager 步行导航管理类
 * @param naviMode 导航类型，参考AMapNaviMode
 */
- (void)walkManager:(AMapNaviWalkManager *)walkManager didStartNavi:(AMapNaviMode)naviMode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(naviManagerDidStartNavi)]) {
        [self.delegate naviManagerDidStartNavi];
    }
}

/**
 * @brief 出现偏航需要重新计算路径时的回调函数.偏航后将自动重新路径规划,该方法将在自动重新路径规划前通知您进行额外的处理.
 * @param walkManager 步行导航管理类
 */
- (void)walkManagerNeedRecalculateRouteForYaw:(AMapNaviWalkManager *)walkManager {
    
}

/**
 * @brief 导航播报信息回调函数
 * @param walkManager 步行导航管理类
 * @param soundString 播报文字
 * @param soundStringType 播报类型,参考AMapNaviSoundType. 注意：since 6.0.0 AMapNaviSoundType 只返回 AMapNaviSoundTypeDefault
 */
- (void)walkManager:(AMapNaviWalkManager *)walkManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType {
    
}

/**
 * @brief 模拟导航到达目的地停止导航后的回调函数
 * @param walkManager 步行导航管理类
 */
- (void)walkManagerDidEndEmulatorNavi:(AMapNaviWalkManager *)walkManager {
    [self stopNavi];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(naviManagerFinishEmulatorNavi)]) {
        [self.delegate naviManagerFinishEmulatorNavi];
    }
}

/**
 * @brief 导航到达目的地后的回调函数
 * @param walkManager 步行导航管理类
 */
- (void)walkManagerOnArrivedDestination:(AMapNaviWalkManager *)walkManager {
    [self stopNavi];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(naviManagerFinishGPSNavi)]) {
        [self.delegate naviManagerFinishGPSNavi];
    }
}

#pragma mark - AMapNaviWalkViewDelegate
// 步行导航界面关闭按钮点击时的回调函数
- (void)walkViewCloseButtonClicked:(AMapNaviWalkView *)walkView {
    [YuAlertViewController showAlertWithTitle:@"退出导航"
                                      message:@"是否确认退出导航"
                               viewController:TopViewController
                                      okTitle:@"退出导航"
                                     okAction:^(UIAlertAction * _Nonnull action) {
                                         [self stopNavi];
                                         if (self.delegate && [self.delegate respondsToSelector:@selector(naviViewClickCloseAction)]) {
                                             [self.delegate naviViewClickCloseAction];
                                         }
                                     }
                                  cancelTitle:@"取消"
                                 cancelAction:nil
                                   completion:nil];
    
    
}

// 步行导航界面更多按钮点击时的回调函数
- (void)walkViewMoreButtonClicked:(AMapNaviWalkView *)walkView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(naviViewClickMoreAction)]) {
        [self.delegate naviViewClickMoreAction];
    }
}

// 步行界面显示模式改变后的回调函数
- (void)walkView:(AMapNaviWalkView *)walkView didChangeShowMode:(AMapNaviWalkViewShowMode)showMode {
    if (showMode != AMapNaviWalkViewShowModeCarPositionLocked) {
        static int time = 0;
        
        if ([self.lockedTimer isValid]) {
            [self.lockedTimer invalidate];
            self.lockedTimer = nil;
            time = 0;
        }
        
        self.lockedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             block:^(NSTimer * _Nonnull timer) {
                                                                 time++;
//                                                             DDLog(@"切换为锁车模式倒计时 %d...", (5-time));
                                                                 
                                                                 if (time > 5) {
                                                                     [timer invalidate];
                                                                     timer = nil;
                                                                     time = 0;
                                                                     walkView.showMode = AMapNaviWalkViewShowModeCarPositionLocked;
                                                                 }
                                                             }
                                                           repeats:YES];
    }
}

@end
