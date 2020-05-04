//
//  ShareManager.h
//  Menci
//
//  Created by 唐琦 on 2019/12/2.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/ShareModel.h>

NS_ASSUME_NONNULL_BEGIN
@interface ShareManager : BaseManager

- (void)shareWithView:(UIView *)view
               object:(ShareObject *)object
         extraTargets:(NSArray *)extraTargets;

- (void)dealWithTarget:(ShareTarget *)target
                object:(ShareObject *)object;

@end

NS_ASSUME_NONNULL_END
