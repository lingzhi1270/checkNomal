//
//  WebViewController.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/15.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "ModWebViewStyle1ViewController.h"
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>
#import <Photos/Photos.h>
// 各个功能模块
#import <ModApps/AppManager.h>
#import <ModLoginBase/AccountManager.h>
#import <LibUpload/SourceManager.h>
#import <LibUpload/UploadManager.h>
#import <ModCameraBase/CameraManager.h>
#import <ModContactBase/ContactManager.h>
#import <ModMenuBase/YCXMenu.h>
#import <ModLocationBase/LocationManager.h>
#import <ModNavigationBase/NavigationManager.h>
#import <ModPayBase/PayManager.h>
#import <ModShareBase/ShareManager.h>
#import <ModScanBase/ScanManager.h>
#import <ModPlayerBase/PlayerManager.h>
#import <ModTTSBase/TTSManager.h>
#import <ModRecordBase/RecordManager.h>


//#import "TFHpple.h"
//#import "SourceManager.h"

@interface NSDictionary (AppendVersion)
@end

@implementation NSDictionary (AppendVersion)

- (instancetype)dictionaryByAppendingVersion {
    NSMutableDictionary *dic = self.mutableCopy;
    [dic setObject:@{@"string" : @"1.0",
                     @"code" : @100}
            forKey:@"version"];
    
    return dic.copy;
}

@end

@interface ModWebViewStyle1ViewController () <WKUIDelegate, RecordManagerDelegate>
@property (nonatomic, strong)   WKWebViewJavascriptBridge   *bridge;

@property (nonatomic, strong)   NSMutableDictionary         *menuHistory;

@property (nonatomic, strong)   WVJBResponseCallback        recordCallBack;
@property (nonatomic, copy)     NSURL                       *firstImageUrl;
@property (nonatomic, strong)   AFSecurityPolicy            *securityPolicy;

@property (nonatomic, strong)   MBProgressHUD               *hud;
@property (nonatomic, strong)   UIButton                    *closeBtn;

@end

@implementation ModWebViewStyle1ViewController

+ (void)clearWKCache {
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    
    // Date from
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    
    // Execute
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes
                                               modifiedSince:dateFrom
                                           completionHandler:^{
                                           }];
}

- (instancetype)initWithUrl:(NSURL *)url {
    if (self = [super initWithTitle:@"" rightItem:nil]) {
        self.url = url;
    }
    
    return self;
}

- (instancetype)initWithHtmlString:(NSString *)htmlString
                             title:(NSString *)title
                           baseUrl:(NSURL *)baseUrl {
    if (self = [super initWithTitle:@"" rightItem:nil]) {
        self.htmlString = htmlString;
        self.baseUrl = baseUrl;
        if (title) {
            self.title = title;
            [self updateNaviBarWithTitle:title];
            
        }
    }
    
    return self;
}

- (instancetype)initWithUrl:(NSURL *)url withTitle:(NSString *)title {
    if (self = [super initWithTitle:title rightItem:nil]) {
        self.url = url;
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    if (self.isMainTab) {
        [self hiddenBackButton];
    }

    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, KTopViewHeight, SCREENWIDTH, SCREENHEIGHT-KTopViewHeight-KBottomSafeHeight-kTabbarHeight) configuration:[[WKWebViewConfiguration alloc] init]];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:self.webView];
    
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.hidden = YES;
    self.progressView.progressTintColor = [UIColor colorWithRGB:0x00B2FF];
    //进度条的宽度变为原来的1倍，高度变为原来的1.5倍.
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view addSubview:self.progressView];
    
    [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.safeArea);
        make.height.mas_offset(2);
    }];
        
    [self.view layoutIfNeeded];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [ModWebViewStyle1ViewController clearWKCache];
    
    [WKWebViewJavascriptBridge enableLogging];
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setWebViewDelegate:self];
    [self registerWebHandlers];
    [self loadRequest];
    
    [[AccountManager shareManager] addObserver:self
                                    forKeyPath:@"accountStatus"
                                       options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                       context:nil];
    
    [self.webView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    
    //添加KVO，监听WKWebView的estimatedProgress属性(当前网页加载的进度)
    [self.webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.isMainTab) {
        MainTabController *tabController = (MainTabController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [tabController showTabbarView];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"accountStatus"]) {
        if ([[AccountManager shareManager] isServerSignin]) {
//            [[HomeManager shareManager] requestAdminWithApp:self.appItem.uid
//                                            completion:^(BOOL success, NSDictionary * _Nullable info) {
//                                                if (success) {
//                                                    NSNumber *number = VALIDATE_NUMBER(info[@"admin"]);
//                                                    self.admin = [number boolValue];
//                                                }
//                                            }];
        }
        else {
//            self.admin = NO;
        }
    }else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        //不要让进度条倒着走...有时候goback会出现这种情况
        if ([change[@"new"] floatValue] < [change[@"old"] floatValue]) {
            return;
        }
        
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        if (self.progressView.progress == 1) {
            /*
             *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
             *动画时长0.25s，延时0.3s后开始动画
             *动画结束后将progressView隐藏
             */
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            }completion:^(BOOL finished) {
                self.progressView.hidden = YES;
            }];
        }
    }
    else if ([keyPath isEqualToString:@"frame"]) {
//        DDLog(@"网页frame：%@", self.webView.frame);
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)loadRequest {
    if (self.url) {
//        DDLog(@"%s url: %@", __PRETTY_FUNCTION__, self.url);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                             timeoutInterval:10];
        [self.webView loadRequest:request];
    }
}

