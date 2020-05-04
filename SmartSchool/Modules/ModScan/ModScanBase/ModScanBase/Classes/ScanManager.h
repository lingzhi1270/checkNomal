//
//  ScanManager.h
//  Menci
//
//  Created by 唐琦 on 2019/12/2.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN
@interface ScanManager : BaseManager

- (void)startCodeScanWithCompletion:(CommonBlock)completion;

@end

NS_ASSUME_NONNULL_END
