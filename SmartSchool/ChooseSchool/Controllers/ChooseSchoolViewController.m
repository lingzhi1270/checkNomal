//
//  ChooseSchoolViewController.m
//  ModuleDemo
//
//  Created by 唐琦 on 2020/1/3.
//  Copyright © 2020 唐琦. All rights reserved.
//

#import "ChooseSchoolViewController.h"
#import <ModLoginBase/AccountManager.h>
#import <ModLoginStyle1/ModLoginStyle1ViewController.h>
#import <LibDataModel/SchoolData.h>

@interface ChooseSchoolViewController () <ModLoginStyle1ViewControllerDelegate>
@property (nonatomic, strong) CommonSelectorView *selectorView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) SchoolData *selectedSchool;

@end

@implementation ChooseSchoolViewController

- (void)loadView {
    [super loadView];
    
    // 修改学校需要显示后退按钮
    if (!self.changeSchool) {
        [self hiddenBackButton];
    }

    UIImage *bgImage = [UIImage imageNamed:@"ic_login_schoolBg"];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.clipsToBounds = YES;
    [self.view addSubview:bgImageView];
    
    UIImage *logoImage = [UIImage imageNamed:@"ic_login_logo"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    logoImageView.clipsToBounds = YES;
    [self.view addSubview:logoImageView];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = @"请选择您的学校名称";
    tipLabel.textColor = [UIColor colorWithRGB:0xFFFEFE];
    tipLabel.font = [UIFont systemFontOfSize:15];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    
    UIButton *schoolButton = [UIButton buttonWithType:UIButtonTypeCustom];
    schoolButton.backgroundColor = [UIColor whiteColor];
    schoolButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [schoolButton setTitle:@"所属学校 >" forState:UIControlStateNormal];
    [schoolButton setTitleColor:[UIColor colorWithRGB:0xA4A4A4] forState:UIControlStateNormal];
    schoolButton.layer.cornerRadius = 22.5;
    schoolButton.layer.masksToBounds = YES;
    [schoolButton addTarget:self action:@selector(showSelectorView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:schoolButton];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.backgroundColor = [UIColor colorWithRGB:0x4D7BFD];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
    confirmButton.layer.cornerRadius = 22.5;
    confirmButton.layer.masksToBounds = YES;;
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
    
    self.selectorView = [[CommonSelectorView alloc] initWithPickerMode:PickerModeSingle];
    self.selectorView.title = @"选择学校";
    [self.view addSubview:self.selectorView];
    
    WEAK(self, weakSelf);
    self.selectorView.singleBlock = ^(NSInteger index) {
//        DDLog(@"选中第%d个", (int)index);

        if (index < weakSelf.dataArray.count) {
            weakSelf.selectedSchool = weakSelf.dataArray[index];

            schoolButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            [schoolButton setTitle:weakSelf.selectedSchool.name forState:UIControlStateNormal];
            [schoolButton setTitleColor:[UIColor colorWithRGB:0x333333] forState:UIControlStateNormal];
        }
    };
    
    
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.safeArea);
    }];
    
    CGFloat imageWidth = SCREENWIDTH*0.53;
    CGFloat imageHeight = imageWidth * logoImage.size.height / logoImage.size.width;
    
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.safeArea).offset(50);
        make.centerX.equalTo(self.view);
        make.size.equalTo(@(CGSizeMake(imageWidth, imageHeight)));
    }];
    
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(logoImageView.mas_bottom).offset(40);
        make.left.equalTo(self.safeArea).offset(25);
        make.right.equalTo(self.safeArea).offset(-25);
    }];
    
    [schoolButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipLabel.mas_bottom).offset(35);
        make.left.equalTo(self.safeArea).offset(25);
        make.right.equalTo(self.safeArea).offset(-25);
        make.height.equalTo(@(45));
    }];
    
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(schoolButton.mas_bottom).offset(30);
        make.left.equalTo(self.safeArea).offset(25);
        make.right.equalTo(self.safeArea).offset(-25);
        make.height.equalTo(@(45));
    }];
    
    [self.selectorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = [NSMutableArray arrayWithCapacity:0];
    // 请求学校列表
    [self requestSchoolListWithCompletion:nil];
}

