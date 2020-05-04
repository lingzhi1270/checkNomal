//
//  ChatCameraViewController.h
//  Conversation
//
//  Created by qlon 2019/4/24.
//

#import <LibComponentBase/ConfigureHeader.h>

typedef void(^cameraBlock)(NSData *videoData, UIImage *thumbImage, NSData *imageData, UIImage *image);

@interface ModCameraStyle1ViewController : BaseViewController
@property (nonatomic, copy) cameraBlock block;
// 当前是前置摄像头还是后置摄像头
@property (nonatomic, assign) BOOL isFrontCamera;
@property (nonatomic, assign) BOOL isEdit;

@end
