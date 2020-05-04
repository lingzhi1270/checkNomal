//
//  ModPayStyle1MenuView.m
//  Unilife
//
//  Created by 唐琦 on 2019/8/3.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ModPayStyle1MenuView.h"

@interface ModPayStyle1Cell : UITableViewCell

@property (nonatomic, strong) PayMethod     *method;

@end

@implementation ModPayStyle1Cell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    
    return self;
}

- (void)setMethod:(PayMethod *)method {
    self.imageView.image = method.enabled?method.image:[method.image convertToGrayscale];
    self.textLabel.text = method.title;
    
    self.textLabel.textColor = method.enabled?[UIColor blackColor]:[UIColor grayColor];
    self.selectionStyle = method.enabled?UITableViewCellSelectionStyleDefault:UITableViewCellSelectionStyleNone;
}

@end

@interface ModPayStyle1MenuView () < UITableViewDataSource, UITableViewDelegate >

@property (nonatomic, strong) UIView                *backgroundView;
@property (nonatomic, strong) UITableView           *tableView;
@property (nonatomic, assign) CGFloat               tableViewHeight;

@property (nonatomic, copy)   NSArray<PayMethod *>  *methods;

@end

@implementation ModPayStyle1MenuView

- (instancetype)initWithMethods:(NSArray<PayMethod *> *)methods {
    if (self = [super initWithFrame:CGRectZero]) {
        self.methods = methods;
        
        self.backgroundView = [UIView new];
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = .0;
        [self.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(tapBackground)]];
        
        [self addSubview:self.backgroundView];
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.alwaysBounceVertical = NO;
        
        [self.tableView registerClass:[ModPayStyle1Cell class]
               forCellReuseIdentifier:[ModPayStyle1Cell reuseIdentifier]];
        
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        [self addSubview:self.tableView];
        self.tableViewHeight = 78 * methods.count;
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self.mas_bottom);
            make.height.equalTo(@(self.tableViewHeight));
        }];
    }
    
    return self;
}

- (void)tapBackground {
    [self dismissViewAnimated:YES
                   completion:^{
                       [self.delegate payMenuViewDidCancel];
                   }];
}

- (void)showMenuAnimated:(BOOL)animated completion:(CommonBlock)completion {
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.equalTo(@(self.tableViewHeight));
    }];
    
    [UIView animateWithDuration:.3
                          delay:0
         usingSpringWithDamping:.7
          initialSpringVelocity:.7
                        options:0
                     animations:^{
                         self.backgroundView.alpha = .3;
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion(YES, nil);
                         }
                     }];
}

- (void)dismissViewAnimated:(BOOL)animated completion:(dispatch_block_t)completion {
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(self.mas_bottom);
        make.height.equalTo(@(self.tableViewHeight));
    }];
    
    [UIView animateWithDuration:.3
                          delay:0
         usingSpringWithDamping:30
          initialSpringVelocity:30
                        options:0
                     animations:^{
                         self.backgroundView.alpha = .0;
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         
                         if (completion) {
                             completion();
                         }
                     }];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.methods.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = CGRectGetHeight(tableView.bounds);
    
    return height / self.methods.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[ModPayStyle1Cell reuseIdentifier] forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(ModPayStyle1Cell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.method = self.methods[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PayMethod *method = self.methods[indexPath.row];
    if (method.enabled) {
        [self.delegate payMenuView:self didSelectedMethod:method];
    }
    else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:tableView animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabel.text = @"暂时不支持";
        hud.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
        [hud hideAnimated:YES afterDelay:PROGRESS_DELAY_HIDE];
    }
}

@end
