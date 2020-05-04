//
//  ModLoginStyle1ViewController.m
//  Unilife
//
//  Created by 唐琦 on 2019/6/14.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ModLoginStyle1ViewController.h"
#import <ModLoginBase/AccountManager.h>
#import "ModLoginStyle1LoginPageView.h"
#import "ModLoginStyle1InputRow.h"

@interface ModLoginStyle1ViewController () < ModLoginStyle1LoginStyleViewDelegate, ModLoginStyle1InputPadViewDelegate >
@property (nonatomic, strong) ModLoginStyle1LoginPageView     *styleView;
@property (nonatomic, strong) ModLoginStyle1InputPadView      *phoneView;
@property (nonatomic, strong) ModLoginStyle1InputPadView      *emisView;
@property (nonatomic, copy)   NSString          *smsKey;

@end

@implementation ModLoginStyle1ViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = MAIN_NAVI_BG_COLOR;
    self.lineView.hidden = YES;

    if (self.schoolData) {
        UIButton *leftButton = [self.topView viewWithTag:KTopViewBackButtonTag];
        [leftButton setImage:[UIImage imageNamed:@"ic_common_close"] forState:UIControlStateNormal];
    }
    else {
        [self hiddenBackButton];
    }
    
    [self.safeArea addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaskView)]];
        
    UIImageView *logoImageView = [[UIImageView alloc] init];
    logoImageView.backgroundColor = [UIColor lightGrayColor];
    logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    logoImageView.clipsToBounds = YES;
    [self.view addSubview:logoImageView];
    
    // 加载所选学校的logo
    if (self.schoolData) {
        [logoImageView setImageWithURL:[NSURL URLWithString:self.schoolData.badge]
                               options:YYWebImageOptionProgressiveBlur];
    }
    else {
        [logoImageView setImageWithURL:[NSURL URLWithString:[NSUserDefaults schoolLogo]]
                               options:YYWebImageOptionProgressiveBlur];
    }
    
    NSArray *items = @[[LoginStyle2PageItem itemWithType:AccountPhone title:@"手机 账号"],
                       [LoginStyle2PageItem itemWithType:AccountEMIS title:@"EMIS"]];
    
    self.styleView = [[ModLoginStyle1LoginPageView alloc] initWithFrame:CGRectZero items:items.copy];
    self.styleView.tintColor = MAIN_COLOR;
    self.styleView.delegate = self;
    [self.view addSubview:self.styleView];
    
    self.phoneView = [ModLoginStyle1InputPadView new];
    self.phoneView.loginType = AccountPhone;
    self.phoneView.numberRow.textField.text = [NSUserDefaults accountForType:AccountPhone];
    self.phoneView.numberRow.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneView.codeRow.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneView.delegate = self;
    [self.view addSubview:self.phoneView];
    
    self.emisView = [ModLoginStyle1InputPadView new];
    self.emisView.loginType = AccountEMIS;
    self.emisView.numberRow.textField.text = [NSUserDefaults accountForType:AccountEMIS];
    self.emisView.delegate = self;
    [self.view addSubview:self.emisView];
    
    UIImage *bottomImage = [UIImage imageNamed:@"ic_login_bottom" bundleName:@"ModLoginStyle1"];

    UIImageView *bottomImageView = [[UIImageView alloc] initWithImage:bottomImage];
    bottomImageView.userInteractionEnabled = YES;
    bottomImageView.contentMode = UIViewContentModeScaleAspectFill;
    bottomImageView.clipsToBounds = YES;
    [bottomImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaskView)]];
    [self.view addSubview:bottomImageView];
    
    UILabel *bottomLabel = [[UILabel alloc] init];
    bottomLabel.text = self.schoolData.name;
    bottomLabel.textColor = [UIColor colorWithRGB:0xffffff];
    bottomLabel.font = [UIFont systemFontOfSize:11];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:bottomLabel];
    
    CGFloat imageHeight = SCREENWIDTH * bottomImage.size.height / bottomImage.size.width;
       
    [bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.size.equalTo(@(CGSizeMake(SCREENWIDTH, imageHeight)));
    }];
    
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.safeArea).offset(25.f);
        make.centerX.equalTo(self.safeArea);
        make.size.equalTo(@(CGSizeMake(120, 120)));
    }];
    
    [self.styleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(logoImageView.mas_bottom).offset(24);
        make.centerX.equalTo(self.safeArea);
        make.width.equalTo(self.safeArea).multipliedBy(.9);
        make.height.equalTo(@48);
    }];
    
    [self.phoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.styleView.mas_bottom).offset(16);
        make.width.equalTo(self.safeArea).multipliedBy(.8);
        make.centerX.equalTo(self.safeArea);
        make.centerY.equalTo(self.safeArea).offset(64);
    }];
    
    [self.emisView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.phoneView);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    // 获取当前登录方式
    self.styleView.selectedType = [NSUserDefaults loginStyle];
    // 获取当前学校id
    if (self.schoolData) {
        [[MainInterface sharedClient] updateSchoolId:self.schoolData.school_id];
    }
    else {
        [[MainInterface sharedClient] updateSchoolId:[NSUserDefaults schoolId]];
    }
}