- (void)configureCloseItem:(BOOL)show{
    if (show) {
        [self showBackButton];
        if (!self.isMainTab) {
            // 导航栏的关闭按钮
            if (!self.closeBtn) {
                self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                self.closeBtn.titleLabel.font = [UIFont systemFontOfSize:17];
                [self.closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
                [self.closeBtn setTitleColor:MAIN_NAVI_TITLE_COLOR forState:UIControlStateNormal];
                [self.closeBtn addTarget:self action:@selector(closeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                [self addLeftButton:self.closeBtn];
            }
            self.closeBtn.hidden = NO;
        }
    }
    else {
        [self hiddenBackButton];
        
        if (!self.isMainTab) {
            self.closeBtn.hidden = YES;
        }
    }
}

// 返回按钮点击
- (void)closeView {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
    else {
        [super closeView];
    }
}

// 关闭按钮点击
- (void)closeBtnPressed:(id)sender {
    [super closeView];
}

- (void)rightButtonAction {
    NSArray *menus = [self.menuHistory objectForKey:self.url];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
    
    for (NSDictionary *dict in menus) {
        // 创建items
    }
}

#pragma mark - 注册JavaScriptBridge
- (void)registerWebHandlers {
    // 1.获取登录信息
    [self registerGetLoginInfo];
    // 2.获取手机号码
    [self registerGetPhoneNumber];
    // 3.设置标题
    [self registerSetTitle];
    // 4.设置菜单
    [self registerSetMenu];
    // 5.获取图片
    [self registerAppGetImage];
    // 6.上传文件
    [self registerUploadFile];
    // 7.支付
    [self registerPay];
    // 8.退出应用
    [self registerExit];
    // 9.处理HUD
    [self registerProcessHud];
    // 10.打开新页面
    [self registerOpenWindow];
    // 11.获取定位
    [self registerGetLocation];
    // 12.开始导航
    [self registerStartNavigation];
    // 13.分享
    [self registerShareLink];
    // 14.二维码扫描
    [self registerScan];
    // 15.选择联系人
    [self registerSelectContacts];
    // 16.拨打电话
    [self registerCall];
    // 17.播放音视频
    [self registerPlayAudioOrVideo];
    // 18.调用前置或后置摄像头
    [self registerFrontOrBackCamera];
    // 19.开始录音
    [self registerStartVoiceRecord];
    // 20.结束录音
    [self registerFinishVoiceRecord];
    // 21.文字转语音
    [self registerTTS];
    
    [self.bridge registerHandler:@"AppIsAdmin"
                             handler:^(id data, WVJBResponseCallback responseCallback) {
    //                             responseCallback(@{@"admin" : [self isAdmin]?@1:@0});
                             }];
}

#pragma mark - 获取登录信息
- (void)registerGetLoginInfo {
    // 获取登录信息
    [self.bridge registerHandler:@"AppGetLoginInfo"
                         handler:^(id data, WVJBResponseCallback responseCallback) {
                             NSNumber *force = data[@"force_login"];
                             if ([force boolValue]) {
                                 [[AccountManager shareManager] validateLoginWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                                     if (success) {
                                         NSMutableDictionary *dic = [MainInterface sharedClient].headerData.mutableCopy;
                                         [dic setObject:[AccountManager shareManager].accountInfo.name?:@"" forKey:@"name"];
                                         [dic setObject:[AccountManager shareManager].accountInfo.union_id forKey:@"union_id"];
                                         
                                         responseCallback([dic.copy dictionaryByAppendingVersion]);
                                     }
                                     else {
                                         responseCallback([[MainInterface sharedClient].headerData dictionaryByAppendingVersion]);
                                     }
                                 }];
                             }
                             else {
                                 if ([[AccountManager shareManager] isServerSignin]) {
                                     NSMutableDictionary *dic = [MainInterface sharedClient].headerData.mutableCopy;
                                     [dic setObject:[AccountManager shareManager].accountInfo.name?:@"" forKey:@"name"];
                                     [dic setObject:[AccountManager shareManager].accountInfo.union_id forKey:@"union_id"];
                                     responseCallback([dic.copy dictionaryByAppendingVersion]);
                                 }
                                 else {
                                     responseCallback([[MainInterface sharedClient].headerData dictionaryByAppendingVersion]);
                                 }
                             }
                         }];
}

#pragma mark - 获取手机号码
- (void)registerGetPhoneNumber {
    // 获取手机号
    [self.bridge registerHandler:@"AppGetPhoneNumber"
                         handler:^(id data, WVJBResponseCallback responseCallback) {
                             NSNumber *force = data[@"force"];
                             NSString *phone = ACCOUNT_PHONE;
                             
                             if (phone.length == 0 && [force boolValue]) {
                                 [[AccountManager shareManager] validateLoginWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                                     if (success) {
                                         responseCallback(@{@"phone" : ACCOUNT_PHONE?:@""});
                                     }
                                     else {
                                         responseCallback(@{@"phone" : @""});
                                     }
                                 }];
                             }
                             else {
                                 responseCallback(@{@"phone" : phone?:@""});
                             }
                         }];
}

#pragma mark - 修改标题
- (void)registerSetTitle {
    // 修改标题
    [self.bridge registerHandler:@"AppSetTitle"
                         handler:^(NSDictionary *data, WVJBResponseCallback responseCallback) {
                             self.title = VALIDATE_STRING(data[@"title"]);
                             responseCallback(@"OK");
                         }];
}

#pragma mark - 设置菜单
- (void)registerSetMenu {
    // 设置右上角菜单
    [self.bridge registerHandler:@"AppSetMenu"
                         handler:^(id data, WVJBResponseCallback responseCallback) {
                             [self setMenuData:data forUrl:self.url];
                             [self webViewMenuShow:YES];
            
                             responseCallback(@"OK");
                         }];
}

#pragma mark - 获取图片或视频
- (void)registerAppGetImage {
    // 获取图片或视频
    [self.bridge registerHandler:@"AppGetImage"
                         handler:^(id data, WVJBResponseCallback responseCallback) {
                             // 图片或者视频个数，默认1个
                             NSNumber *limit = data[@"limit"];
                             if (!limit) {
                                 limit = @1;
                             }
                             // 文件大小，默认15M
                             NSNumber *size_limit = data[@"size_limit"];
                             if (!size_limit) {
                                 size_limit = @(1024 * 1024 * 15);
                             }
                             // 应用id
                             NSString *app_id = VALIDATE_STRING_WITH_DEFAULT(data[@"app_id"], @"");
                             // 图片压缩比例
                             NSNumber *jpeg_quality = VALIDATE_NUMBER_WITH_DEFAULT(data[@"jpeg_quality"], @.7);
                             // 是否需要裁减，默认不裁减
                             NSNumber *need_crop = VALIDATE_NUMBER_WITH_DEFAULT(data[@"need_crop"], @NO);
                             // 裁减宽高比，默认原图宽高比
                             NSNumber *ratio = VALIDATE_NUMBER_WITH_DEFAULT(data[@"ratio"], @1);

                             PHAssetMediaType mediaType = PHAssetMediaTypeImage;
                             // 媒体类型，默认图片
                             NSString *type = data[@"type"];
                             if ([type isEqualToString:@"video"]) {
                                 mediaType = PHAssetMediaTypeVideo;
                             }

                             __block NSString *appName;
                             if (app_id) {
                                 AppData *app =  [[AppManager shareManager] appWithUid:app_id];
                                 appName = app.name;

                                 NSString *key = [NSString stringWithFormat:@"%@/%@", appName?:@"h5", ACCOUNT_NAME];
                                 [[SourceManager shareManager] getSourcesWithLimit:[limit integerValue]
                                                                              type:mediaType
                                                                    viewController:self
                                                                              crop:need_crop
                                                                            upload:YES
                                                                         uploadKey:key
                                                                     uploadQuality:jpeg_quality?[jpeg_quality floatValue]:0
                                                                   fileLengthLimit:[size_limit unsignedIntegerValue]
                                                                    withCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                                                                        responseCallback(success?info:nil);
                                                                    }];
                             }
                             else {
                                 NSString *key = [NSString stringWithFormat:@"h5/%@", ACCOUNT_NAME];
                                 [[SourceManager shareManager] getSourcesWithLimit:[limit integerValue]
                                                                              type:mediaType
                                                                    viewController:self
                                                                              crop:need_crop
                                                                            upload:YES
                                                                         uploadKey:key
                                                                     uploadQuality:jpeg_quality?[jpeg_quality floatValue]:0
                                                                   fileLengthLimit:[size_limit unsignedIntegerValue]
                                                                    withCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                                                                        responseCallback(success?info:nil);
                                                                    }];
                             }
                         }];
}

