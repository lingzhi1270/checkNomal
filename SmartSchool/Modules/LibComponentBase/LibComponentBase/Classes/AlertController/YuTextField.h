//
//  UITextField.h
//  YuCloud
//
//  Created by 唐琦 on 15/11/20.
//  Copyright © 2015年 VIROYAL-ELEC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigureHeader.h"

@protocol YuTextFieldDelegate <UITextFieldDelegate>


@end

@interface YuTextFieldCommonTarget : NSObject

@end

@interface YuTextField : UITextField

@property (atomic, readonly)    NSInteger               maxInputLength;
@property (atomic, assign)      BOOL                    upperCase;
@property (atomic, readonly)    BOOL                    filterEmoji;

+ (id <YuTextFieldDelegate>)commonYuTextTarget;

- (void)setLeftPadding:(NSInteger)padding mode:(UITextFieldViewMode)mode;
- (void)setRightPadding:(NSInteger)padding mode:(UITextFieldViewMode)mode;
- (void)setLeftImage:(UIImage *)image padding:(NSInteger)padding mode:(UITextFieldViewMode)mode;

- (void)setMaxInputLength:(NSInteger)maxInputLength delegate:(id < YuTextFieldDelegate >)delegate;
- (void)setFilterEmoji:(BOOL)filterEmoji delegate:(id < YuTextFieldDelegate >)delegate;


@end