- (void)tapMaskView {
    [self.view endEditing:YES];
}

- (void)closeView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginViewController:loginState:)]) {
        [self.delegate loginViewController:self loginState:NO];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ModLoginStyle1LoginStyleViewDelegate
- (void)loginStyleSelected:(LoginAccountType)type {
    if (self.emisView.loginType == type) {
        self.emisView.hidden = NO;
    }
    
    if (self.phoneView.loginType == type) {
        self.phoneView.hidden = NO;
    }
    
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:.3
                     animations:^{
                         self.emisView.alpha = self.emisView.loginType == type?1:0;
                         self.phoneView.alpha = self.phoneView.loginType == type?1:0;
                     }
                     completion:^(BOOL finished) {
                         self.emisView.hidden = self.emisView.loginType != type;
                         self.phoneView.hidden = self.phoneView.loginType != type;
                     }];
}

#pragma mark - ModLoginStyle1InputPadViewDelegate
- (void)touchGetSms:(ModLoginStyle1InputPadView *)inputPadView {
    NSString *phone = inputPadView.numberRow.textField.text;
    if (phone.length != 11) {
        return;
    }
    
    __block MBProgressHUD *hud = [MBProgressHUD showHudOn:self.view
                                             mode:MBProgressHUDModeIndeterminate
                                            image:nil
                                          message:YUCLOUD_STRING_PLEASE_WAIT
                                        delayHide:NO
                                       completion:nil];
    
    [[AccountManager shareManager] getSmsWithPhone:phone
                                        completion:^(BOOL success, NSDictionary * _Nullable info) {
                                            [hud hideAnimated:YES];

                                            if (success) {
                                                [inputPadView.codeRow.textField becomeFirstResponder];
                                                
                                                NSString *smsKey = VALIDATE_STRING(info[@"sms_key"]);
                                                NSNumber *expiration = VALIDATE_NUMBER(info[@"expiration"]);
                                                self.smsKey = smsKey;
                                                inputPadView.smsKey = smsKey;
                                                inputPadView.codeRow.text = VALIDATE_STRING(info[@"sms_code"]);
                                                [inputPadView.numberRow startCountDown:[NSDate dateWithTimeIntervalSinceNow:[expiration integerValue]]];
                                                
                                                hud = [MBProgressHUD showFinishHudOn:self.view
                                                                          withResult:success
                                                                           labelText:[info errorMsg:success]
                                                                           delayHide:YES
                                                                          completion:nil];
                                            }
                                            else {
                                                hud = [MBProgressHUD showFinishHudOn:self.view
                                                                          withResult:NO
                                                                           labelText:[info errorMsg:success]
                                                                           delayHide:YES
                                                                          completion:nil];
                                            }
                                       }];
}

