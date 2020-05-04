//
//  BaseTabbarView.h
//  XNN
//
//  Created by tangqi on 2018/11/6.
//  Copyright © 2018 VIROYAL. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BaseTabbarItemState) {
    BaseTabbarItemNormal,
    BaseTabbarItemPushInside,
    BaseTabbarItemPushOutside,
    BaseTabbarItemFailed
};

@interface BaseTabbarModel : NSObject

+ (instancetype)allocWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage;

@end

@class BaseTabbarItem;

@protocol BaseTabbarItemDelegate < NSObject >

- (void)baseTabbarItemTouchDown:(BaseTabbarItem *)button;

- (void)baseTabbarItemTouchUpInside:(BaseTabbarItem *)button;

- (void)baseTabbarItemTouchUpOutside:(BaseTabbarItem *)button;

@end

@interface BaseTabbarItem : UIView <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) BaseTabbarModel *model;
@property (nonatomic, strong) UILongPressGestureRecognizer *rec;

@property (nonatomic, weak)   id<BaseTabbarItemDelegate>    delegate;
@property (nonatomic, assign) BaseTabbarItemState           state;
@property (nonatomic, assign) CGFloat                       meter;
@property (nonatomic, assign) BOOL                          selected;
@property (nonatomic, copy)   UIColor                       *hudTintColor;
@property (nonatomic, copy)   UIColor                       *hudBackgroundColor;

@end

@protocol BaseTabbarViewDelegate <NSObject>

- (void)tabbarButtonClick:(NSInteger)index;

@end

@interface BaseTabbarView : UIView
@property (nonatomic, assign) id<BaseTabbarViewDelegate> delegate;

- (instancetype)initWithArray:(NSArray *)array;
- (void)configureBackgroundImage:(UIImage *)bgImage;

@end

NS_ASSUME_NONNULL_END
