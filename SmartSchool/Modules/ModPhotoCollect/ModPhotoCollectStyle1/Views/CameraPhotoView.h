//
//  CameraPhotoView.h
//  Unilife
//
//  Created by 唐琦 on 2019/9/8.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraControlPane.h"
#import "CameraManager.h"

@interface CameraPhotoView : UIView

@property (nonatomic, strong) CameraPhotoData       *photo;
@property (nonatomic, strong) CameraTemplateData    *templateData;
@property (nonatomic, copy)   UIImage               *image;

@end