- (void)loginWithPhone:(NSString *)phone code:(NSString *)code {        
    [self.view endEditing:YES];
    
    if (phone.length == 0 || code.length == 0 || self.smsKey.length == 0) {
        return;
    }
    
    __block MBProgressHUD *hud = [MBProgressHUD showHudOn:self.view
                                             mode:MBProgressHUDModeIndeterminate
                                            image:nil
                                          message:YUCLOUD_STRING_PLEASE_WAIT
                                        delayHide:NO
                                       completion:nil];
    
    [[AccountManager shareManager] loginPhoneWithUnionid:phone
                                                 smsCode:code
                                                  smsKey:self.smsKey
                                              completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                 [hud hideAnimated:YES];
                                                 if (success) {
                                                     // 保存当前登录方式为Phone
                                                     [NSUserDefaults saveLoginStyle:AccountPhone];
                                                     // 保存当前登录方式的Phone用户名
                                                     [NSUserDefaults saveAccount:phone ForType:AccountPhone];
                                                     // 保存学校信息
                                                     if (self.schoolData) {
                                                         // 保存当前登录的学校id
                                                         [NSUserDefaults saveSchoolId:self.schoolData.school_id];
                                                         // 保存当前登录的学校名称
                                                         [NSUserDefaults saveSchoolName:self.schoolData.name];
                                                         // 保存当前登录的学校Logo
                                                         [NSUserDefaults saveSchoolLogo:self.schoolData.badge];
                                                     }
                                                     // 立即存储
                                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                                     
                                                     hud = [MBProgressHUD showFinishHudOn:self.view
                                                                               withResult:YES
                                                                                labelText:@"登录成功!"
                                                                                delayHide:YES
                                                                               completion:^{
                                                                                    if (self.delegate && [self.delegate respondsToSelector:@selector(loginViewController:loginState:)]) {
                                                                                        [self.delegate loginViewController:self loginState:YES];
                                                                                    }
                                                                                }];
                                                 }
                                                 else {
                                                     hud = [MBProgressHUD showFinishHudOn:self.view
                                                                               withResult:NO
                                                                                labelText:[info errorMsg:success]
                                                                                delayHide:YES
                                                                               completion:nil];
                                                 }
                                             }];
}

- (void)loginWithEmis:(NSString *)unionid password:(NSString *)password {
    [self.view endEditing:YES];
    
    if (unionid.length == 0 || password.length == 0) {
        [MBProgressHUD showFinishHudOn:[UIApplication sharedApplication].keyWindow
                            withResult:NO
                             labelText:@"请输入有效内容"
                             delayHide:YES
                            completion:nil];
        return;
    }
    
    __block MBProgressHUD *hud = [MBProgressHUD showHudOn:self.view
                                             mode:MBProgressHUDModeIndeterminate
                                            image:nil
                                          message:YUCLOUD_STRING_PLEASE_WAIT
                                        delayHide:NO
                                       completion:nil];
    
    [[AccountManager shareManager] loginEmisWithUnionid:unionid
                                               password:password
                                             completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                 [hud hideAnimated:YES];
                                                 if (success) {
                                                     // 保存当前登录方式为EMIS
                                                     [NSUserDefaults saveLoginStyle:AccountEMIS];
                                                     // 保存当前登录方式的EMIS用户名
                                                     [NSUserDefaults saveAccount:unionid ForType:AccountEMIS];
                                                     // 保存学校信息
                                                     if (self.schoolData) {
                                                         // 保存当前登录的学校id
                                                         [NSUserDefaults saveSchoolId:self.schoolData.school_id];
                                                         // 保存当前登录的学校名称
                                                         [NSUserDefaults saveSchoolName:self.schoolData.name];
                                                         // 保存当前登录的学校Logo
                                                         [NSUserDefaults saveSchoolLogo:self.schoolData.badge];
                                                     }
                                                     
                                                     // 立即存储
                                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                                     
                                                     hud = [MBProgressHUD showFinishHudOn:self.view
                                                                               withResult:YES
                                                                                labelText:@"登录成功!"
                                                                                delayHide:YES
                                                                               completion:^{
                                                                                    if (self.delegate && [self.delegate respondsToSelector:@selector(loginViewController:loginState:)]) {
                                                                                        [self.delegate loginViewController:self loginState:YES];
                                                                                    }
                                                                                }];
                                                 }
                                                 else {
                                                     hud = [MBProgressHUD showFinishHudOn:self.view
                                                                               withResult:NO
                                                                                labelText:[info errorMsg:success]
                                                                                delayHide:YES
                                                                               completion:nil];
                                                 }
                                             }];
}

#pragma mark - AccountBindNavigationDelegate

- (void)accountBindFinished {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)accountBindCanceled {
    
}

#pragma mark - NSNotificationMethods
- (void)keyboardWillShow:(NSNotification *)noti {
    NSDictionary *dict      = noti.userInfo;
    CGRect keyboardFrame    = [dict[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat maxY            = CGRectGetMaxY(self.emisView.frame);
    if (keyboardFrame.origin.y < maxY) {
        [UIView animateWithDuration:duration animations:^{
            self.view.transform     = CGAffineTransformMakeTranslation(0, -(maxY-keyboardFrame.origin.y));
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)noti {
    NSDictionary *dict      = noti.userInfo;
    NSTimeInterval duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
