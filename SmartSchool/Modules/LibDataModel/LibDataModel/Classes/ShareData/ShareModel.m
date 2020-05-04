//
//  ShareModel.m
//  Dreamedu
//
//  Created by 唐琦 on 2019/3/15.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ShareModel.h"
#import <LibComponentBase/ConfigureHeader.h>

//#import "AccountManager.h"

@implementation ShareObject

+ (instancetype)urlObjectWithTitle:(NSString *)title
                              text:(NSString *)text
                         urlString:(NSString *)urlString
                          imageURL:(NSURL *)imageURL {
    return [[ShareObject alloc] initWithTitle:title
                                         text:text
                                    urlString:urlString
                                     imageURL:imageURL];
}

+ (instancetype)imgObjectWithImage:(UIImage *)image {
    return [[ShareObject alloc] initWithImage:image];
}

- (instancetype)initWithTitle:(NSString *)title
                         text:(NSString *)text
                    urlString:(NSString *)urlString
                     imageURL:(NSURL *)imageURL {
    if (self = [super init]) {
        self.type = ShareMediaUrl;
        
        self.title = title;
        self.text = text;
        self.url = urlString;
        self.imageURL = imageURL;
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        self.image = image;
    }
    
    return self;
}

@end

#pragma mark - ShareTarget

@implementation ShareTarget

+ (instancetype)targetWithImage:(UIImage *)image title:(NSString *)title activity:(ShareActivity)activity {
    return [[ShareTarget alloc] initWithImage:image title:title activity:activity];
}

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title activity:(ShareActivity)activity {
    if (self = [super init]) {
        self.image = image;
        self.title = title;
        self.activity = activity;
    }
    
    return self;
}

@end
