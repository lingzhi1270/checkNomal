//
//  ViewController.m
//  ModuleDemo
//
//  Created by 唐琦 on 2020/1/3.
//  Copyright © 2020 唐琦. All rights reserved.
//

#import "ViewController.h"
#import "LocationManager.h"
#import "SourceManager.h"
#import "ModCameraStyle1ViewController.h"
//#import "ModPhotoCollectionStyle1ViewController.h"
//#import "WebViewController.h"

#import <LibDataModel/AppData.h>
#import <ModScanBase/ScanManager.h>
#import <ModContactBase/ContactManager.h>
#import <ModShareBase/ShareManager.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) NSInteger titleIndex;
@property (nonatomic, strong) NSArray *textArray;

@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    
    [self hiddenBackButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titleIndex = 0;
    
    self.textArray = @[@"1、获取登录信息",
                       @"2、设置页面标题",
                       @"3、设置页面菜单",
                       @"4、获取手机号码",
                       @"5、获取图片或视频",
                       @"6、退出应用",
                       @"7、处理Hud",
                       @"8、打开新页面",
                       @"9、获取定位信息",
                       @"10、开启导航",
                       @"11、开始录音",
                       @"12、结束录音",
                       @"12、支付",
                       @"14、文件上传",
                       @"15、分享",
                       @"16、评论",
                       @"17、点赞",
                       @"18、扫一扫",
                       @"19、选择联系人",
                       @"20、拨打电话",
                       @"21、播放音频或视频",
                       @"22、调用前置或后置摄像头",
                       @"23、人像采集",
                       @"24、人脸识别",
                       @"24、文字转语音"];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(KTopViewHeight);
        make.left.right.bottom.equalTo(self.view);
    }];
    
//    for (int i = 0; i < self.textArray.count; i++) {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.tag = i;
//        [button setTitle:self.textArray[i] forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor colorWithRGB:0x00b2ff] forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:button];
//        [button sizeToFit];
//
//        [button mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.view).offset(KTopViewHeight+20+(15+44)*i);
//            make.left.equalTo(self.view).offset(30);
//            make.width.equalTo(@(button.frame.size.width+8));
//        }];
//    }
}

