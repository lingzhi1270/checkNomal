//
//  ModShareStyle1ShareView.h
//  Dreamedu
//
//  Created by 唐琦 on 2019/3/15.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <ModShareBase/ShareManager.h>

@interface ModShareStyle1ShareView : UIView

- (void)configureWithSuperview:(UIView *)superview
                        object:(ShareObject *)object
                  extraTargets:(NSArray *)extraTargets;

- (void)showView;
- (void)dismissView;

@end
