//
//  NaviModel.h
//  Module_demo
//
//  Created by 唐琦 on 2019/9/3.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <AMapNaviKit/AMapNaviKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NaviOverlay : NSObject<MAOverlay>
@property (nonatomic, assign) NSInteger routeID;
@property (nonatomic, assign, getter = isSelected) BOOL selected;
@property (nonatomic, strong) id<MAOverlay> overlay;

- (id)initWithOverlay:(id<MAOverlay>) overlay;

@end

@interface RouteInfo : NSObject
@property (nonatomic, copy) NSString *routeLabel;           // 路线标签
@property (nonatomic, copy) NSString *routeTime;            // 路线时长
@property (nonatomic, copy) NSString *routeLength;          // 路线距离
@property (nonatomic, copy) NSString *trafficLightCount;    // 路线红绿灯数量
@property (nonatomic, copy) NSString *routeSegmentCount;    // 路线路口数量
@property (nonatomic, assign) NSInteger routeID;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) NavigationType naviType;

+ (instancetype)routeWithNaviRoute:(AMapNaviRoute *)naviRoute;

@end

NS_ASSUME_NONNULL_END
