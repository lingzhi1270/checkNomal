//
//  AccountCell.h
//  Unilife
//
//  Created by 唐琦 on 2019/6/21.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/UserData.h>

@interface AccountView : UIView

@property (nonatomic, strong) UserData      *user;

- (void)setPrimaryColor:(UIColor *)primaryColor color:(UIColor *)secondaryColor;

@end

@interface AccountCell : UITableViewCell

@property (nonatomic, strong) UserData      *user;

- (void)setPrimaryColor:(UIColor *)primaryColor color:(UIColor *)secondaryColor;

@end
