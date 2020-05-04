//
//  SwitchCell.h
//  Unilife
//
//  Created by 唐琦 on 2019/8/18.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

@class SwitchCell;

@protocol SwitchCellDelegate <NSObject>

- (void)switchCell:(SwitchCell *)cell switched:(BOOL)on;

@end

@interface SwitchCell : UITableViewCell

@property (nonatomic, weak) id<SwitchCellDelegate>      delegate;
@property (nonatomic, assign) BOOL                      on;

@end
