//
//  ModLoginStyle1ViewController.h
//  Unilife
//
//  Created by 唐琦 on 2019/6/14.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/SchoolData.h>

@protocol ModLoginStyle1ViewControllerDelegate <NSObject>
- (void)loginViewController:(BaseViewController *)loginViewController loginState:(BOOL)success;

@end

@interface ModLoginStyle1ViewController : BaseViewController
@property (nonatomic, strong) SchoolData  *schoolData;
@property (nonatomic, weak) id<ModLoginStyle1ViewControllerDelegate> delegate;

@end