- (void)rightButtonAction {
    //     *meVC = [[ModUserCenterStyle1ViewController alloc] initWithTitle:@"我的" rightItem:nil];

    Class userCenterClass = NSClassFromString(@"ModUserCenterStyle1ViewController");
    if (userCenterClass) {
        UIViewController *userCenterVC = [[userCenterClass alloc] init];
        [self.navigationController pushViewController:userCenterVC animated:YES];
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.textArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UITableViewCell reuseIdentifier]];
    }
    
    cell.textLabel.text = self.textArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case ActionTypeLoginInfo:
            [[AccountManager shareManager] validateLoginWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                if (success) {
                    NSString *message = [NSString stringWithFormat:@"UserId：%@\nToken：%@\n手机：%@", ACCOUNT_USERID, ACCOUNT_TOKEN, ACCOUNT_PHONE];
                    DDLog(@"%@",message);
                    [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                        mode:MBProgressHUDModeText
                                       image:nil
                                     message:message
                                   delayHide:YES
                                  completion:nil];
                }
            }];
            
            break;
            
        case ActionTypeSetTitle:
            self.titleIndex++;
            [self updateNaviBarWithTitle:[NSString stringWithFormat:@"修改页面标题%ld", self.titleIndex]] ;
            break;
            
        case ActionTypeSetMenu:
            
            break;
            
        case ActionTypeGetPhoneNumber:
            [[AccountManager shareManager] validateLoginWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                if (success) {
                    NSString *message = [NSString stringWithFormat:@"手机号：%@", ACCOUNT_PHONE];
                    [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                        mode:MBProgressHUDModeText
                                       image:nil
                                     message:message
                                   delayHide:YES
                                  completion:nil];
                }
            }];
            break;
            
        case ActionTypeGetPhotoOrVideo: {
//            [[UniManager shareManager] selectImageWithLimit:9
//                                                       type:PHAssetMediaTypeImage
//                                             viewController:self
//                                                     upload:NO
//                                                  uploadKey:nil
//                                              uploadQuality:0.0
//                                            fileLengthLimit:15
//                                             withCompletion:^(BOOL success, NSDictionary * _Nullable info) {
//                                                 if (success) {
//
//                                                 }
//                                             }];
            
//            if (app_id) {
//                AppData *app = [[AppManager shareManager] appWithUid:app_id];
//                appName = app.name;
//            }
            NSString *appName;
            NSString *key = [NSString stringWithFormat:@"%@/%@", appName?:@"h5", [AccountManager shareManager].accountInfo.name];
            [[SourceManager shareManager] getSourcesWithLimit:9
                                                         type:PHAssetMediaTypeImage
                                               viewController:self
                                                         crop:YES
                                                       upload:YES
                                                    uploadKey:key
                                                uploadQuality:0.7
                                              fileLengthLimit:15
                                               withCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                                                   if (success) {
                                                       
                                                   }
                                               }];
        }
            break;
            
        case ActionTypeExit:
            [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                mode:MBProgressHUDModeText
                               image:nil
                             message:@"正在退出应用..."
                           delayHide:YES
                          completion:^{
                              exit(0);
                          }];
            
            break;
            
        case ActionTypeHud:
            
            break;
            
        case ActionTypeOpenNewWindow:
            
            break;
            
        case ActionTypeGetLocation: {
            __block MBProgressHUD *hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                                             mode:MBProgressHUDModeIndeterminate
                                                            image:nil
                                                          message:@"定位中..."
                                                        delayHide:NO
                                                       completion:nil];
            
            Class locationClass = NSClassFromString(@"LocationManager");
            if (locationClass) {
                if ([locationClass respondsToSelector:@selector(shareManager)]) {
                    id locationManager = [locationClass performSelector:@selector(shareManager)];
                    if (locationManager) {
                        if ([locationManager respondsToSelector:@selector(getLocationInfoWithCompletion:)]) {
                            CommonBlock completion = ^(BOOL success, NSDictionary * _Nullable info) {
                                dispatch_async_on_main_queue(^{
                                    [hud hideAnimated:YES];
                                    if (success) {
                                        if ([locationManager respondsToSelector:@selector(getFormattedAddress)]) {
                                            NSString *formattedAddress = [locationManager performSelector:@selector(getFormattedAddress)];
                                            
                                            hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                                                      mode:MBProgressHUDModeText
                                                                     image:nil
                                                                   message:formattedAddress
                                                                 delayHide:YES
                                                                completion:nil];
                                        }
                                        
                                        
                                    }
                                    else {
                                        hud = [MBProgressHUD showFinishHudOn:APP_DELEGATE_WINDOW
                                                                  withResult:NO labelText:info[@"error"]
                                                                   delayHide:YES
                                                                  completion:nil];
                                    }
                                });
                            };
                            
                            [locationManager performSelector:@selector(getLocationInfoWithCompletion:) withObject:completion];
                        }
                    }
                }
            }
            