#pragma mark - 上传文件
- (void)registerUploadFile {
    // 上传文件
    [self.bridge registerHandler:@"AppUploadFile"
                         handler:^(id data, WVJBResponseCallback responseCallback) {
                             // 上传地址
                             NSString *address = data[@"address"];
//                             [NSUserDefaults saveInternalAddress:address];
                             // 文件个数
                             NSNumber *limit = data[@"limit"];
                             // 文件类型，默认图片
                             PHAssetMediaType mediaType = PHAssetMediaTypeImage;
                             NSString *type = data[@"type"];
                             if ([type isEqualToString:@"video"]) {
                                 mediaType = PHAssetMediaTypeVideo;
                             }
                             // 用途，默认头像
                             NSString *usage = data[@"usage"];
                             if (!usage) {
                                 usage = @"avatar";
                             }

                             [[SourceManager shareManager] getSourcesWithLimit:[limit integerValue]
                                                                          type:mediaType
                                                                viewController:self
                                                                          crop:NO
                                                                        upload:NO
                                                                     uploadKey:nil
                                                                 uploadQuality:0
                                                               fileLengthLimit:1024 * 1024 * 14
                                                                withCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                                                                    responseCallback(success?info:nil);
                                                                }];
                         }];
}

#pragma mark - 支付
- (void)registerPay {
    // 支付
        [self.bridge registerHandler:@"AppPay"
                             handler:^(id data, WVJBResponseCallback responseCallback) {
                                 NSString *orderid = data[@"product_id"];
                                 NSString *subject = data[@"subject"];
                                 NSNumber *amount = data[@"amount"];
    //
    //                             CommonBlock block = ^(BOOL success, NSDictionary * _Nullable info) {
    //                                 responseCallback(@{@"success" : success?@1:@0});
    //                             };
    //
    //                             Class payClass = NSClassFromString(@"PayManager");
    //                             if (payClass && [payClass respondsToSelector:@selector(shareManager)]) {
    //                                 Class manager = [payClass performSelector:@selector(shareManager)];
    //                                 if (manager && [manager respondsToSelector:@selector(startPayWithOrder:amount:appid:product:subject:completion:)]) {
    //                                     [manager performSelectorWithArgs:@selector(startPayWithOrder:amount:appid:product:subject:completion:), orderid, amount, self.appItem.uid, nil, subject, block];
    //                                 }
    //                             }
                                 [[PayManager shareManager] startPayWithOrder:orderid
                                                                  amount:amount
                                                                   appid:self.appItem.uid
                                                                 product:nil
                                                                 subject:subject
                                                              completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                                  responseCallback(@{@"success" : success?@1:@0});
                                                              }];
                             }];
}

