//
//  CommitCheckSuccessViewController.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/17.
//

#import "CommitCheckSuccessViewController.h"
#import "CheckTodayResultListViewController.h"
#import "CheckSelectClassViewController.h"
#import "PersonCheckinRegisterViewController.h"
#import "ModCommonCheckStyle1ViewController.h"
@interface CommitCheckSuccessViewController ()

@property (nonatomic, strong)UIImageView *iconImageV;

@property (nonatomic, strong)UILabel *successTipLabel;

@property (nonatomic, strong)UIButton *scoreResultButton;

@property (nonatomic, strong)UIButton *continueScoreButton;


@end

@implementation CommitCheckSuccessViewController

- (void)loadView
{
    [super loadView];
    self.iconImageV = [UIImageView new];
    self.iconImageV.contentMode = UIViewContentModeScaleAspectFill;
    self.iconImageV.layer.cornerRadius = 40;
    self.iconImageV.layer.masksToBounds = YES;
    self.iconImageV.image = [UIImage imageNamed:@"commitSuccessImage" bundleName:@"ModCommonCheckStyle1"];
    [self.view addSubview:self.iconImageV];
    
    self.successTipLabel = [UILabel new];
    self.successTipLabel.textAlignment = NSTextAlignmentCenter;
    self.successTipLabel.text = @"提交成功";
    self.successTipLabel.font = [UIFont systemFontOfSize:16];
    self.successTipLabel.textColor =  [UIColor colorFromHex:0x343434];
    [self.view addSubview:self.successTipLabel];
        
    self.scoreResultButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.scoreResultButton.backgroundColor = [UIColor whiteColor];
    self.scoreResultButton.layer.cornerRadius = 12;
    self.scoreResultButton.layer.masksToBounds = YES;
    self.scoreResultButton.layer.borderWidth = 1;
    self.scoreResultButton.layer.borderColor = [UIColor colorFromHex:0x4D7BFD].CGColor;
    [self.scoreResultButton setTitle:@"查看打分" forState:UIControlStateNormal];
    [self.scoreResultButton setFont:[UIFont systemFontOfSize:16]];
    [self.scoreResultButton setTitleColor:  [UIColor colorFromHex:0x4D7BFD] forState:UIControlStateNormal];
    [self.scoreResultButton addTarget:self action:@selector(scoreResultButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scoreResultButton];
    
    self.continueScoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.continueScoreButton.backgroundColor = [UIColor colorFromHex:0x4D7BFD];
    self.continueScoreButton.layer.cornerRadius = 12;
    self.continueScoreButton.layer.masksToBounds = YES;
    [self.continueScoreButton setTitle:@"继续打分" forState:UIControlStateNormal];
    [self.continueScoreButton setFont:[UIFont systemFontOfSize:16]];
    [self.continueScoreButton setTitleColor:  [UIColor whiteColor] forState:UIControlStateNormal];
    [self.continueScoreButton addTarget:self action:@selector(continueScoreButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.continueScoreButton];
    
    [self.iconImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(140);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.height.equalTo(@80);
    }];
    
    [self.successTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageV.mas_bottom).offset(15);
        make.centerX.equalTo(self.iconImageV.mas_centerX);
        make.width.equalTo(@120);
        make.height.equalTo(@30);
    }];
    
    [self.scoreResultButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_centerX).offset(-24);
        make.centerY.equalTo(self.view.mas_centerY);
        make.width.equalTo(@140);
        make.height.equalTo(@50);
    }];
    
    [self.continueScoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_centerX).offset(24);
        make.centerY.equalTo(self.view.mas_centerY);
        make.width.equalTo(@140);
        make.height.equalTo(@50);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)scoreResultButtonAction
{
    CheckTodayResultListViewController *resultVC = [[CheckTodayResultListViewController alloc] initWithTitle:@"当日汇总表" rightItem:nil];
    resultVC.tipGradesData = self.tipGradesData;
    resultVC.tipClassData = self.tipClassData;
    [self.navigationController pushViewController:resultVC animated:YES];
}

- (void)continueScoreButtonAction
{
    switch (self.cheackGradeFromType) {
        case 0://个人
        {
            for(UIViewController *controller in self.navigationController.viewControllers) {

            if([controller isKindOfClass:[PersonCheckinRegisterViewController class]]) {
                [self.navigationController popToViewController:controller animated:YES];

               }
            }
        }
        break;
        case 1://班级
        {
            for(UIViewController *controller in self.navigationController.viewControllers) {

            if([controller isKindOfClass:[CheckSelectClassViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];

            }
          }
        }
        break;
        case 2://包干区
        {
            for(UIViewController *controller in self.navigationController.viewControllers) {

            if([controller isKindOfClass:[ModCommonCheckStyle1ViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
              }
            }
        }
        break;
        default:
        break;
    }
}
@end
