//
//  LocationViewController.h
//  ViroyalFireWarning_iOS
//
//  Created by 唐琦 on 2019/6/12.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

typedef void(^locationBlock)(NSString *name, NSString *address, NSString *location);

@interface LocationViewController : BaseViewController
@property (nonatomic, copy) locationBlock block;

@end
