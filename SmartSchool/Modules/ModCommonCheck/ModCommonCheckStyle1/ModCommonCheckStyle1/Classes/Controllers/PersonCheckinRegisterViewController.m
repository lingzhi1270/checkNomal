//
//  PersonCheckinRegisterViewController.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/18.
//

#import "PersonCheckinRegisterViewController.h"
#import <ModCommonCheckBase/CommonCheckManager.h>
#import <LibDataModel/CheckClassData.h>
#import "CheckGradeViewController.h"
@interface PersonCheckinRegisterViewController ()
{
    StudentInfoData *_studentInfoData;
}

@property (nonatomic, strong)UIImageView *topImageView;

@property (nonatomic ,strong) UIView            *topTFBackView;
@property (nonatomic, strong) UITextField       *topTextField;
@property (nonatomic, strong) UIButton          *rightBtn;

@property (nonatomic ,strong) UIView            *centerTFBackView;
@property (nonatomic, strong) UITextField       *centerTextField;

@property (nonatomic ,strong) UIView            *bottomTFBackView;
@property (nonatomic, strong) UITextField       *bottomTextField;

@property (nonatomic, strong) UIButton          *sureBtn;

@end

@implementation PersonCheckinRegisterViewController

- (void)loadView
{
      [super loadView];
      self.topImageView = [UIImageView new];
      self.topImageView.contentMode = UIViewContentModeScaleAspectFill;
      self.topImageView.image = [UIImage imageNamed:@"checkPersonRegisterTopImageView" bundleName:@"ModCommonCheckStyle1"];
      [self.view addSubview:self.topImageView];
         
      self.topTFBackView = [UIView new];
      self.topTFBackView.backgroundColor = [UIColor colorWithRGB:0xF2F2F2];
      self.topTFBackView.layer.cornerRadius = 22.f;
      self.topTFBackView.layer.masksToBounds = YES;
      [self.view addSubview:self.topTFBackView];
    
      self.topTextField = [UITextField new];
      self.topTextField.backgroundColor = [UIColor colorWithRGB:0xF2F2F2];
      self.topTextField.textColor = [UIColor colorWithRGB:0xA4A4A4];
      self.topTextField.textColor = [UIColor colorWithRGB:0x343434];
      self.topTextField.font = [UIFont systemFontOfSize:13];
      self.topTextField.placeholder = @"请输入学号";
      self.topTextField.autocorrectionType = UITextAutocorrectionTypeNo;
      self.topTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
      self.topTextField.delegate = self;
      [self.topTFBackView addSubview:self.topTextField];
    
      self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
      self.rightBtn.layer.cornerRadius = 22.f;
      self.rightBtn.layer.masksToBounds = YES;
      [self.rightBtn setBackgroundImage:[UIImage imageNamed:@"getInfobyIdImageView" bundleName:@"ModCommonCheckStyle1"] forState:UIControlStateNormal];
      [self.rightBtn addTarget:self action:@selector(touchRightBtn) forControlEvents:UIControlEventTouchUpInside];
      [self.topTFBackView addSubview:self.rightBtn];
    
      self.centerTFBackView = [UIView new];
      self.centerTFBackView.backgroundColor = [UIColor colorWithRGB:0xF2F2F2];
      self.centerTFBackView.layer.cornerRadius = 22.f;
      self.centerTFBackView.layer.masksToBounds = YES;
      [self.view addSubview:self.centerTFBackView];
    
      self.centerTextField = [UITextField new];
      self.centerTextField.userInteractionEnabled = NO;
      self.centerTextField.backgroundColor = [UIColor colorWithRGB:0xF2F2F2];
      self.centerTextField.textColor = [UIColor colorWithRGB:0xA4A4A4];
      self.centerTextField.textColor = [UIColor colorWithRGB:0x343434];
      self.centerTextField.font = [UIFont systemFontOfSize:13];
      self.centerTextField.placeholder = @"根据输入学号自动匹配";
      self.centerTextField.autocorrectionType = UITextAutocorrectionTypeNo;
      self.centerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
      [self.centerTFBackView addSubview:self.centerTextField];
    
      self.bottomTFBackView = [UIView new];
      self.bottomTFBackView.backgroundColor = [UIColor colorWithRGB:0xF2F2F2];
      self.bottomTFBackView.layer.cornerRadius = 22.f;
      self.bottomTFBackView.layer.masksToBounds = YES;
      [self.view addSubview:self.bottomTFBackView];
    
      self.bottomTextField = [UITextField new];
      self.bottomTextField.userInteractionEnabled = NO;
      self.bottomTextField.backgroundColor = [UIColor colorWithRGB:0xF2F2F2];
      self.bottomTextField.textColor = [UIColor colorWithRGB:0xA4A4A4];
      self.bottomTextField.textColor = [UIColor colorWithRGB:0x343434];
      self.bottomTextField.font = [UIFont systemFontOfSize:13];
      self.bottomTextField.placeholder = @"根据输入学号自动匹配";
      self.bottomTextField.autocorrectionType = UITextAutocorrectionTypeNo;
      self.bottomTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
      [self.bottomTFBackView addSubview:self.bottomTextField];
    
    
      self.sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
      self.sureBtn.layer.cornerRadius = 22.f;
      self.sureBtn.layer.masksToBounds = YES;
      [self.sureBtn setBackgroundColor:[UIColor colorWithRGB:0x4D7BFD]];
      [self.sureBtn setTitle:@"确定" forState:UIControlStateNormal];
      [self.sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      [self.sureBtn setFont:[UIFont systemFontOfSize:15]];
      [self.sureBtn addTarget:self action:@selector(touchSureBtn) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:self.sureBtn];
      
      [self.topImageView  mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.view).offset(KTopViewHeight);
          make.left.right.equalTo(self.view);
          make.height.equalTo(@100);
      }];
    
      [self.topTFBackView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(self.view).offset(40);
          make.right.equalTo(self.view).offset(-40);
          make.top.equalTo(self.topImageView.mas_bottom).offset(30);
          make.height.equalTo(@40);
      }];
    
      [self.topTextField mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(self.topTFBackView.mas_left).offset(15);
         make.top.bottom.equalTo(self.topTFBackView);
         make.width.equalTo(self.topTFBackView).multipliedBy(0.66);
      }];
    
      [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(self.topTextField.mas_right);
         make.top.bottom.right.equalTo(self.topTFBackView);
      }];
    
      [self.centerTFBackView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(self.view).offset(40);
         make.right.equalTo(self.view).offset(-40);
         make.top.equalTo(self.topTFBackView.mas_bottom).offset(35);
         make.height.equalTo(@40);
      }];
    
      [self.centerTextField mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(self.centerTFBackView.mas_left).offset(15);
         make.top.right.bottom.equalTo(self.centerTFBackView);
      }];

      [self.bottomTFBackView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(self.view).offset(40);
         make.right.equalTo(self.view).offset(-40);
         make.top.equalTo(self.centerTFBackView.mas_bottom).offset(35);
         make.height.equalTo(@40);
      }];
    
      [self.bottomTextField mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(self.bottomTFBackView.mas_left).offset(15);
         make.top.right.bottom.equalTo(self.bottomTFBackView);
      }];
    
      [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(self.view).offset(40);
         make.right.equalTo(self.view).offset(-40);
         make.top.equalTo(self.bottomTFBackView.mas_bottom).offset(35);
         make.height.equalTo(@40);
      }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
}

