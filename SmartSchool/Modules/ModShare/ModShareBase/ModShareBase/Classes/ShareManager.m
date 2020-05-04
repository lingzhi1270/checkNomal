//
//  ShareManager.m
//  Menci
//
//  Created by 唐琦 on 2019/12/2.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ShareManager.h"
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <Photos/Photos.h>

@interface ShareManager ()
@property (nonatomic, strong) UIView *shareView;

@end

@implementation ShareManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static ShareManager *client = nil;
    dispatch_once(&onceToken, ^{
        client = [ShareManager new];
    });
    
    return client;
}

- (instancetype)init {
    if (self = [super init]) {
        NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
        NSDictionary *platformInfo = infoDic[@"PlatformInfo"];
        
        if (platformInfo.count) {
            NSString *qqAppID = platformInfo[@"QQAppID"];
            NSString *qqAppSecret = platformInfo[@"QQAppSecret"];
            NSString *wechatAppID = platformInfo[@"WechatAppID"];
            NSString *wechatAppSecret = platformInfo[@"WechatAppSecret"];
            NSString *universalLink = platformInfo[@"UniversalLink"];
            
            if (!qqAppID.length ||
                !qqAppSecret.length) {
                NSAssert(NO, @"info/plist未配置QQ的AppKey或AppSecret");
            }
            
            if (!wechatAppID.length ||
                !wechatAppSecret.length ||
                !universalLink.length) {
                NSAssert(NO, @"info/plist未配置微信的AppKey、AppSecret和通用链接");
            }
            // 第三方分享
            [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {
                //QQ
                [platformsRegister setupQQWithAppId:qqAppID
                                             appkey:qqAppSecret];
                
                //微信
                [platformsRegister setupWeChatWithAppId:wechatAppID
                                              appSecret:wechatAppSecret
                                          universalLink:universalLink];
            }];
        }
        
    }
    
    return self;
}

- (void)shareWithView:(UIView *)view
               object:(ShareObject *)object
         extraTargets:(NSArray *)extraTargets {
    Class shareClass = NSClassFromString(@"ModShareStyle1ShareView");
    if (shareClass) {
        UIView *shareView = [[shareClass alloc] initWithFrame:view.bounds];
        [view addSubview:shareView];
        
        if (shareView && [shareView respondsToSelector:@selector(configureWithSuperview:object:extraTargets:)]) {
            [shareView performSelectorWithArgs:@selector(configureWithSuperview:object:extraTargets:), view, object, extraTargets];
        }
        
        if (shareView && [shareView respondsToSelector:@selector(showView)]) {
            [shareView performSelector:@selector(showView)];
        }
    }
}

- (void)dealWithTarget:(ShareTarget *)shareTarget
                object:(ShareObject *)shareObject{
    id image = shareObject.image;
    if (!image) {
        if (shareObject.imageURL) {
            image = shareObject.imageURL;
        }
        else {
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"LibComponentBase" ofType:@"bundle"];
            NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
            image = [UIImage imageNamed:@"ic_logo" inBundle:bundle compatibleWithTraitCollection:nil];
        }
    }
    
    // 分享
    if (shareTarget.activity < ShareFavourite) {
        // 分享参数
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:shareObject.text
                                         images:image
                                            url:[NSURL URLWithString:shareObject.url]
                                          title:shareObject.title
                                           type:SSDKContentTypeAuto];
        
        SSDKPlatformType platformType = SSDKPlatformTypeUnknown;
        
        switch (shareTarget.activity) {
            case ShareToWechatFriends:
                platformType = SSDKPlatformSubTypeWechatSession;
                
                break;
                
            case ShareToWechatMoments:
                platformType = SSDKPlatformSubTypeWechatTimeline;
                
                break;
                
            case ShareToQQFriends:
                platformType = SSDKPlatformSubTypeQQFriend;
                
                break;
                
            case ShareToQQZone:
                platformType = SSDKPlatformSubTypeQZone;
                
                break;
                
            default:
                break;
        }
        
        [ShareSDK  share:platformType
              parameters:shareParams
          onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
            switch (state) {
                case SSDKResponseStateSuccess:
//                    DDLog(@"分享成功");

                    break;
            
                case SSDKResponseStateFail:
//                    DDLog(@"分享失败 %@", error.description);

                    //失败
                    break;
                
                case SSDKResponseStateCancel:
//                    DDLog(@"分享取消");

                    break;
                    
                default:
                    break;
            }
        }];
    }
    else {
        switch (shareTarget.activity) {
            // 收藏
            case ShareFavourite:
//                DDLog(@"根据业务逻辑实现 网络或本地收藏");
                
                break;
                
            // 编辑
            case ShareEdit:
//                DDLog(@"根据业务逻辑实现 编辑功能");
                
                break;
                
            // 删除
            case ShareDelete:
//                DDLog(@"根据业务逻辑实现 编辑功能");
                
                break;
                
            // 拷贝链接
            case ShareCopyURL:
                [[UIPasteboard generalPasteboard] setURL:[NSURL URLWithString:shareObject.url]];
                
                [MBProgressHUD showHudOn:[UIApplication sharedApplication].keyWindow
                                    mode:MBProgressHUDModeText
                                   image:nil
                                 message:@"拷贝链接成功!"
                               delayHide:YES
                              completion:nil];
                
                break;
                
             // 保存图片
            case ShareSaveImage: {
                MBProgressHUD *hud = [MBProgressHUD showHudOn:TopViewController.view
                                                         mode:MBProgressHUDModeIndeterminate
                                                        image:nil
                                                      message:YUCLOUD_STRING_PLEASE_WAIT
                                                    delayHide:NO
                                                   completion:nil];
                
                [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:shareObject.imageURL]
                                                            options:0
                                                           progress:nil
                                                          completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    [hud hideAnimated:YES];
                    if (image) {
                        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (status == PHAuthorizationStatusAuthorized) {
                                    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                                }
                                else {
                                    [MBProgressHUD finishHudWithResult:NO
                                                                   hud:hud
                                                             labelText:@"访问相册被拒绝"
                                                            completion:nil];
                                }
                            });
                        }];
                    }
                    else {
                        [MBProgressHUD finishHudWithResult:NO
                                                       hud:hud
                                                 labelText:YUCLOUD_STRING_FAILED
                                                completion:nil];
                    }
                }];
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - 保存到相册
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if (error){
//        DDLog(@"保存图片失败");
        
        [MBProgressHUD showFinishHudOn:[UIApplication sharedApplication].keyWindow
                            withResult:NO
                             labelText:@"保存图片失败"
                             delayHide:YES
                            completion:nil];
    }else{
//        DDLog(@"保存图片成功");
        
        [MBProgressHUD showFinishHudOn:[UIApplication sharedApplication].keyWindow
                            withResult:YES
                             labelText:@"保存图片成功"
                             delayHide:YES
                            completion:nil];
    }
}


@end
