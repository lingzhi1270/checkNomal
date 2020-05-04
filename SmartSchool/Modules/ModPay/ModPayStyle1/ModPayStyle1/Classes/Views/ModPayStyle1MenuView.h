//
//  ModPayStyle1MenuView.h
//  Unilife
//
//  Created by 唐琦 on 2019/8/3.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayManager.h"
#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ModPayStyle1MenuViewDelegate <NSObject>

- (void)payMenuView:(id)menu didSelectedMethod:(PayMethod *)method;
- (void)payMenuViewDidCancel;

@end

@interface ModPayStyle1MenuView : UIView

@property (nonatomic, weak) id<ModPayStyle1MenuViewDelegate>     delegate;

- (instancetype)initWithMethods:(NSArray<PayMethod *> *)methods;

- (void)showMenuAnimated:(BOOL)animated completion:(nullable CommonBlock)completion;

- (void)dismissViewAnimated:(BOOL)animated completion:(nullable dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
