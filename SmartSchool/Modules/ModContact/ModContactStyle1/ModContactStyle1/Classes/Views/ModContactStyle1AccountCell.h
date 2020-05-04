//
//  ModContactStyle1AccountCell.h
//  Pods
//
//  Created by 唐琦 on 2019/12/30.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/UserData.h>

NS_ASSUME_NONNULL_BEGIN

@interface ModContactStyle1AccountCell : UITableViewCell

@property (nonatomic, strong) UserData      *user;

- (void)setPrimaryColor:(UIColor *)primaryColor color:(UIColor *)secondaryColor;

@end

NS_ASSUME_NONNULL_END