//            [[LocationManager shareManager] getLocationInfoWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
//                dispatch_async_on_main_queue(^{
//                    [hud hideAnimated:YES];
//                    if (success) {
//                        hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
//                                                  mode:MBProgressHUDModeText
//                                                 image:nil
//                                               message:[LocationManager shareManager].formattedAddress
//                                             delayHide:YES
//                                            completion:nil];
//                    }
//                    else {
//                        hud = [MBProgressHUD showFinishHudOn:APP_DELEGATE_WINDOW
//                                                  withResult:NO labelText:info[@"error"]
//                                                   delayHide:YES
//                                                  completion:nil];
//                    }
//                });
//            }];
        }
            break;
            
        case ActionTypeStartNavgator: {
            Class locationClass = NSClassFromString(@"LocationViewController");
            if (locationClass) {
                UIViewController *locationVC = [[locationClass alloc] initWithTitle:@"选择目的地" rightItem:nil];
                [self presentViewController:locationVC animated:YES completion:nil];
                
                if ([locationVC respondsToSelector:@selector(setBlock:)]) {
                    typedef void(^locationBlock)(NSString *name, NSString *address, NSString *location);
                    locationBlock block = ^(NSString *name, NSString *address, NSString *location) {
                        Class naviClass = NSClassFromString(@"ModNavigationStyle1ViewController");
                        if (naviClass) {
                            UIViewController *naviVC = [[naviClass alloc] initWithTitle:@"导航界面" rightItem:nil];
                            [self.navigationController pushViewController:naviVC animated:YES];
                            
                            [naviVC performSelector:@selector(startNaviRoutePlanWithEndPoint:) withObject:location];
                        }
                    };
                    
                    [locationVC performSelector:@selector(setBlock:) withObject:block];
                }
            }
        }
            
            break;
            
        case ActionTypeStartRecord: {
            [[AccountManager shareManager] validateLoginWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                if (success) {
                    Class recordClass = NSClassFromString(@"RecordManager");
                    if (recordClass && [recordClass respondsToSelector:@selector(shareManager)]) {
                        id manager = [recordClass performSelector:@selector(shareManager)];
                        if (manager) {
                            [manager setValue:self forKey:@"delegate"];
                            if ([manager respondsToSelector:@selector(startVoiceRecord)]) {
                                [manager performSelector:@selector(startVoiceRecord)];
                            }
                        }
                    }
                }
            }];
        }
            break;
            
        case ActionTypeStopRecord: {
            [[AccountManager shareManager] validateLoginWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                if (success) {
                    Class recordClass = NSClassFromString(@"RecordManager");
                    if (recordClass && [recordClass respondsToSelector:@selector(shareManager)]) {
                        id manager = [recordClass performSelector:@selector(shareManager)];
                        if (manager) {
                            // 结束录音
                            if ([manager respondsToSelector:@selector(finishVoiceRecord)]) {
                                [manager performSelector:@selector(finishVoiceRecord)];
                            }
                        }
                    }
                }
            }];
        }
            break;
            
        case ActionTypePay: {
            CommonBlock block = ^(BOOL success, NSDictionary * _Nullable info) {
                DDLog(@"");
            };
            
            Class payClass = NSClassFromString(@"PayManager");
            if (payClass && [payClass respondsToSelector:@selector(shareManager)]) {
                Class manager = [payClass performSelector:@selector(shareManager)];
                if (manager && [manager respondsToSelector:@selector(startPayWithOrder:amount:appid:product:subject:completion:)]) {
                    [manager performSelectorWithArgs:@selector(startPayWithOrder:amount:appid:product:subject:completion:), @"orderid", @"amount", @"self.appItem.uid", nil, @"subject", block];
                }
            }
        }
            break;
            
        case ActionTypeUploadFile:
            
            break;
            
        case ActionTypeShare:
            [[AccountManager shareManager] validateLoginWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                if (success) {
                    NSURL *url = [NSURL URLWithString:@"http://oss-cn-shanghai.aliyuncs.com/viroyalcampus/home_theme/screen/819b7a4c598dab5f864e5fdad6c006e3.png"];
                    ShareObject *object = [ShareObject urlObjectWithTitle:@"测试分享标题"
                                                                     text:@"测试分享内容"
                                                                urlString:@"https://www.baidu.com"
                                                                 imageURL:url];

                    [[ShareManager shareManager] shareWithView:[UIApplication sharedApplication].keyWindow
                                                        object:object
                                                  extraTargets:@[@(ShareSaveImage), @(ShareSaveImage), @(ShareCopyURL)]];
                }
            }];
            break;
            
        case ActionTypeComment: {
            Class class = NSClassFromString(@"ModCommentStyle1CommentView");
            if (class) {
                UIView *commentView = [[class alloc] init];
                [commentView setValue:@YES forKey:@"isReply"];
                [APP_DELEGATE_WINDOW addSubview:commentView];
                
                [commentView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(APP_DELEGATE_WINDOW);
                }];
                
                [commentView performSelector:@selector(showView)];
            }
        }
            break;
            
        case ActionTypePraise:
            
            break;
            
        case ActionTypeScan:
            [[ScanManager shareManager] startCodeScanWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
                if (success) {
                    NSString *result = info[@"result"];
                    DDLog(@"%@", result);
                }
            }];
            
            break;
            
        case ActionTypeSelectContacts:
            [[ContactManager shareManager] startContactSelectWithType:@"phone" limit:nil completion:^(BOOL success, NSDictionary * _Nullable info) {
                if (success) {
                    NSArray *array = info[@"contacts"];
                    if (array.count) {
                        NSDictionary *dic = array.firstObject;
                        NSString *phone = dic[@"phone"];
                        NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"telprompt://%@", phone];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                        
                        DDLog(@"%@", dic);
                    }
                }
            }];
            
            break;
            
        case ActionTypeCall: {
            NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"telprompt://%@",@"18012345678"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:nil];
        }
            break;
            
        case ActionTypePlayPhotoOrVideo:
            
            break;
            
        case ActionTypeCamera:
            [self useCamera];
            break;
            
        case ActionTypeAvatarCollection: {
//            [[UniManager shareManager] validateLoginWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
//                if (success) {
//                    NSDictionary *data = @{@"api_version" : @"",
//                                           @"cache_url" : @"",
//                                           @"category_id" : @56,
//                                           @"home_url" : @"",
//                                           @"icon_url" : @"http://oss-cn-shanghai.aliyuncs.com/viroyalcampus/apps/f81829ab216d156049d61839bd38ee1a.png",
//                                           @"name" : @"{\"en-us\":\"camera\",\"zh-Hans\":\"照片采集\"}",
//                                           @"qr_key" : @"",
//                                           @"type" : @"native",
//                                           @"uid" : @"avatar",
//                                           @"user_groups" : @0,
//                                           @"version" : @"",
//                                           @"version_code" : @""};
//                    [AppData itemWithData:data completion:^(BOOL success, NSDictionary * _Nullable info) {
//                        AppData *item = info[@"data"];
//
//                        dispatch_async_on_main_queue(^{
//                            ModPhotoCollectionStyle1ViewController *camera = [[ModPhotoCollectionStyle1ViewController alloc] initWithApp:item];
//                            [[UniManager shareManager].topNavigationController pushViewController:camera animated:YES];
//                        });
//                    }];
//                }
//            }];
        }
            break;
            
            
        case ActionTypeFaceRecognition: {
           
        }
            
            break;
            
        case ActionTypeTextToSpeech:
        {
            
        }
            break;
        default:
            break;
    }
}

