//
//  WBGImageToolBase.m
//  CLImageEditorDemo
//
//  Created by Jason on 2017/2/28.
//  Copyright © 2017年 CALACULU. All rights reserved.
//

#import "WBGImageToolBase.h"

@implementation WBGImageToolBase

- (instancetype)initWithImageEditor:(ImageEditViewController *)editor {
    self = [super init];
    if(self) {
        self.editor   = editor;
    }
    return self;
}

#pragma mark - need subclass override
- (void)setup
{
    
}

- (void)cleanup
{
    
}

- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock
{
    completionBlock(self.editor.editImage, nil, nil);
}

- (UIImage*)imageForKey:(NSString*)key defaultImageName:(NSString*)defaultImageName {
    return nil;
}

@end
