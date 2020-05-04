//
//  CameraControlPane.h
//  Unilife
//
//  Created by 唐琦 on 2019/9/11.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraManager.h"

@class CameraControlPane;

@protocol CameraControlPaneDelegate <NSObject>

- (void)controlPane:(CameraControlPane *)pane didSelectedTemplate:(CameraTemplateData *)data;

- (void)controlPaneSelectPhoto;
- (void)controlPaneConfirmPhoto;
- (void)controlPaneHide;

@end

@interface CameraControlPane : UIView

@property (nonatomic, weak) id<CameraControlPaneDelegate>       delegate;

- (instancetype)initWithTemplates:(NSArray *)templates;

- (void)selectTemplateAtIndex:(NSInteger)index;

@end
