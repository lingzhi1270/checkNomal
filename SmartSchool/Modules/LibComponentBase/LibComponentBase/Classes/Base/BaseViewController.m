//
//  BaseViewController.m
//  Unilife
//
//  Created by 唐琦 on 2018/12/10.
//  Copyright © 2018 南京远御网络科技有限公司. All rights reserved.
//

#import "BaseViewController.h"
#import "ConfigureHeader.h"

@interface BaseViewController ()

@property (nonatomic, strong) UIView        *safeArea;

@property (nonatomic, copy)   NSString      *barTitle;

@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UIButton      *backButton;
@property (nonatomic, strong) UIButton      *rightButton;
@property (nonatomic, strong) UIButton      *leftButton;

@end

@implementation BaseViewController

- (void)dealloc {
//    DDLog(@"%@已销毁", NSStringFromClass(self.class));
}

- (instancetype)initWithTitle:(nullable NSString *)title
                    rightItem:(nullable UIButton *)rightButton {
    if (self = [super init]) {
        self.barTitle = title;
        self.rightButton = rightButton;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

/*
 * if your subclass want overwrite this method,
 * remember to call super and use self.view at later.
 */
- (void)loadView {
    self.modalPresentationStyle = UIModalPresentationFullScreen;

    UIView *view = [UIView new];
    
    view.backgroundColor = MAIN_BG_COLOR;
    
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = MAIN_NAVI_BG_COLOR;
    [view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(view);
        make.height.equalTo(@(KTopViewHeight));
    }];
    
    self.lineView = [[UIImageView alloc] init];
    self.lineView.backgroundColor = MAIN_LINE_COLOR;
    [self.topView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.topView);
        make.height.equalTo(@1);
    }];
    
    if (self.barTitle) {
        self.title = self.barTitle;
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = self.barTitle;
        self.titleLabel.textColor = MAIN_NAVI_TITLE_COLOR;
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.topView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView).offset([UIScreen resolution] > UIDeviceResolution_iPhoneRetina6p ? 44 : 20);
            make.centerX.equalTo(self.topView);
            make.width.equalTo(@(SCREENWIDTH*0.5));
            make.height.equalTo(@NAVIBAR_HEIGHT);
        }];
        
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backButton.tag = KTopViewBackButtonTag;
        [self.backButton setImage:[UIImage imageNamed:@"ic_app_back" bundleName:@"LibComponentBase"] forState:UIControlStateNormal];
        [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.backButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:self.backButton];
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topView).offset(5);
            make.centerY.equalTo(self.titleLabel);
            make.width.equalTo(@40);
            make.height.equalTo(@44);
        }];
        
        if (self.rightButton) {
            self.rightButton.tag = KTopViewRightButtonTag;
            [self.rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [self.topView addSubview:self.rightButton];
            [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.topView).offset(-15);
                make.centerY.equalTo(self.titleLabel);
                make.height.equalTo(@44);
            }];
        }
    }
    
    self.safeArea = [[UIView alloc] init];
    [view insertSubview:self.safeArea belowSubview:self.topView];
    
    [self.safeArea mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.barTitle) {
            make.top.equalTo(self.topView.mas_bottom);
            if (@available(iOS 11.0, *)) {
                make.left.equalTo(view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(view.mas_safeAreaLayoutGuideRight);
                make.bottom.equalTo(view.mas_safeAreaLayoutGuideBottom);
            }
            else {
                make.left.bottom.right.equalTo(view);
            }
        }
        else {
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(view.mas_safeAreaLayoutGuideTop).offset(KTopViewHeight);
                make.left.equalTo(view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(view.mas_safeAreaLayoutGuideRight);
                make.bottom.equalTo(view.mas_safeAreaLayoutGuideBottom);
            }
            else {
                make.top.equalTo(view).offset(KTopViewHeight);
                make.left.right.bottom.equalTo(view);
            }
        }
    }];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)hiddenBackButton {
    if (self.backButton) {
        self.backButton.hidden = YES;
    }
}

- (void)showBackButton {
    if (self.backButton) {
        self.backButton.hidden = NO;
    }
}

- (void)updateNaviBarWithTitle:(NSString *)title {
    self.barTitle = self.titleLabel.text = title;
}

- (void)addLeftButton:(UIButton *)leftButton {
    if (self.leftButton) {
        [self.leftButton removeFromSuperview];
        self.leftButton = nil;
    }
    
    self.leftButton = leftButton;
    self.leftButton.tag = KTopViewLeftButtonTag;
    [self.topView addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backButton);
        make.left.equalTo(self.backButton.mas_right);
        make.width.height.equalTo(@40);
    }];
}

- (void)addRightButton:(UIButton *)rightButton {
    if (self.rightButton) {
        [self.rightButton removeFromSuperview];
        self.rightButton = nil;
    }
    
    self.rightButton = rightButton;
    self.rightButton.tag = KTopViewRightButtonTag;
    [self.rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topView).offset(-15);
        make.centerY.equalTo(self.topView.mas_top).offset(KStatusBarHeight+44/2);
        make.height.equalTo(@44);
    }];
}

- (BOOL)landScape {
    return !UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints {
    [self constraintsNeedUpdate];
    
    [super updateViewConstraints];
}

- (void)constraintsNeedUpdate {
    // Implementation in your subclass.
}

- (void)closeView {
    if (self.navigationController.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)rightButtonAction {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
