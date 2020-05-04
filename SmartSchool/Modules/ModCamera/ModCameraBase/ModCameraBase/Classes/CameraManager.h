//
//  CameraManager.h
//  Dreamedu
//
//  Created by 唐琦 on 2019/2/21.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraManager : BaseManager

- (void)startCameraWithCameraType:(CameraType)cameraType
                   viewController:(UIViewController *)viewController;

@end


NS_ASSUME_NONNULL_END
