//
//  ThemeView.m
//  Unilife
//
//  Created by 唐琦 on 2019/7/22.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ThemeView.h"
#import "ThemeManager.h"
#import <LibComponentBase/ConfigureHeader.h>

@interface ThemeView ()

@property (nonatomic, strong) UIImageView   *imageView;

@end

@implementation ThemeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [UIImageView new];
        self.imageView.contentMode = UIViewContentModeTop;
        self.image = [ThemeManager shareManager].activeTheme.imageFull;
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [[ThemeManager shareManager] addObserver:self
                                      forKeyPath:@"activeTheme"
                                         options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                         context:nil];
    }
    
    return self;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == [ThemeManager shareManager] && [keyPath isEqualToString:@"activeTheme"]) {
        ThemeData *theme = [ThemeManager shareManager].activeTheme;
        
        self.backgroundColor = [theme colorForKey:ThemeContentBackgroundViewColorKey];
        self.image = theme.imageFull;
        
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UITableView class]]) {
                UITableView *tableView = (UITableView *)view;
                [tableView reloadData];
                
                if (tableView.style == UITableViewStyleGrouped) {
                    tableView.backgroundColor = [theme colorForKey:ThemeContentViewSeparatorColorKey];
                }
                else {
                    tableView.backgroundColor = [theme colorForKey:ThemeContentBackgroundViewColorKey];
                }
                tableView.separatorColor = [theme colorForKey:ThemeContentViewSeparatorColorKey];
            }
            else if ([view isKindOfClass:[UICollectionView class]]) {
                UICollectionView *collectionView = (UICollectionView *)view;
                [collectionView reloadData];
                
                collectionView.backgroundColor = [theme colorForKey:ThemeContentBackgroundViewColorKey];
            }
        }
    }
}

- (void)dealloc {
    [[ThemeManager shareManager] removeObserver:self
                                     forKeyPath:@"activeTheme"
                                        context:nil];
}

@end
