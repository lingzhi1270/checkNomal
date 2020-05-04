//
//  CommonSelectorView.m
//  SmartSchool
//
//  Created by 唐琦 on 2020/1/7.
//  Copyright © 2020 唐琦. All rights reserved.
//

#import "CommonSelectorView.h"
#import <YYKit/NSObject+YYModel.h>

@implementation SelectorMultiModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return [self modelInitWithCoder:aDecoder];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self modelCopy];
}

- (instancetype)init {
    if (self = [super init]) {
        self.array = [NSMutableArray arrayWithCapacity:0];
    }
    
    return self;
}
@end

@interface CommonSelectorView () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, assign) PickerMode pickerMode;
@property (nonatomic, assign) NSInteger sectionNumber;

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, assign) NSInteger selectedMainIndex;
@property (nonatomic, assign) NSInteger selectedSubIndex;
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) UIDatePicker *datePicker;

@end

@implementation CommonSelectorView

- (instancetype)initWithPickerMode:(PickerMode)mode {
    if (self = [super init]) {
        self.pickerMode = mode;
        self.defaultFont = [UIFont systemFontOfSize:22];
        
        self.bgView = [UIView new];
        self.bgView.backgroundColor = [UIColor blackColor];
        self.bgView.alpha = 0.0;
        [self addSubview:self.bgView];
        
        [self.bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)]];
        
        self.contentView = [UIView new];
        self.contentView.backgroundColor = [UIColor colorWithRGB:0xEEEEEE];
        [self addSubview:self.contentView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [UIColor colorWithRGB:0x333333];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLabel];
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor colorWithRGB:0x4C8EEA] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.cancelButton];
        
        self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.confirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [self.confirmButton setTitleColor:[UIColor colorWithRGB:0x4C8EEA] forState:UIControlStateNormal];
        [self.confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.confirmButton];
        
        if (mode == PickerModeDate) {
            self.datePicker = [[UIDatePicker alloc] init];
            self.datePicker.backgroundColor = [UIColor whiteColor];
            self.datePicker.datePickerMode = UIDatePickerModeDate;
            [self.contentView addSubview:self.datePicker];
            
            [self.datePicker mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.cancelButton.mas_bottom);
                make.left.bottom.right.equalTo(self.contentView);
                make.height.equalTo(@(200.f));
            }];
        }
        else {
            self.pickerView = [[UIPickerView alloc] init];
            self.pickerView.backgroundColor = [UIColor whiteColor];
            self.pickerView.delegate = self;
            self.pickerView.dataSource = self;
            [self.contentView addSubview:self.pickerView];
            
            [self.pickerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.cancelButton.mas_bottom);
                make.left.bottom.right.equalTo(self.contentView);
                make.height.equalTo(@(200.f));
            }];
        }
        
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom);
            make.left.right.equalTo(self);
        }];
        
        [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(15);
            make.size.equalTo(@(CGSizeMake(44.f, 44.f)));
        }];
        
        [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-15);
            make.size.equalTo(@(CGSizeMake(44.f, 44.f)));
        }];
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.cancelButton);
            make.left.equalTo(self.cancelButton.mas_right).offset(10);
            make.right.equalTo(self.confirmButton.mas_left).offset(-10);
        }];
        
        // 默认隐藏
        self.hidden = YES;
    }
    
    return self;
}

- (void)cancelAction {
    [self dismissView];
}

- (void)confirmAction {
    if (self.pickerMode == PickerModeDate) {
        if (self.dateBlock) {
            self.dateBlock(self.datePicker.date);
        }
    }
    else if (self.pickerMode == PickerModeSingle) {
        if (self.singleBlock) {
            self.singleBlock(self.selectedIndex);
        }
    }
    else {
        if (self.multiBlock) {
            self.multiBlock(@[@(self.selectedMainIndex), @(self.selectedSubIndex), @(self.selectedIndex)]);
        }
    }
    
    [self dismissView];
}

#pragma mark - 配置数据源
- (void)setSingleDataSource:(NSArray<NSString *> *)singleDataSource {
    if (self.pickerMode != PickerModeSingle) {
        return;
    }
    
    _singleDataSource = singleDataSource;
    
    self.selectedIndex = 0;
    [self.pickerView reloadAllComponents];
}

