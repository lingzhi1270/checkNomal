//
//  FriendRequestInfoViewController.m
//  Unilife
//
//  Created by 唐琦 on 2019/7/7.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "FriendRequestInfoViewController.h"
#import "ModContactStyle1AccountCell.h"
#import <ModLoginBase/AccountManager.h>
#import <ModLoginBase/UserManager.h>

typedef enum : NSUInteger {
    ConnectCellAccount,
    ConnectCellMessage,
    ConnectCellBtnRequest,
    ConnectCellBtnAccept,
    ConnectCellBtnChat,
} ConnectCellType;

@interface ConnectMessageCell : UITableViewCell

@property (nonatomic, copy)     NSString        *text;
@property (nonatomic, strong)   UITextView      *textView;

@end

@implementation ConnectMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textView = [UITextView new];
        self.textView.font = [UIFont systemFontOfSize:15];
        [CONTENT_VIEW addSubview:self.textView];
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leftMargin.equalTo(CONTENT_VIEW);
            make.topMargin.equalTo(CONTENT_VIEW);
            make.rightMargin.equalTo(CONTENT_VIEW);
            make.bottomMargin.equalTo(CONTENT_VIEW);
            make.height.equalTo(@64);
        }];
    }
    
    return self;
}

- (void)setText:(NSString *)text {
    self.textView.text = text;
}

@end

#pragma mark - FriendRequestInfoViewController

@interface FriendRequestInfoViewController () < UITableViewDelegate, UITableViewDataSource >

@property (nonatomic, strong) VITableView       *tableView;

@property (nonatomic, copy)   NSString          *userid;
@property (nonatomic, strong) FriendRequestData *request;
@property (nonatomic, copy)   NSArray           *data;
@property (nonatomic, copy)   NSString          *message;

@end

@implementation FriendRequestInfoViewController

- (instancetype)initWithUser:(UserData *)user {
    if (self = [super initWithTitle:@"详细资料" rightItem:nil]) {
        self.userid = user.userid;
        
        NSArray *section0 = @[@(ConnectCellAccount)];
        NSArray *section1 = @[@(ConnectCellMessage)];
        NSArray *section2 = @[@(ConnectCellBtnRequest)];
        self.data = @[section0, section1, section2];
    }
    
    return self;
}

- (instancetype)initWithRequest:(FriendRequestData *)data {
    if (self = [super initWithTitle:@"详细资料" rightItem:nil]) {
        self.userid = data.userid;
        self.request = data;
        
        NSArray *section0 = @[@(ConnectCellAccount)];
        NSArray *section1 = @[@(ConnectCellMessage)];
        NSArray *section2 = data.accepted?@[@(ConnectCellBtnChat)]:@[@(ConnectCellBtnAccept)];
        self.data = @[section0, section1, section2];
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    VITableView *tableView = [[VITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor colorFromHex:0xCCCCCC];
    tableView.backgroundColor = [UIColor colorFromHex:0xF9F9F9];
    
    [tableView registerClass:[ModContactStyle1AccountCell class]
      forCellReuseIdentifier:[ModContactStyle1AccountCell reuseIdentifier]];
    
    [tableView registerClass:[ConnectMessageCell class]
      forCellReuseIdentifier:[ConnectMessageCell reuseIdentifier]];
    
    [tableView registerClass:[UITableViewCell class]
      forCellReuseIdentifier:[UITableViewCell reuseIdentifier]];
    
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.safeArea);
    }];
    
    self.tableView = tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.message = [NSString stringWithFormat:@"我是%@", [AccountManager shareManager].accountInfo.name?:@""];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewDidEndEditing:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:nil];
}

- (void)textViewDidEndEditing:(NSNotification *)notification {
    UITextView *textView = notification.object;
    self.message = textView.text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)reuseIdentifierAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *number = self.data[indexPath.section][indexPath.row];
    switch ([number integerValue]) {
        case ConnectCellAccount:
            return [ModContactStyle1AccountCell reuseIdentifier];
            
        case ConnectCellMessage:
            return [ConnectMessageCell reuseIdentifier];
            
        default:
            return [UITableViewCell reuseIdentifier];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.data[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifierAtIndexPath:indexPath] forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return .1;
    }
    
    return 38.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"验证信息";
    }
    else if (section == 2) {
        return @"操作";
    }
    
    return nil;
}

