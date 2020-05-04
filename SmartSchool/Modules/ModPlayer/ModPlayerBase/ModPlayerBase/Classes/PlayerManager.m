//
//  PlayerManager.m
//  Unilife
//
//  Created by 唐琦 on 2019/7/15.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "PlayerManager.h"

@interface PlayerManager ()

@end

@implementation PlayerManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static PlayerManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [[PlayerManager alloc] init];
    });
    
    return client;
}

- (void)playVideoWithUrl:(NSString *)urlString title:(NSString *)title {
    Class playerClass = NSClassFromString(@"ModPlayerStyle1ViewController");
    if (playerClass) {
        BaseViewController *playerViewController = [[playerClass alloc] initWithTitle:title rightItem:nil];
        if ([playerViewController respondsToSelector:@selector(playWithUrl:title:)]) {
            [playerViewController performSelectorWithArgs:@selector(playWithUrl:title:), urlString, title];
            
            [TopViewController presentViewController:playerViewController
                                            animated:YES
                                          completion:nil];
        }
    }
}

@end
