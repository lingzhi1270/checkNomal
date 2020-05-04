//
//  CameraPhotoEditViewController.m
//  Unilife
//
//  Created by 唐琦 on 2019/10/26.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "CameraPhotoEditViewController.h"
#import "CameraPhotoView.h"
#import "CameraControlPane.h"
#import <NYXImagesKit/NYXImagesKit.h>
#import "SourceManager.h"

@interface CameraPhotoEditViewController () < CameraControlPaneDelegate >

@property (nonatomic, strong) CameraPhotoData       *photo;
@property (nonatomic, copy)   UIImage               *image;

@property (nonatomic, strong) CameraPhotoView       *photoView;
@property (nonatomic, strong) CameraControlPane     *controlPane;
@property (nonatomic, strong) CameraTemplateData    *templateData;

@end

@implementation CameraPhotoEditViewController

- (instancetype)initWithPhoto:(CameraPhotoData *)photo image:(UIImage *)image {
    if (self = [self init]) {
        self.photo = photo;
        self.image = image;
    }
    
    return self;
}

- (void)loadView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor blackColor];
    
    self.photoView = [CameraPhotoView new];
    self.photoView.photo = self.photo;
    self.photoView.image = self.image;
    [self.photoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapPhotoView:)]];
    [view addSubview:self.photoView];
    [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.centerY.equalTo(view).offset(32);
    }];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑照片";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:YUCLOUD_STRING_CLOSE
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(closeViewController)];
    
    self.templateData = [CameraManager shareManager].templates.firstObject;
    
    self.controlPane = [[CameraControlPane alloc] initWithTemplates:[CameraManager shareManager].templates];
    self.controlPane.delegate = self;
    [self.view addSubview:self.controlPane];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showControlPane:YES animated:NO];
}

- (void)setTemplateData:(CameraTemplateData *)templateData {
    if (templateData.backgroundImage) {
        _templateData = templateData;
        
        self.photoView.templateData = templateData;
        [self.photoView layoutIfNeeded];
    }
}

- (void)closeViewController {
    if (self.photoView.image) {
        [YuAlertViewController showAlertWithTitle:nil
                                          message:@"修改没有保存，是否退出？"
                                   viewController:self
                                          okTitle:NSLocalizedString(@"Exit", nil)
                                         okAction:^(UIAlertAction * _Nonnull action) {
                                             [self dismissViewControllerAnimated:YES
                                                                      completion:nil];
                                         }
                                      cancelTitle:YUCLOUD_STRING_CANCEL
                                     cancelAction:nil
                                       completion:nil];
    }
    else {
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }
}