#pragma mark - 退出应用
- (void)registerExit {
    // 退出应用
    [self.bridge registerHandler:@"AppExit"
                         handler:^(id data, WVJBResponseCallback responseCallback) {
                             [self.navigationController popViewControllerAnimated:YES];
                             responseCallback(@"OK");
                         }];
}


#pragma mark - 处理HUD
- (void)registerProcessHud {
    // 展示Hud
    [self.bridge registerHandler:@"AppProcessHud"
                         handler:^(id data, WVJBResponseCallback responseCallback) {
                             MBProgressHUDMode mode = MBProgressHUDModeIndeterminate;
                             UIImage *image;
                             NSString *text = data[@"text"];
                             NSNumber *delay_hide = data[@"delay_hide"];
                             NSString *action = data[@"action"];
                             
                             if (!delay_hide) {
                                 delay_hide = @YES;
                             }
                             
                             NSString *string = data[@"mode"];
                             if ([string isEqualToString:@"text"]) {
                                 mode = MBProgressHUDModeText;
                             }
                             else if ([string isEqualToString:@"loading"]) {
                                 delay_hide = @0;
                                 mode = MBProgressHUDModeIndeterminate;
                             }
                             else if ([string isEqualToString:@"success"]) {
                                 mode = MBProgressHUDModeCustomView;
                                 image = [UIImage bundleImageNamed:@"ic_hud_success"];
                             }
                             else if ([string isEqualToString:@"failed"]) {
                                 mode = MBProgressHUDModeCustomView;
                                 image = [UIImage bundleImageNamed:@"ic_hud_fail"];
                             }
                             
                             if ([action isEqualToString:@"show"]) {
                                 self.hud = [MBProgressHUD showHudOn:[UIApplication sharedApplication].keyWindow
                                                                mode:mode
                                                               image:image
                                                             message:text
                                                           delayHide:[delay_hide boolValue]
                                                          completion:^{
                                                              responseCallback(@"OK");
                                                          }];
                             }
                             else if ([action isEqualToString:@"change"]) {
                                 self.hud.mode = mode;
                                 if (image) {
                                     [self.hud setCustomView:[[UIImageView alloc] initWithImage:image]];
                                 }
                                 else {
                                     [self.hud setCustomView:nil];
                                 }
                                 self.hud.detailsLabel.text = text;
                                 if ([delay_hide boolValue]) {
                                     [self.hud hideAnimated:YES afterDelay:PROGRESS_DELAY_HIDE];
                                 }
                                 self.hud.completionBlock = ^{
                                     responseCallback(@"OK");
                                 };
                             }
                             else if ([action isEqualToString:@"hide"]) {
                                 self.hud.completionBlock = ^{
                                     responseCallback(@"OK");
                                 };
                                 
                                 [self.hud hideAnimated:YES];
                             }
                         }];
}

