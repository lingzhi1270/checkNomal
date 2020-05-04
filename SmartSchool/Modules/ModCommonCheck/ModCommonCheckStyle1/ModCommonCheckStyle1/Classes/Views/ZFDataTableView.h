//  ZFDataTableView.h
//  AFNetworking
//
//  Created by lingzhi on 2020/1/8.
//

#import <LibComponentBase/ConfigureHeader.h>

/// 设置同步滑动代理
@protocol ZFScrollDelegate <NSObject>

- (void)dataTableViewContentOffSet:(CGPoint)contentOffSet;

@end

@interface ZFDataTableView : UITableView<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSString *headerStr;

@property (nonatomic, assign) id<ZFScrollDelegate> scroll_delegate;

- (void)setTableViewContentOffSet:(CGPoint)contentOffSet;

@end