- (void)tapPhotoView:(UITapGestureRecognizer *)tapGesture {
    BOOL visible = CGRectContainsPoint(self.view.frame, self.controlPane.center);
    [self showControlPane:!visible animated:YES];
    
    [self.navigationController setNavigationBarHidden:visible animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showControlPane:(BOOL)show animated:(BOOL)animated {
    [self.controlPane mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        if (show) {
            make.bottom.equalTo(self.view);
        }
        else {
            make.top.equalTo(self.view.mas_bottom);
        }
    }];
    
    if (animated) {
        [UIView animateWithDuration:.3
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }
    else {
        [self.view layoutIfNeeded];
    }
}

#pragma mark - CameraControlPaneDelegate

- (void)controlPane:(CameraControlPane *)pane didSelectedTemplate:(CameraTemplateData *)data {
    if (data.backgroundImage) {
        self.templateData = data;
    }
    else {
        [[UniManager shareManager] prefetchURLs:@[[NSURL URLWithString:data.backgroundImageUrl]]];
        
        [YuAlertViewController showAlertWithTitle:nil
                                          message:@"模板加载失败"
                                   viewController:self
                                          okTitle:YUCLOUD_STRING_OK
                                         okAction:nil
                                      cancelTitle:nil
                                     cancelAction:nil
                                       completion:nil];
    }
}

- (void)controlPaneSelectPhoto {
    [[SourceManager shareManager] getSourcesWithLimit:1
                                                 type:PHAssetMediaTypeImage
                                       viewController:self
                                                 crop:YES
                                               upload:NO
                                            uploadKey:nil
                                        uploadQuality:0.9
                                      fileLengthLimit:0
                                       withCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                                           if (success) {
                                               NSArray *images = info[@"images"];
                                               NSDictionary *dic = images.firstObject;
                                               self.photoView.image = dic[@"image"];
                                           }
                                       }];
}

- (void)controlPaneConfirmPhoto {
    CameraTemplateData *template = self.photoView.templateData;
    if (!template || !template.backgroundImage) {
        [YuAlertViewController showAlertWithTitle:nil
                                          message:@"模板加载失败"
                                   viewController:self
                                          okTitle:YUCLOUD_STRING_OK
                                         okAction:nil
                                      cancelTitle:nil
                                     cancelAction:nil
                                       completion:nil];
        
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                             mode:MBProgressHUDModeIndeterminate
                                            image:nil
                                          message:YUCLOUD_STRING_PLEASE_WAIT
                                        delayHide:NO
                                       completion:nil];
    
    UIImage *image = [self.photoView snapshotImage];
    image = [[UIImage alloc] initWithCGImage:image.CGImage scale:1 orientation:image.imageOrientation];
    image = [image scaleToSize:CGSizeMake(1028, 1028) usingMode:NYXResizeModeAspectFit];
    UIImage *original = self.photoView.image;
    
    dispatch_group_t group = dispatch_group_create();
    __block BOOL result = YES;
    __block NSString *imageUrl, *originalUrl;
    
    [[AppManager shareManager] appWithUid:APP_CAMERA_UID completion:^(BOOL success, NSDictionary * _Nullable info) {
        AppData *app = info[@"data"];
        
        NSString *key = [NSString stringWithFormat:@"%@/%@-%@", app.name, self.photo.name, self.photo.number];
        dispatch_group_enter(group);
        [[UploadManager shareManager] uploadData:UIImageJPEGRepresentation(image, .9)
                                             key:key
                                         fileExt:nil
                                        progress:nil
                                      completion:^(BOOL success, NSDictionary * _Nullable info) {
                                          dispatch_group_leave(group);
                                          result = success && result;
                                          if (result) {
                                              imageUrl = info.url;
                                              
                                              [[SDImageCache sharedImageCache] storeImage:image
                                                                                   forKey:imageUrl
                                                                               completion:nil];
                                          }
                                      }];
        
        dispatch_group_enter(group);
        [[UploadManager shareManager] uploadData:UIImageJPEGRepresentation(original, .7)
                                             key:[key stringByAppendingString:@"-original"]
                                         fileExt:nil
                                        progress:nil
                                      completion:^(BOOL success, NSDictionary * _Nullable info) {
                                          dispatch_group_leave(group);
                                          result = success && result;
                                          if (result) {
                                              originalUrl = info.url;
                                          }
                                      }];
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (result) {
            [[CameraManager shareManager] requestCameraPickWithAction:YuCloudDataEdit
                                                               taskid:(NSInteger)self.photo.taskid
                                                                  uid:(NSInteger)self.photo.uid
                                                             imageUrl:imageUrl
                                                          originalUrl:originalUrl
                                                           completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                               [MBProgressHUD finishHudWithResult:success
                                                                                              hud:hud
                                                                                        labelText:[info errorMsg:success]
                                                                                       completion:^{
                                                                                           if (success) {
                                                                                               [self dismissViewControllerAnimated:YES completion:nil];
                                                                                           }
                                                                                       }];
                                                           }];
        }
        else {
            [MBProgressHUD finishHudWithResult:NO
                                           hud:hud
                                     labelText:YUCLOUD_STRING_FAILED
                                    completion:nil];
        }
    });
}

- (void)controlPaneHide {
    [self showControlPane:NO animated:YES];
}

@end