- (void)closeView {
    // 还原上一次选择的学校id
    [[MainInterface sharedClient] updateSchoolId:[NSUserDefaults schoolId]];
    // 退出
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)requestSchoolListWithCompletion:(CommonBlock)completion {
    __block MBProgressHUD *hud = [MBProgressHUD showHudOn:self.view
                                                     mode:MBProgressHUDModeIndeterminate
                                                    image:nil
                                                  message:@"获取学校列表中..."
                                                delayHide:NO
                                               completion:nil];
    
    NSString *mainBaseUrl = @"TestBaseUrl";
    NSURL *resourceUrl = [[NSBundle mainBundle] URLForResource:@"servers" withExtension:@"plist"];
    NSDictionary *servers = [NSDictionary dictionaryWithContentsOfURL:resourceUrl];
    NSAssert(servers, @"config should not be failed");
    
    NSURL *baseUrl = [NSURL URLWithString:servers[mainBaseUrl]];
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
    [sessionManager.requestSerializer setValue:YuCloudMasterKey
                            forHTTPHeaderField:@"master_key"];
    [sessionManager GET:[[MainInterface sharedClient] serverInfo][@"ALL_SCHOOL_INFO"]
             parameters:nil
               progress:nil
                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [hud hideAnimated:YES];
                    
                    NSNumber *error_code = VALIDATE_NUMBER_WITH_DEFAULT([responseObject valueForKey:@"error_code"], @0);
                    NSString *error_msg = VALIDATE_STRING_WITH_DEFAULT(responseObject[@"error_msg"], @"");
                    
                    if ([error_code errorCodeSuccess]) {
                        NSArray *extra = responseObject[@"extra"];
                        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
                        for (NSDictionary *dict in extra) {
                            SchoolData *data = [SchoolData modelWithDictionary:dict];
                            [tempArray addObject:data.name];
                            [self.dataArray addObject:data];
                        }

                        self.selectorView.singleDataSource = tempArray.mutableCopy;
                        
                        if (completion) {
                            completion(YES, nil);
                        }
                    }
                    else {
                        if (completion) {
                            completion(NO, nil);
                        }
                        
                        hud = [MBProgressHUD showFinishHudOn:self.view
                                                  withResult:NO
                                                   labelText:error_msg
                                                   delayHide:YES
                                                  completion:nil];
                    }
                }
                failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [hud hideAnimated:YES];
        
                    if (completion) {
                        completion(NO, @{@"error_msg":error.domain});
                    }
                    if (error) {
                        hud = [MBProgressHUD showFinishHudOn:self.view
                                                  withResult:NO
                                                   labelText:error.domain
                                                   delayHide:YES
                                                  completion:nil];
                    }
                }];
}

- (void)showSelectorView {
    if (!self.dataArray.count) {
        [self requestSchoolListWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
            if (success) {
                [self showSelectorView];
            }
        }];
    }
    else {
        [self.selectorView showView];
    }
}

- (void)confirmAction {
    if (!self.selectedSchool) {
        [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
                            mode:MBProgressHUDModeText
                           image:nil
                         message:@"请选择学校"
                       delayHide:YES
                      completion:nil];
        
        return;
    }
    ModLoginStyle1ViewController *loginVC = [[ModLoginStyle1ViewController alloc] initWithTitle:@"登录" rightItem:nil];
    loginVC.delegate = self;
    loginVC.schoolData = self.selectedSchool;
    [self presentViewController:loginVC animated:YES completion:nil];
}

#pragma mark - ModLoginStyle1ViewControllerDelegate
- (void)loginViewController:(BaseViewController *)loginViewController loginState:(BOOL)success {
    if (success) {
        if (!self.changeSchool) {
            APP_DELEGATE_WINDOW.rootViewController = [[AppDelegate shareAppDelagate] configureTabController];
        }
        else {
            [NavigationController dismissViewControllerAnimated:NO completion:nil];
        }
    }
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
