//
//  WBGImageToolBase.h
//  CLImageEditorDemo
//
//  Created by Jason on 2017/2/28.
//  Copyright © 2017年 CALACULU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageEditViewController.h"

@interface WBGImageToolBase : NSObject

@property (nonatomic, weak) ImageEditViewController *editor;

- (instancetype)initWithImageEditor:(ImageEditViewController *)editor;

- (void)setup;
- (void)cleanup;
- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;

@end
