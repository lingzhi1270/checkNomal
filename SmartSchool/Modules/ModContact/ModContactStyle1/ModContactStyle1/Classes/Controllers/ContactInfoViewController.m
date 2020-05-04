//
//  ContactInfoViewController.m
//  Unilife
//
//  Created by zhangliyong on 2019/12/7.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ContactInfoViewController.h"
#import <MessageUI/MessageUI.h>

typedef enum : NSUInteger {
    ContactCellPhone,
    ContactCellShortNo,
    ContactCellEmail,
} ContactCell;

@interface ContactInfoViewController () < MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource >
@property (nonatomic, strong) UITableView   *tableView;
@property (nonatomic, strong) ContactData   *contact;
@property (nonatomic, copy)   NSArray       *cellData;

@end

@implementation ContactInfoViewController

- (instancetype)initWithContact:(ContactData *)data {
    if(self = [super init]) {
        self.contact = data;
        [self updateNaviBarWithTitle:data.title];
        
        NSMutableArray *arr = [NSMutableArray new];
        if (data.phone.length) {
            [arr addObject:@(ContactCellPhone)];
        }
        
        if (data.shortNo.length) {
            [arr addObject:@(ContactCellShortNo)];
        }
        
        if (data.email.length) {
            [arr addObject:@(ContactCellEmail)];
        }
        
        self.cellData = arr.copy;
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 180)];
    headerView.backgroundColor = MAIN_COLOR;
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = self.contact.title;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:26];
    [headerView addSubview:nameLabel];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(headerView).offset(-16);
        make.left.equalTo(headerView).offset(16);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:[UITableViewCell reuseIdentifier]];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.safeArea);
    }];

    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell reuseIdentifier]];
    
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *number = self.cellData[indexPath.row];
    switch ([number integerValue]) {
        case ContactCellPhone:
            cell.imageView.image = [UIImage imageNamed:@"ic_contact_phone"];
            cell.textLabel.text = self.contact.phone;
            break;
            
        case ContactCellShortNo:
            cell.imageView.image = [UIImage imageNamed:@"ic_contact_shortno"];
            cell.textLabel.text = self.contact.shortNo;
            break;
            
        case ContactCellEmail:
            cell.imageView.image = [UIImage imageNamed:@"ic_contact_shortno"];
            cell.textLabel.text = self.contact.email;
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSNumber *number = self.cellData[indexPath.row];
    switch ([number integerValue]) {
        case ContactCellPhone: {
            [self showAlertWithNumber:self.contact.phone
                                title:@"拨打号码"];
        }
            
            break;
        case ContactCellShortNo: {
            [self showAlertWithNumber:self.contact.shortNo
                                title:@"拨打短号"];
        }
            break;
            
        case ContactCellEmail: {
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
                mail.mailComposeDelegate = self;
                [mail setToRecipients:@[self.contact.email]];
                [self presentViewController:mail
                                   animated:YES
                                 completion:nil];
            }
            else {
                [YuAlertViewController showAlertWithTitle:nil
                                                  message:@"请先配置邮件账号"
                                           viewController:self
                                                  okTitle:YUCLOUD_STRING_OK
                                                 okAction:^(UIAlertAction * _Nonnull action) {
                                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                                                        options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @NO}
                                                                              completionHandler:nil];
                                                 }
                                              cancelTitle:YUCLOUD_STRING_CANCEL
                                             cancelAction:nil
                                               completion:nil];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)showAlertWithNumber:(NSString *)number
                      title:(NSString *)title {
    
    if(!number.length) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:title
                                                      style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        NSString *tel = [NSString stringWithFormat:@"telprompt://%@", number];
                                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
                                                    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"复制号码到剪切板"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                                        pasteboard.string = number;
                                                        [MBProgressHUD showFinishHudOn:self.view
                                                                            withResult:YES
                                                                             labelText:@"号码已复制到剪切板"
                                                                             delayHide:YES
                                                                            completion:nil];
                                                    }];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    
    [self.navigationController presentViewController:alert
                                            animated:YES
                                          completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
