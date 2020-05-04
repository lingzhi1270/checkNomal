//
//  ModLoginStyle1InputRow.h
//  Unilife
//
//  Created by 唐琦 on 2019/6/25.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <ModLoginBase/AccountManager.h>

@protocol ModLoginStyle1InputRowDelegate <NSObject>
- (void)touchGetSms;

@end

@interface ModLoginStyle1InputRow : UIView
@property (nonatomic, copy)   NSString          *text;
@property (nonatomic, strong) UITextField       *textField;
@property (nonatomic, strong) UIButton          *rightBtn;
@property (nonatomic, weak)   id<ModLoginStyle1InputRowDelegate>     delegate;

- (void)showCountDownView;
- (void)startCountDown:(NSDate *)date;

@end

@class ModLoginStyle1InputPadView;

@protocol ModLoginStyle1InputPadViewDelegate <NSObject>
- (void)touchGetSms:(ModLoginStyle1InputPadView *)inputPadView;
- (void)loginWithPhone:(NSString *)phone code:(NSString *)code;
- (void)loginWithEmis:(NSString *)unionid password:(NSString *)password;

@end

@interface ModLoginStyle1InputPadView : UIView < ModLoginStyle1InputRowDelegate >
@property (nonatomic, assign) LoginAccountType          loginType;
@property (nonatomic, weak)   id<ModLoginStyle1InputPadViewDelegate>  delegate;
@property (nonatomic, strong) ModLoginStyle1InputRow             *numberRow;
@property (nonatomic, strong) ModLoginStyle1InputRow             *codeRow;

@property (nonatomic, strong) UIButton                  *doneButton;

@property (nonatomic, copy)   NSString                  *smsKey;

@end
