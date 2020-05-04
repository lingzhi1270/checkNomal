//
//  YCXMenuItem.h

//  Created by lingzhi on 19/12/24.
//
#import <LibComponentBase/ConfigureHeader.h>

@interface YCXMenuItem : NSObject

@property (nonatomic, strong) UIImage      *image;
@property (nonatomic, copy) NSString     *title;
@property (nonatomic, assign) NSInteger     tag;
@property (nonatomic, assign) NSInteger     unreadNumber;
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, strong) UIFont  *titleFont;
@property (nonatomic) NSTextAlignment  alignment;
@property (nonatomic, strong) UIColor *foreColor;

@property (nonatomic, weak) id target;
@property (readwrite, nonatomic) SEL      action;



+ (instancetype)menuTitle:(NSString *)title withIcon:(UIImage *)icon unreadNumber:(NSInteger)unreadNumber;
+ (instancetype)menuItem:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag unreadNumber:(NSInteger)unreadNumber userInfo:(NSDictionary *)userInfo;

+ (instancetype)menuItem:(NSString *)title image:(UIImage *)image target:(id)target unreadNumber:(NSInteger)unreadNumber action:(SEL)action;
- (void)performAction;

- (BOOL)enabled;

@end