- (void)touchRightBtn
{
    if ([self.topTextField.text length] != 0) {
       __block MBProgressHUD *hud = [MBProgressHUD showHudOn:self.view
                                                               mode:MBProgressHUDModeIndeterminate
                                                              image:nil
                                                            message:@"正在获取关联信息"
                                                          delayHide:NO
                                                         completion:nil];
        [[CommonCheckManager shareManager] getStudentCheckProjectWithStudentId:self.topTextField.text completion:^(BOOL success, NSDictionary * _Nullable info) {
            [hud hideAnimated:YES];
            if (success) {
                if (info)
                {
                    _studentInfoData = [StudentInfoData modelWithDictionary:info];
                                                      self.centerTextField.text = _studentInfoData.name;
                                                      self.bottomTextField.text = _studentInfoData.class_name;
                }
                else
                {
                    hud = [MBProgressHUD showFinishHudOn:self.view
                      withResult:NO
                    labelText:@"未获取到该学生信息"
                    delayHide:YES
                    completion:nil];
                }
            }
            else
            {
              hud = [MBProgressHUD showFinishHudOn:self.view
                  withResult:NO
                labelText:@"获取关联信息失败"
                delayHide:YES
                completion:nil];
            }
        }];
    }
    else{
        [MBProgressHUD showFinishHudOn:self.view
          withResult:NO
        labelText:@"请先输入学号"
        delayHide:YES
        completion:nil];
    }
}

- (void)touchSureBtn
{
    if ([self.topTextField.text length] != 0)
    {
        if ([self.centerTextField.text length] != 0 && [self.bottomTextField.text length] != 0) {
               
            CheckGradeViewController *checkGradeVC = [[CheckGradeViewController alloc] initWithTitle:self.title rightItem:nil];
            checkGradeVC.mainKeyId = self.mainKeyId;
            checkGradeVC.studentId = _studentInfoData.studentId;
            checkGradeVC.classId = _studentInfoData.class_id;
            checkGradeVC.cheackGradeFromType = self.cheackGradeFromType;
            CheckGradesData *tipGradesData = [CheckGradesData new];
            tipGradesData.grade_no = _studentInfoData.grade_no;
            checkGradeVC.tipGradesData  = tipGradesData;
            
            CheckClassData *tipClassData = [CheckClassData new];
            tipClassData.class_no = _studentInfoData.class_no;
            tipClassData.name = _studentInfoData.class_name;
            checkGradeVC.tipClassData = tipClassData;
            [self.navigationController pushViewController:checkGradeVC animated:YES];
           }
           else
           {
               [MBProgressHUD showFinishHudOn:self.view
                        withResult:NO
                      labelText:@"请先获取关联信息"
                      delayHide:YES
                      completion:nil];
           }
    }
    else
    {
        [MBProgressHUD showFinishHudOn:self.view
          withResult:NO
        labelText:@"请先输入学号,获取关联信息"
        delayHide:YES
        completion:nil];
    }
}

@end
