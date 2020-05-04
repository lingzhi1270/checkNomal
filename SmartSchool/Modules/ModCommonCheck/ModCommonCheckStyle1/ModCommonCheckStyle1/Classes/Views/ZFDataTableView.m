//  ZFDataTableView.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/8.
//

#import "ZFDataTableView.h"
#define ItemHeight 44

@implementation ZFDataTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        
        [self _initView];
    }
    return self;
}

- (void)_initView {
    self.delegate = self;
    self.dataSource = self;
    self.showsVerticalScrollIndicator = NO;    //竖直
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;  //去掉分割线
    self.bounces = NO;
    self.rowHeight = ItemHeight;
}

- (void)setTableViewContentOffSet:(CGPoint)contentOffSet {
    [self setContentOffset:contentOffSet];
}

- (void)setTitleArr:(NSArray *)titleArr {
    _titleArr = titleArr;
}

#pragma mark - UITableView delegate/dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.backgroundColor = [UIColor clearColor];
        
        //设置边框，形成表格
        cell.layer.borderWidth = .3f;
        cell.layer.borderColor = [UIColor colorFromHex:0x6686FD].CGColor;
        //取消选中
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
        label.tag = 100;
        label.font = [UIFont systemFontOfSize:12];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
        
    }
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    label.text = [_titleArr objectAtIndex:indexPath.row];
    if ([label.text isEqualToString:@"总计"]) {
        cell.backgroundColor = [UIColor colorFromHex:0x6686FD];
    }
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, ItemHeight)];
    headerView.backgroundColor = [UIColor colorFromHex:0x6686FD];
 
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.bounds];
    label.text = self.headerStr;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:label];
    
    headerView.layer.borderColor = [UIColor colorFromHex:0x6686FD].CGColor;
    headerView.layer.borderWidth = .3f;
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ItemHeight;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_scroll_delegate && [_scroll_delegate respondsToSelector:@selector(dataTableViewContentOffSet:)]) {
        [_scroll_delegate dataTableViewContentOffSet:scrollView.contentOffset];
    }
}


@end
