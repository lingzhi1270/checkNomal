//
//  VoiceHud.h
//  Unilife
//
//  Created by 唐琦 on 2018/3/27.
//  Copyright © 2018年 南京远御网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigureHeader.h"

@interface VoiceHud : UIView

@property (nonatomic, copy)   UIColor       *tintColor;

@property (nonatomic, assign) CGFloat       meter;
@property (nonatomic, copy)   NSString      *title;

@end
