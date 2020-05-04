//
//  ScanManager.m
//  Menci
//
//  Created by 唐琦 on 2019/12/2.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ScanManager.h"

@interface ScanManager ()
@property (nonatomic, copy) CommonBlock codeScanCompletion;

@end

@implementation ScanManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static ScanManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [ScanManager new];
    });
    
    return client;
}

- (void)startCodeScanWithCompletion:(CommonBlock)completion {
    Class class = NSClassFromString(@"ModScanStyle1ViewController");
    if (class) {
        BaseViewController *codeScan = [[class alloc] initWithTitle:@"二维码" rightItem:nil];
        [codeScan setValue:self forKey:@"delegate"];
        self.codeScanCompletion = completion;
        
        MainNavigationController *nav = [[MainNavigationController alloc] initWithRootViewController:codeScan];
        // 模态弹出
        [TopViewController presentViewController:nav
                                        animated:YES
                                      completion:nil];
    }
}

#pragma mark - ModScanStyle1ViewControllerDelegate
- (void)scanCanceled {
    if (self.codeScanCompletion) {
        self.codeScanCompletion(NO, nil);
    }
}

- (void)scanCodeFound:(NSString *)result {
    self.codeScanCompletion(YES, @{@"result":result});
}

@end