- (void)setMultiDataSource:(NSArray<SelectorMultiModel *> *)multiDataSource {
    if (self.pickerMode != PickerModeMulti) {
        return;
    }
    
    _multiDataSource = multiDataSource;
    
    self.sectionNumber = 0;
    for (SelectorMultiModel *mainModel in multiDataSource) {
        if (mainModel.array.count) {
            self.sectionNumber = 2;
        }
        
        for (SelectorMultiModel *subModel in mainModel.array) {
            if (subModel.array.count) {
                self.sectionNumber = 3;
            }
        }
    }
    
    self.selectedMainIndex = 0;
    self.selectedIndex = 0;
    [self.pickerView reloadAllComponents];
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

#pragma mark - 进出场动画
- (void)showView {
    self.hidden = NO;
    self.bgView.alpha = 0.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.alpha = 0.6;
        
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).offset(-self.contentView.height);
        }];
        
        [self layoutIfNeeded];
    }];
}

- (void)dismissView {
    self.bgView.alpha = 0.6;
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.alpha = 0.0;
        
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom);
        }];
        
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = YES;
        
        self.selectedMainIndex = 0;
        self.selectedSubIndex = 0;
        self.selectedIndex = 0;
        
        [self.pickerView selectRow:0 inComponent:0 animated:NO];
        if (self.sectionNumber > 1) {
            [self.pickerView selectRow:0 inComponent:1 animated:NO];
        }
        else if (self.sectionNumber > 2) {
            [self.pickerView selectRow:0 inComponent:1 animated:NO];
            [self.pickerView selectRow:0 inComponent:2 animated:NO];
        }
    }];
}

#pragma mark - UIPickerViewDataSource&&UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.pickerMode == PickerModeSingle) {
        return 1;
    }
    
    return self.sectionNumber;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.pickerMode == PickerModeSingle) {
        return self.singleDataSource.count;
    }
    else {
        if (component == 0) {
            return self.multiDataSource.count;
        }
        else if (component == 1) {
            SelectorMultiModel *mainModel = self.multiDataSource[self.selectedMainIndex];
            
            return mainModel.array.count;
        }
        else {
            SelectorMultiModel *mainModel = self.multiDataSource[self.selectedMainIndex];
            SelectorMultiModel *subModel = mainModel.array[self.selectedSubIndex];
            
            return subModel.array.count;
        }
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    NSString *title = nil;
    
    if (self.pickerMode == PickerModeSingle) {
        title = self.singleDataSource[row];
    }
    else {
        if (component == 0) {
            SelectorMultiModel *model = self.multiDataSource[row];
            
            title = model.title;
        }
        else if (component == 1) {
            SelectorMultiModel *mainModel = self.multiDataSource[self.selectedMainIndex];
            SelectorMultiModel *subModel = mainModel.array[row];
            
            title = subModel.title;
        }
        else {
            SelectorMultiModel *mainModel = self.multiDataSource[self.selectedMainIndex];
            SelectorMultiModel *subModel = mainModel.array[self.selectedSubIndex];
            SelectorMultiModel *model = subModel.array[row];
            
            title = model.title;
        }
    }
    
    UILabel *titleLabel = (UILabel *)view;
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [UIColor colorWithRGB:0x000000];
        titleLabel.font = self.defaultFont;
        titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    titleLabel.text = title;
    
    return titleLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.pickerMode == PickerModeSingle) {
        self.selectedIndex = row;
    }
    else {
        if (component == 0) {
            self.selectedMainIndex = row;
            self.selectedSubIndex = 0;
            self.selectedIndex = 0;
            // 刷新数据
            [pickerView reloadAllComponents];
            // 二级目录默认选中第一个
            [pickerView selectRow:0 inComponent:1 animated:YES];
            // 如果有三级目录,也默认选中第一个
            if (self.sectionNumber == 3) {
                [pickerView selectRow:0 inComponent:2 animated:YES];
            }
        }
        else if (component == 1) {
            self.selectedSubIndex = row;
            self.selectedIndex = 0;
            // 刷新数据
            [pickerView reloadAllComponents];
            // 如果有三级目录,也默认选中第一个
            if (self.sectionNumber == 3) {
                [pickerView selectRow:0 inComponent:2 animated:YES];
            }
        }
        else {
            self.selectedIndex = row;
        }
    }
}

@end
