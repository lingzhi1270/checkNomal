//
//  ShareModel.h
//  Dreamedu
//
//  Created by 唐琦 on 2019/3/15.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

@interface ShareObject : NSObject

@property (nonatomic) ShareMediaType            type;
@property (nonatomic, copy) NSString            *title;
@property (nonatomic, copy) NSString            *text;
@property (nonatomic, copy) NSURL               *imageURL;
@property (nonatomic, copy) NSString            *url;
@property (nonatomic, copy) UIImage             *image;

+ (instancetype)urlObjectWithTitle:(NSString *)title
                              text:(NSString *)text
                         urlString:(NSString *)urlString
                          imageURL:(NSURL *)imageURL;

+ (instancetype)imgObjectWithImage:(UIImage *)image;

@end

#pragma mark - ShareTarget

@interface ShareTarget : NSObject

@property (nonatomic, copy) UIImage             *image;
@property (nonatomic, copy) NSString            *title;
@property (nonatomic)       ShareActivity       activity;

+ (instancetype)targetWithImage:(UIImage *)image title:(NSString *)title activity:(ShareActivity)activity;

@end