#pragma mark - 打开新页面
- (void)registerOpenWindow {
    // 打开新页面
    [self.bridge registerHandler:@"AppOpenWindow"
                         handler:^(id data, WVJBResponseCallback responseCallback) {
                             NSString *url = VALIDATE_STRING(data[@"url"]);
                             self.url = [NSURL URLWithString:url];
                             [self loadRequest];
                         }];
}

#pragma mark - 获取定位信息
- (void)registerGetLocation {
    // 获取定位信息
    [self.bridge registerHandler:@"AppGetLocation" handler:^(id data, WVJBResponseCallback responseCallback) {
        __block MBProgressHUD *hud = [MBProgressHUD showHudOn:[UIApplication sharedApplication].keyWindow
                                                         mode:MBProgressHUDModeIndeterminate
                                                        image:nil
                                                      message:@"定位中..."
                                                    delayHide:NO
                                                   completion:nil];
        
        [[LocationManager shareManager] getLocationInfoWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
            [hud hideAnimated:YES];
            
            if (success) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                if ([LocationManager shareManager].location) {
                    [dic setObject:@([LocationManager shareManager].location.coordinate.latitude) forKey:@"latitude"];
                    [dic setObject:@([LocationManager shareManager].location.coordinate.longitude) forKey:@"longitude"];
                }
                
                if ([LocationManager shareManager].formattedAddress) {
                    [dic setObject:[LocationManager shareManager].formattedAddress forKey:@"address"];
                }
                
                responseCallback(dic.copy);
                
                hud = [MBProgressHUD showHudOn:[UIApplication sharedApplication].keyWindow
                                          mode:MBProgressHUDModeText
                                         image:nil
                                       message:[LocationManager shareManager].formattedAddress
                                     delayHide:YES
                                    completion:nil];
            }
            else {
                hud = [MBProgressHUD showFinishHudOn:[UIApplication sharedApplication].keyWindow
                                          withResult:NO labelText:info[@"error"]
                                           delayHide:YES
                                          completion:nil];
            }
        }];
    }];
}

#pragma mark - 开始导航
- (void)registerStartNavigation {
    // 分享
    [self.bridge registerHandler:@"AppStartNavigation"
                         handler:^(NSDictionary *data, WVJBResponseCallback responseCallback) {
        NSString *startAddress = VALIDATE_STRING(data[@"startAddress"]);
        double startLng = [VALIDATE_NUMBER(data[@"startLng"]) doubleValue];
        double startLat = [VALIDATE_NUMBER(data[@"startLat"]) doubleValue];
        NSString *endAddress = VALIDATE_STRING(data[@"endAddress"]);
        double endLng = [VALIDATE_NUMBER(data[@"endLng"]) doubleValue];
        double endLat = [VALIDATE_NUMBER(data[@"endLat"]) doubleValue];
        
        CGPoint startPoint = CGPointMake(startLng, startLat);
        CGPoint endPoint = CGPointMake(endLng, endLat);
        NSString *startPointString = NSStringFromCGPoint(startPoint);
        NSString *endPointString = NSStringFromCGPoint(endPoint);
        
        [[NavigationManager shareManager] showNavigationControllerWithStartPoint:startPointString
                                                                        endPoint:endPointString];
    }];
}

