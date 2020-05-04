//
//  CameraPhotoEditViewController.h
//  Unilife
//
//  Created by 唐琦 on 2019/10/26.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraData.h"

@interface CameraPhotoEditViewController : UIViewController

- (instancetype)initWithPhoto:(CameraPhotoData *)photo image:(UIImage *)image;

@end
