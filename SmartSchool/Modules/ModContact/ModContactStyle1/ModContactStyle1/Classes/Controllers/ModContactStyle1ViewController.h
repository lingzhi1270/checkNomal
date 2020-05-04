//
//  ModContactStyle1ViewController.h
//  Unilife
//
//  Created by 唐琦 on 2018/3/15.
//  Copyright © 2018年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ContactSelectDelegate <NSObject>

- (void)contactSelectCanceled;
- (void)contactSelected:(id)data;

@end

@interface ModContactStyle1ViewController : BaseViewController

@property (nonatomic, weak) id<ContactSelectDelegate>    delegate;

- (instancetype)initWithCategory:(nullable NSString *)category grouped:(BOOL)grouped;

@end

NS_ASSUME_NONNULL_END

