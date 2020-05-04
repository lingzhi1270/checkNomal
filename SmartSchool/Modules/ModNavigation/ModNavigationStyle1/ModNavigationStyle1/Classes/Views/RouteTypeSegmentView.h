//
//  RouteTypeSegmentView.h
//  Module_demo
//
//  Created by 唐琦 on 2019/9/4.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

#define kRouteTypeSegmentViewHeight    50.f

@protocol RouteTypeSegmentViewDelegate <NSObject>

- (void)didSelectedTypeWithIndex:(NSInteger)index;

@end

@interface RouteTypeSegmentView : UIView
@property (nonatomic, assign) id<RouteTypeSegmentViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
