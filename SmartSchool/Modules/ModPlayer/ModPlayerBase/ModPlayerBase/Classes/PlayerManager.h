//
//  PlayerManager.h
//  Unilife
//
//  Created by 唐琦 on 2019/7/15.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerManager : BaseManager

- (void)playVideoWithUrl:(NSString *)urlString title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
