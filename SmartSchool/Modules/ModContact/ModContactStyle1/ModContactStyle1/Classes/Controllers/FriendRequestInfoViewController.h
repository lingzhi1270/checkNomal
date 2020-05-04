//
//  FriendRequestInfoViewController.h
//  Unilife
//
//  Created by 唐琦 on 2019/7/7.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import "UserData.h"
#import "FriendRequestData.h"

@interface FriendRequestInfoViewController : BaseViewController

- (instancetype)initWithUser:(UserData *)user;

- (instancetype)initWithRequest:(FriendRequestData *)data;

@end