#pragma mark - 分享
- (void)registerShareLink {
    // 分享
    [self.bridge registerHandler:@"AppShareLink"
                         handler:^(NSDictionary *data, WVJBResponseCallback responseCallback) {
                            NSString *title = VALIDATE_STRING(data[@"title"]);
                            NSString *text = VALIDATE_STRING(data[@"overview"]);
                            NSString *url = VALIDATE_STRING(data[@"url"]);
                            NSString *type = VALIDATE_STRING_WITH_DEFAULT(data[@"type"], @"url");

                            NSURL *imageUrl, *videoUrl;

                            NSString *string = VALIDATE_STRING(data[@"image_url"]);
                            if (string && ![string containsString:@"%"]) {
                                string = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            }
                            if (string) {
                                imageUrl = [NSURL URLWithString:string];
                            }

                            string = VALIDATE_STRING(data[@"video_url"]);
                            if (string && ![string containsString:@"%"]) {
                                string = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            }
                            if (string) {
                                videoUrl = [NSURL URLWithString:string];
                            }

                            NSMutableArray *arr = [NSMutableArray array];
                            if (imageUrl) {
                                [arr addObject:@(ShareSaveImage)];
                            }
                            else if (videoUrl) {
                                [arr addObject:@(ShareSaveImage)];
                            }

                            [arr addObject:@(ShareCopyURL)];
        
                            ShareObject *object = [ShareObject urlObjectWithTitle:@"测试标题"
                                                                             text:@"测试内容"
                                                                        urlString:@"https://www.baidu.com/"
                                                                         imageURL:@"https://www.baidu.com/img/baidu_resultlogo@2.png"];
        
                            [[ShareManager shareManager] shareWithView:self.view
                                                                object:object
                                                          extraTargets:arr];
    }];
}

#pragma mark - 二维码扫描
- (void)registerScan {
    // 二维码扫描
    [self.bridge registerHandler:@"AppScan" handler:^(id data, WVJBResponseCallback responseCallback) {
        [[ScanManager shareManager] startCodeScanWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
            responseCallback(@{@"data" : success?info[@"result"]:@""});
        }];
    //        Class scanClass = NSClassFromString(@"ScanManager");
    //        if (scanClass && [scanClass respondsToSelector:@selector(shareManager)]) {
    //            id scanManager = [scanClass performSelector:@selector(shareManager)];
    //            if (scanManager && [scanManager respondsToSelector:@selector(startCodeScanWithCompletion:)]) {
    //                CommonBlock completion = ^(BOOL success, NSDictionary * _Nullable info) {
    //                    responseCallback(@{@"data" : success?info[@"result"]:@""});
    //                };
    //
    //                [scanManager performSelectorWithArgs:@selector(startCodeScanWithCompletion:), completion];
    //            }
    //        }
    }];
}

#pragma mark - 选择联系人
- (void)registerSelectContacts {
    // 选择联系人
    [self.bridge registerHandler:@"AppSelectContacts"
                         handler:^(NSDictionary *data, WVJBResponseCallback responseCallback) {
                            NSString *type = VALIDATE_STRING_WITH_DEFAULT(data[@"type"], @"app");
                            NSNumber *limit = VALIDATE_NUMBER_WITH_DEFAULT(data[@"limit"], @1);
        
                            [[ContactManager shareManager] startContactSelectWithType:type
                                                                                limit:limit
                                                                           completion: ^(BOOL success, NSDictionary * _Nullable info) {
                                                                                responseCallback(info);
                                                                            }];
    }];
}

#pragma mark - 拨打电话
- (void)registerCall {
    [self.bridge registerHandler:@"AppCall"
                         handler:^(NSDictionary *data, WVJBResponseCallback responseCallback) {
                            NSString *name = VALIDATE_STRING(data[@"name"]);
                            NSString *phone = VALIDATE_STRING(data[@"phone"]);
                            
                            if (phone.length) {
                                NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"telprompt://%@", phone];
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:nil];
                            }
    }];
    
}

#pragma mark - 播放音视频
- (void)registerPlayAudioOrVideo {
    // 播放
    [self.bridge registerHandler:@"AppPlayAudioOrVideo"
                         handler:^(NSDictionary *data, WVJBResponseCallback responseCallback) {
                            NSString *title = VALIDATE_STRING(data[@"title"]);
                            NSString *type = VALIDATE_STRING(data[@"type"]);
                            NSString *url = VALIDATE_STRING(data[@"url"]);

                            if (![url containsString:@"%"]) {
                                url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            }
                            
                            [[PlayerManager shareManager] playVideoWithUrl:url title:title];
                         }];
}

#pragma mark - 调用前置&后置摄像头
- (void)registerFrontOrBackCamera {
    // 播放
    [self.bridge registerHandler:@"AppFrontOrBackCamera"
                         handler:^(NSDictionary *data, WVJBResponseCallback responseCallback) {
                            NSString *cameraType = VALIDATE_STRING(data[@"cameraType"]);
                            NSString *sourceType = VALIDATE_STRING(data[@"sourceType"]);
                            NSString *flashType = VALIDATE_STRING(data[@"flashType"]);
                            NSString *videoDuration = VALIDATE_STRING(data[@"videoDuration"]);
        
                            CameraType type = CameraTypeDefault;
                            if ([cameraType isEqualToString:@"back"]) {
                                type = CameraTypeBack;
                            }
                            else {
                                type = CameraTypeFront;
                            }
                                     
                            [[CameraManager shareManager] startCameraWithCameraType:type viewController:self];
                         }];
}

