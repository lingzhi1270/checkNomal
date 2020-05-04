//
//  RouteSelectorView.h
//  Module_demo
//
//  Created by 唐琦 on 2019/9/3.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kRouteSelectorViewHeight    140.f

@protocol RouteSelectorViewDelegate <NSObject>

- (void)didSelectedRouteWithRouteID:(NSInteger)routeID;
- (void)didSelectNavigation;

@end

@interface RouteSelectorView : UIView
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, assign) id<RouteSelectorViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
