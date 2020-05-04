//
//  CommonSelectorView.h
//  SmartSchool
//
//  Created by 唐琦 on 2020/1/7.
//  Copyright © 2020 唐琦. All rights reserved.
//

#import "ConfigureHeader.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SingleSelectorBlock)(NSInteger index);
typedef void(^MultiSelectorBlock)(NSArray<NSNumber *> *indexs);
typedef void(^DateSelectorBlock)(NSDate *date);

typedef enum : NSUInteger {
    PickerModeDate,
    PickerModeSingle,
    PickerModeMulti,
} PickerMode;

@interface SelectorMultiModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSMutableArray *array;

@end

@interface CommonSelectorView : UIView
@property (nonatomic, copy)   NSString                      *title;
@property (nonatomic, strong) UIFont                        *defaultFont;           // 滚轮文字Font,默认22
@property (nonatomic, copy)   SingleSelectorBlock           singleBlock;
@property (nonatomic, copy)   MultiSelectorBlock            multiBlock;
@property (nonatomic, copy)   DateSelectorBlock             dateBlock;

@property (nonatomic, strong) NSArray<NSString *>           *singleDataSource;      // PickerModeSingle模式的数据源
@property (nonatomic, strong) NSArray<SelectorMultiModel *> *multiDataSource;       // PickerModeMulti模式的数据源

- (instancetype)initWithPickerMode:(PickerMode)mode;

- (void)showView;
- (void)dismissView;

@end

NS_ASSUME_NONNULL_END