#pragma mark - 开始录音
- (void)registerStartVoiceRecord {
    // 开始录音
    [self.bridge registerHandler:@"AppStartVoiceRecord"
                         handler:^(id data, WVJBResponseCallback responseCallback) {
                            self.recordCallBack = responseCallback;

                            [RecordManager shareManager].delegate = self;
                            [[RecordManager shareManager] startVoiceRecord];
                            responseCallback(@"OK");
                         }];
}
    
#pragma mark - 结束录音
- (void)registerFinishVoiceRecord {
    // 结束录音
    [self.bridge registerHandler:@"AppFinishVoiceRecord"
                         handler:^(id data, WVJBResponseCallback responseCallback) {
                             [[RecordManager shareManager] finishVoiceRecord];
                         }];
}

#pragma mark - TTS
- (void)registerTTS {
    [self.bridge registerHandler:@"AppTextToSpeech"
                         handler:^(id data, WVJBResponseCallback responseCallback) {
                            NSString *title = VALIDATE_STRING(data[@"title"]);
                            NSString *content = VALIDATE_STRING(data[@"content"]);
                            
                            [[TTSManager shareManager] speakWithTitle:title content:content];
    }];
}

- (void)setMenuData:(NSArray *)menuData forUrl:(NSURL *)url {
    if (!self.menuHistory) {
        self.menuHistory = [NSMutableDictionary new];
    }
    
    // 此处记忆菜单，页面返回时需要展示
    [self.menuHistory setObject:menuData?:@[] forKey:self.url];
}

- (void)webViewMenuShow:(BOOL)show {
    NSArray *menuData = [self.menuHistory objectForKey:self.url];
    if (menuData.count == 1) {
        NSMutableDictionary *dic = menuData.firstObject;
        UIImage *image;
        NSString *image_url = VALIDATE_STRING(dic[@"image_url"]);
        if (image_url.length) {
            NSString *path = [[SDImageCache sharedImageCache] cachePathForKey:image_url];
            NSData *data = [NSData dataWithContentsOfFile:path];
            image = [UIImage imageWithData:data scale:2];
        }
        
        NSString *title = VALIDATE_STRING(dic[@"title"]);
        NSNumber *badge = VALIDATE_NUMBER(dic[@"badge"]);
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton addTarget:self action:@selector(touchWebViewMenu) forControlEvents:UIControlEventTouchUpInside];
        if (image) {
            [rightButton setImage:image forState:UIControlStateNormal];
        }
        else if (title.length) {
            [rightButton setTitle:title forState:UIControlStateNormal];
        }
        
        [rightButton setImage:[[UIImage imageNamed:@"ic_app_menu" bundleName:@"LibComponentBase"] imageMaskedWithColor:MAIN_NAVI_TITLE_COLOR]
                     forState:UIControlStateNormal];
        
        [self addRightButton:rightButton];
    }
    else if (menuData.count > 1) {
        NSInteger badge = 0;
        for (NSDictionary *item in menuData) {
            NSNumber *number = VALIDATE_NUMBER(item[@"badge"]);
            if ([number integerValue] > 0) {
                badge++;
            }
        }
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setImage:[[UIImage imageNamed:@"ic_app_menu" bundleName:@"LibComponentBase"] imageMaskedWithColor:MAIN_NAVI_TITLE_COLOR] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(touchWebViewMenu) forControlEvents:UIControlEventTouchUpInside];
        
        [self addRightButton:rightButton];
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.url = webView.URL;
    
//    DDLog(@"开始加载网页 url=%@", webView.URL.absoluteString);
    //开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self webViewDidFinishedLoading:webView];
    
    self.url = webView.URL;
    
    [self webViewMenuShow:YES];
    
//    DDLog(@"加载完成");
    if (webView.canGoBack) {
        [self configureCloseItem:YES];
    }
    else {
        [self configureCloseItem:NO];
    }
    
    //加载完成后隐藏progressView
    self.progressView.hidden = YES;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
//    DDLog(@"didFailProvisionalNavigation error: %@", error);
    
    [self webViewLoadFailed];
    
    //加载失败同样需要隐藏progressView
    self.progressView.hidden = YES;
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    
}
// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void)webViewDidFinishedLoading:(WKWebView *)webView {
    if (!self.isMainTab) {
        if (self.url && webView.title.length) {
            [self webViewSetTitle:webView.title];
        }
    }
    
    [self.webView evaluateJavaScript:@"document.body.innerHTML"
                   completionHandler:^(NSString *string, NSError * _Nullable error) {
                       if (string.length) {
//                           TFHpple *doc = [[TFHpple alloc] initWithHTMLData:[string dataUsingEncoding:NSUTF8StringEncoding]];
//                           TFHppleElement *element = [doc searchWithXPathQuery:@"//img"].firstObject;
//                           NSString *src = element[@"src"];
//                           self.firstImageUrl = [NSURL URLWithString:src];
                           
                           self.firstImageUrl = [self getHtmlImageUrl:string];
                       }
                   }];
    
}

