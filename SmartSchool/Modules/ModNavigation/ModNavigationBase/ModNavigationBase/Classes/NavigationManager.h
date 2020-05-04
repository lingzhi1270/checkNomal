//
//  NavigationManager.h
//  Module_demo
//
//  Created by 唐琦 on 2019/9/2.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import "NaviModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NavigationManagerDelegate <NSObject>
// 路线规划成功
- (void)calculateRouteSuccess:(AMapNaviBaseManager *)naviManager;
// 路线规划失败
- (void)calculateRouteFailure:(AMapNaviBaseManager *)naviManager error:(NSError *)error;
// 开始导航
- (void)naviManagerDidStartNavi;
// 模拟导航到达终点
- (void)naviManagerFinishEmulatorNavi;
// 实际导航到达终点
- (void)naviManagerFinishGPSNavi;
// 关闭导航
- (void)naviManagerDidStopNavi;
// 点击关闭按钮
- (void)naviViewClickCloseAction;
// 点击更多按钮
- (void)naviViewClickMoreAction;

@end

@interface NavigationManager : BaseManager
@property (nonatomic, assign) NavigationType naviType;
@property (nonatomic, assign) id<NavigationManagerDelegate> delegate;

- (void)showNavigationControllerWithStartPoint:(NSString *)startPoint endPoint:(NSString *)endPoint;

/**
 更新驾车导航策略

 @param multipleRoute 是否多路径规划
 @param avoidCongestion 是否躲避拥堵
 @param avoidHighway 是否不走高速
 @param avoidCost 是否避免收费
 @param prioritiseHighway 是否高速优先
 提示: 高速优先与(避免收费或不走高速)不能同时为true。
 */
- (void)updateDrivingStrategy:(BOOL)multipleRoute
              avoidCongestion:(BOOL)avoidCongestion
                 avoidHighway:(BOOL)avoidHighway
                    avoidCost:(BOOL)avoidCost
            prioritiseHighway:(BOOL)prioritiseHighway;

/**
 获取当前驾车导航策略

 @return 当前驾车导航策略
 */
- (AMapNaviDrivingStrategy)getDrivingStrategy;

/**
 路线规划(有起点)

 @param startPoint 起点
 @param endPoint 终点
 */
- (void)startRoutePlanWithStartPoint:(AMapNaviPoint *)startPoint
                            endPoint:(AMapNaviPoint *)endPoint;

/**
 路线规划(无起点)
 
 @param endPoint 终点
 */
- (void)startRoutePlanWithEndPoint:(AMapNaviPoint *)endPoint;


/**
 切换线路

 @param routeID 路线ID
 */
- (void)selectNaviRouteWithRouteID:(NSInteger)routeID;

/**
 开启模拟导航
 */
- (void)startEmulatorNaviWithViewController:(UIViewController *)viewController;

/**
 开启GPS导航
 */
- (void)startGPSNaviWithViewController:(UIViewController *)viewController;

/**
 停止导航
 */
- (void)stopNavi;

@end

NS_ASSUME_NONNULL_END
