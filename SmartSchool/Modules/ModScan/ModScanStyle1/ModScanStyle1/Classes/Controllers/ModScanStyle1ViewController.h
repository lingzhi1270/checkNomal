//
//  ModScanStyle1ViewController.h
//  Unilife
//
//  Created by 唐琦 on 2019/7/5.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LibComponentBase/ConfigureHeader.h>

@protocol ModScanStyle1ViewControllerDelegate <NSObject>

- (void)scanCanceled;
- (void)scanCodeFound:(NSString *)result;

@end

@interface ModScanStyle1ViewController : BaseViewController
@property (nonatomic, weak) id<ModScanStyle1ViewControllerDelegate>  delegate;

@end
