//
//  NaviModel.m
//  Module_demo
//
//  Created by 唐琦 on 2019/9/3.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "NaviModel.h"

@implementation NaviOverlay

#pragma mark - MAOverlay Protocol
- (CLLocationCoordinate2D)coordinate{
    return [self.overlay coordinate];
}

- (MAMapRect)boundingMapRect{
    return [self.overlay boundingMapRect];
}

#pragma mark - Life Cycle
- (id)initWithOverlay:(id<MAOverlay>)overlay{
    if (self = [super init]) {
        self.overlay       = overlay;
        self.selected      = NO;
    }
    
    return self;
}

@end

@implementation RouteInfo

+ (instancetype)routeWithNaviRoute:(AMapNaviRoute *)naviRoute {
    return [[self alloc] initWithNaviRoute:naviRoute];
}

- (instancetype)initWithNaviRoute:(AMapNaviRoute *)naviRoute {
    if (self = [super init]) {
        self.trafficLightCount = @(naviRoute.routeTrafficLightCount).stringValue;
        self.routeSegmentCount = @(naviRoute.routeSegmentCount).stringValue;
        self.routeLength = [NSString stringWithFormat:@"%.1f公里", naviRoute.routeLength/1000.0];
        NSString *timeString = [NSString stringWithFormat:@"%d分钟", (int)naviRoute.routeTime/60];
        if (naviRoute.routeTime > 60*60) {
            int second = naviRoute.routeTime%(60*60);
            int minute = second/60;
            long hour = naviRoute.routeTime/(60*60);
            
            timeString = [NSString stringWithFormat:@"%ld小时%d分钟", hour, minute];
        }
        
        self.routeTime = timeString;
        
        if (naviRoute.routeLabels.count) {
            AMapNaviRouteLabel *routeLabel = naviRoute.routeLabels.firstObject;
            self.routeLabel = routeLabel.content;
        }
    }
    
    return self;
}

@end