- (void)useCamera {
    
}

#pragma mark - RecordManagerDelegate
- (void)recordFinish:(NSData *)audioData {
    __block MBProgressHUD *hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                                                     mode:MBProgressHUDModeAnnularDeterminate
                                                    image:nil
                                                  message:@"录音上传中..."
                                                delayHide:NO
                                               completion:nil];
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    NSString *string = [formatter stringFromDate:[NSDate date]];
    // 文件名
    NSString *key = [NSString stringWithFormat:@"%@/%@", string, [[audioData MD5] substringToIndex:6]];
    // 上传进度block
    typedef  void (^ProgressBlock)(NSUInteger completedBytes, NSInteger totalBytes);
    ProgressBlock progress = ^(NSUInteger completedBytes, NSInteger totalBytes){
        dispatch_async_on_main_queue(^{
            hud.progress = completedBytes / (float)totalBytes;
        });
    };
    // 完成回调block
    CommonBlock completion = ^(BOOL success, NSDictionary *info) {
        dispatch_async_on_main_queue(^{
            [hud hideAnimated:YES];
            NSString *url = info[@"url"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"播放音频" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.text = url;
            }];
            [alert addAction:[UIAlertAction actionWithTitle:@"播放" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//                Class recordClass = NSClassFromString(@"RecordManager");
//                if (recordClass && [recordClass respondsToSelector:@selector(shareManager)]) {
//                    Class manager = [recordClass performSelector:@selector(shareManager)];
//                    if (manager && [manager respondsToSelector:@selector(playAudioWithUrl:)]) {
//                        [manager performSelectorWithArgs:@selector(playAudioWithUrl:), url];
//                    }
//                }
                
//                WebViewController *webVC = [[WebViewController alloc] initWithUrl:[NSURL URLWithString:url]];
//                [self.navigationController pushViewController:webVC animated:YES];
            }]];
            
            [self presentViewController:alert animated:YES completion:nil];
        });
    };
    
    Class uploadClass = NSClassFromString(@"UploadManager");
    if (uploadClass && [uploadClass respondsToSelector:@selector(shareManager)]) {
        Class manager = [uploadClass performSelector:@selector(shareManager)];
        if (manager && [manager respondsToSelector:@selector(uploadData:key:fileExt:progress:completion:)]) {
            [manager performSelectorWithArgs:@selector(uploadData:key:fileExt:progress:completion:), audioData, key, @"aac", progress, completion];
        }
    }
}

// 录音失败
- (void)recordFailed:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"录音失败 %@", error.domain];
    
    [MBProgressHUD showFinishHudOn:APP_DELEGATE_WINDOW
                        withResult:NO
                         labelText:message
                         delayHide:YES
                        completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
