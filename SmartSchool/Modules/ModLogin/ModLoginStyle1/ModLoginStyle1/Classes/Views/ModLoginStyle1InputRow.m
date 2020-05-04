//
//  ModLoginStyle1InputRow.m
//  Unilife
//
//  Created by 唐琦 on 2019/6/25.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ModLoginStyle1InputRow.h"

@interface ModLoginStyle1InputRow () < UITextFieldDelegate >
@property (nonatomic, copy)   NSDate                *countDownDate;
@property (nonatomic, strong) NSTimer               *timer;

@end

@implementation ModLoginStyle1InputRow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRGB:0xF2F2F2];
        
        self.textField = [UITextField new];
        self.textField.textColor = [UIColor colorWithRGB:0x333333];
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.delegate = self;
        [self addSubview:self.textField];
        
        self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rightBtn.backgroundColor = MAIN_COLOR;
        self.rightBtn.layer.cornerRadius = 22.f;
        self.rightBtn.layer.masksToBounds = YES;
        self.rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.rightBtn setTitle:NSLocalizedString(@"Get Sms", nil) forState:UIControlStateNormal];
        [self.rightBtn addTarget:self action:@selector(touchRightBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightBtn];
        self.rightBtn.hidden = YES;
        
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(16);
            make.right.equalTo(self).offset(-16);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
        }];
    }
    
    return self;
}

- (void)showCountDownView {
    self.rightBtn.hidden = NO;
    
    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    [self.rightBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textField.mas_right).offset(15);
        make.top.right.bottom.equalTo(self);
        make.width.equalTo(@(100.f));
    }];
}

- (void)touchRightBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchGetSms)]) {
        [self.delegate touchGetSms];
    }
}

- (void)startCountDown:(NSDate *)date {    
    self.countDownDate = date;
    [self startResendTimer];
}

- (void)startResendTimer {
    if (self.timer) {
        [self.timer invalidate];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.3
                                                  target:self
                                                selector:@selector(resendTimerFires:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)resendTimerFires:(NSTimer *)timer {
    NSTimeInterval interval = [self.countDownDate timeIntervalSinceDate:[NSDate date]];
    if (interval > 0) {
        NSString *string = [NSString stringWithFormat:@"%ld", (long)interval];
        [self.rightBtn setTitle:string forState:UIControlStateNormal];
        self.rightBtn.enabled = NO;
    }
    else {
        self.rightBtn.enabled = YES;
        [self.rightBtn setTitle:NSLocalizedString(@"Resend", nil) forState:UIControlStateNormal];
        [timer invalidate];
    }
}

- (void)setText:(NSString *)text {
    self.textField.text = @"";
    if (text.length) {
        [self.textField insertText:text];
    }
}

- (NSString *)text {
    return self.textField.text;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:.3
                     animations:^{
                        self.textField.textColor = [UIColor whiteColor];
                        self.backgroundColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.8];
                     }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason {
    [UIView animateWithDuration:.3
                     animations:^{
                        self.textField.textColor = [UIColor colorWithRGB:0x333333];
                        self.backgroundColor = [UIColor colorWithRGB:0xF2F2F2];
                     }];
}


@end


@implementation ModLoginStyle1InputPadView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldTextDidChange)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:nil];
        
        self.numberRow = [ModLoginStyle1InputRow new];
        self.numberRow.delegate = self;
        self.numberRow.layer.cornerRadius = 22;
        self.numberRow.layer.masksToBounds = YES;
        [self addSubview:self.numberRow];
        
        self.codeRow = [ModLoginStyle1InputRow new];
        self.codeRow.layer.cornerRadius = 22;
        self.codeRow.layer.masksToBounds = YES;
        [self addSubview:self.codeRow];
        
        self.doneButton = [UIButton buttonWithTitleColor:[UIColor whiteColor]
                                         backgroundColor:MAIN_COLOR
                                             cornerRadii:CGSizeMake(22, 22)];
        [self.doneButton setTitle:@"登录" forState:UIControlStateNormal];
        [self.doneButton addTarget:self action:@selector(touchLoginBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.doneButton];

        [self.numberRow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.equalTo(@(44));
        }];
        
        [self.codeRow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.numberRow.mas_bottom).offset(16);
            make.left.right.equalTo(self);
            make.height.equalTo(@(44));
        }];
        
        [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.codeRow.mas_bottom).offset(16);
            make.left.right.equalTo(self);
            make.height.equalTo(@(44));
        }];
    }
    
    return self;
}

- (void)setLoginType:(LoginAccountType)loginType {
    _loginType = loginType;
    
    if (loginType == AccountPhone) {
        [self.numberRow showCountDownView];
        
        self.numberRow.textField.placeholder = @"请输入手机号码";
        self.codeRow.textField.placeholder = @"请输入验证码";
    }
    else if (loginType == AccountEMIS) {
        self.numberRow.textField.placeholder = @"请输入Emis账号";
        self.codeRow.textField.placeholder = @"请输入密码";
        self.codeRow.textField.secureTextEntry = YES;
    }
}

- (void)touchLoginBtn {
    if (self.loginType == AccountPhone) {
        [self.delegate loginWithPhone:self.numberRow.textField.text
                                 code:self.codeRow.textField.text];
    }
    else {
        [self.delegate loginWithEmis:self.numberRow.textField.text
                            password:self.codeRow.textField.text];
    }
}

- (void)textFieldTextDidChange {
    NSString *number = self.numberRow.textField.text;
    NSString *code = self.codeRow.textField.text;
    if (!self.codeRow.rightBtn.hidden) {
        self.codeRow.rightBtn.enabled = number.length == 11;
        
        self.doneButton.enabled = number.length == 11 && code.length == 6 && self.smsKey.length > 0;
    }
}

#pragma mark - ModLoginStyle1InputRowDelegate
- (void)touchGetSms {
    [self.delegate touchGetSms:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
}

@end