- (CGFloat)tableView:(VITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MAX([tableView heightForRowWithIdentifier:[self reuseIdentifierAtIndexPath:indexPath]
                                       indexPath:indexPath
                                      fixedWidth:CGRectGetWidth([UIScreen mainScreen].bounds)
                                   configuration:^(__kindof UITableViewCell *cell) {
                                       [self configureCell:cell atIndexPath:indexPath];
                                   }], 48);
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSNumber *number = self.data[indexPath.section][indexPath.row];
    switch ([number integerValue]) {
        case ConnectCellAccount: {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            ModContactStyle1AccountCell *aCell = (ModContactStyle1AccountCell *)cell;
            [[UserManager shareManager] requestUserInfoWithUserid:self.userid
                                                     forceRefresh:NO
                                                      localholder:^(BOOL success, NSDictionary * _Nullable info) {
                                                          if (success) {
                                                              aCell.user = info[@"user"];
                                                          }
                                                      }
                                                       completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                           if (success) {
                                                               aCell.user = info[@"user"];
                                                           }
                                                       }];
        }
            break;
            
        case ConnectCellMessage: {
            ConnectMessageCell *mCell = (ConnectMessageCell *)cell;
            mCell.text = self.message;
        }
            break;
            
        case ConnectCellBtnRequest: {
            cell.textLabel.text = @"添加为好友";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
            break;
            
        case ConnectCellBtnAccept: {
            cell.textLabel.text = @"同意";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
            break;
            
        case ConnectCellBtnChat: {
            cell.textLabel.text = @"聊天";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
            break;
            
            
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:cell atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSNumber *number = self.data[indexPath.section][indexPath.row];
//    if ([number integerValue] == ConnectCellBtnRequest) {
//        [self.tableView endEditing:YES];
//
//        MBProgressHUD *hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
//                                                 mode:MBProgressHUDModeIndeterminate
//                                                image:nil
//                                              message:YUCLOUD_STRING_PLEASE_WAIT
//                                            delayHide:NO
//                                           completion:nil];
//
//        [[MessageManager shareManager] requestFriendConnectWith:self.userid
//                                                   message:self.message
//                                                completion:^(BOOL success, NSDictionary * _Nullable info) {
//                                                    NSNumber *error_code = info[@"error_code"];
//                                                    if ([error_code integerValue] == 2000) {
//                                                        [hud hideAnimated:YES];
//                                                        [YuAlertViewController showAlertWithTitle:nil
//                                                                                          message:info[@"error_msg"]
//                                                                                   viewController:self
//                                                                                          okTitle:YUCLOUD_STRING_DONE
//                                                                                         okAction:^(UIAlertAction * _Nonnull action) {
//                                                                                             [self.navigationController popViewControllerAnimated:YES];
//                                                                                         }
//                                                                                      cancelTitle:nil
//                                                                                     cancelAction:nil
//                                                                                       completion:nil];
//                                                    }
//                                                    else {
//                                                        [MBProgressHUD finishHudWithResult:success
//                                                                                       hud:hud
//                                                                                 labelText:[info errorMsg:success]
//                                                                                completion:nil];
//                                                    }
//                                                }];
//    }
//    else if ([number integerValue] == ConnectCellBtnAccept) {
//        MBProgressHUD *hud = [MBProgressHUD showHudOn:APP_DELEGATE_WINDOW
//                                                 mode:MBProgressHUDModeIndeterminate
//                                                image:nil
//                                              message:YUCLOUD_STRING_PLEASE_WAIT
//                                            delayHide:NO
//                                           completion:nil];
//
//        [[MessageManager shareManager] respondFriendRequestWith:self.request.requestid
//                                                    accept:YES
//                                                completion:^(BOOL success, NSDictionary * _Nullable info) {
//                                                    [MBProgressHUD finishHudWithResult:success
//                                                                                   hud:hud
//                                                                             labelText:[info errorMsg:success]
//                                                                            completion:^{
//                                                                                if (success) {
//                                                                                    [self.navigationController popViewControllerAnimated:YES];
//                                                                                }
//                                                                            }];
//                                                }];
//    }
//    else if ([number integerValue] == ConnectCellBtnChat) {
//
//    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidEndEditingNotification
                                                  object:nil];
}

@end