- (NSString *)getHtmlImageUrl:(NSString *)string {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<img[^>]* src[^>]*/>"
                                                                           options:NSRegularExpressionAllowCommentsAndWhitespace
                                                                             error:nil];

    NSArray *result = [regex matchesInString:string
                                     options:NSMatchingReportCompletion
                                       range:NSMakeRange(0, string.length)];

    for (NSTextCheckingResult *item in result) {
        NSString *imgHtml = [string substringWithRange:[item rangeAtIndex:0]];

        if ([imgHtml rangeOfString:@"src="].location != NSNotFound) {

            NSRange rangeSrc = [imgHtml rangeOfString:@"src="];

            NSRange rangeJpg = [imgHtml rangeOfString:@".jpg"];

            if ((rangeJpg.location - rangeSrc.location - @"src=".length + @".jpg".length-1) <= imgHtml.length){

                NSString *str = [imgHtml substringWithRange:(NSMakeRange(rangeSrc.location+@"src=".length+1, rangeJpg.location- rangeSrc.location-@"src=".length+@".jpg".length-1))];

                NSLog(@"正确解析出来的SRC为：%@", str);
                
                return str;
            }
        }
    }
    
    return @"";
}

- (void)webViewSetTitle:(NSString *)title {
    if (![self.title isEqualToString:title]) {
        self.title = title;
        [self updateNaviBarWithTitle:title];
    }
}

- (void)webViewLoadFailed {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"common_error" withExtension:@"html"];
    if (url) {
        [self.webView loadFileURL:url allowingReadAccessToURL:url];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            if (credential) {
                disposition = NSURLSessionAuthChallengeUseCredential;
            }
            else {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
        }
        else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    }
    else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
    
    [self webViewDidFinishedLoading:webView];
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)touchWebViewMenu {
    Class class = NSClassFromString(@"FavManager");
    if (class) {
        SEL shareManagerSelector = NSSelectorFromString(@"shareManager");
        if ([class respondsToSelector:shareManagerSelector]) {
            id manager = [class performSelector:shareManagerSelector];
            if (manager) {
                SEL favWithContentSelector = NSSelectorFromString(@"favWithContent:");
                if ([manager respondsToSelector:favWithContentSelector]) {
                    Class objectClass = [manager performSelector:favWithContentSelector withObject:self.url.absoluteString];
                    Class favClass = NSClassFromString(@"FavData");
                    if (objectClass && [favClass isKindOfClass:[favClass class]]) {
                        SEL uidSelector = NSSelectorFromString(@"uid");
                        if ([objectClass respondsToSelector:uidSelector]) {
                            NSInteger favouriteid = (NSInteger)[objectClass performSelector:uidSelector];
                            ShareObject *object = [ShareObject urlObjectWithTitle:self.title
                                                                             text:nil
                                                                        urlString:self.url.absoluteString
                                                                         imageURL:self.firstImageUrl];
                            
                            NSString *action;
                            if (favouriteid > 0) {
                                action = @"取消收藏";
                            }
                            else {
                                action = @"收藏";
                            }
                            
                            ShareTarget *fav = [ShareTarget targetWithImage:[UIImage imageNamed:@"icon_share_favourite"]
                                                                      title:action
                                                                   activity:ShareFavourite];
                            
                            ShareTarget *copyURL = [ShareTarget targetWithImage:[UIImage imageNamed:@"share_copy_icon"]
                                                                          title:@"复制链接"
                                                                       activity:ShareCopyURL];
                            
                            
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - RecordManagerDelegate
- (void)recordFinish:(NSData *)audioData {
    if (self.recordCallBack) {
        NSString *key = [NSString stringWithFormat:@"H5/%@", [[audioData MD5] substringToIndex:6]];
        
        [[UploadManager shareManager] uploadData:audioData
                                             key:key
                                         fileExt:@"aac"
                                        progress:nil
                                      completion:^(BOOL success, NSDictionary * _Nullable info) {
                                        self.recordCallBack(info);
                                        self.recordCallBack = nil;
        }];
    }
}

// 录音失败
- (void)recordFailed:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"录音失败 %@", error.domain];
    
    [MBProgressHUD showFinishHudOn:[UIApplication sharedApplication].keyWindow
                        withResult:NO
                         labelText:message
                         delayHide:YES
                        completion:nil];
    
    if (self.recordCallBack) {
        self.recordCallBack(nil);
        self.recordCallBack = nil;
    }
}

#pragma mark - WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

@end
