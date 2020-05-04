//
//  ModLoginStyle1LoginPageView.h
//  Unilife
//
//  Created by 唐琦 on 2019/6/24.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/AccountInfo.h>

@interface LoginStyle2PageItem : NSObject
@property (nonatomic, assign) LoginAccountType      type;
@property (nonatomic, copy)   NSString              *title;

+ (instancetype)itemWithType:(LoginAccountType)type title:(NSString *)title;

@end

@protocol ModLoginStyle1LoginStyleViewDelegate <NSObject>

- (void)loginStyleSelected:(LoginAccountType)type;

@end

@interface ModLoginStyle1LoginPageView : UIView
@property (nonatomic, weak)   id<ModLoginStyle1LoginStyleViewDelegate>    delegate;
@property (nonatomic, assign) LoginAccountType              selectedType;

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray<LoginStyle2PageItem *> *)items;

@end
