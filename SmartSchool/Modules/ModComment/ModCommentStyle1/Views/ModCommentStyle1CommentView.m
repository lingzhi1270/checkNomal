//
//  ModCommentStyle1CommentView.m
//  Module_demo
//
//  Created by 唐琦 on 2019/9/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "ModCommentStyle1CommentView.h"

#define kTextMinHeight                      70.f
#define kTextMaxHeight                      150.f
#define kPlaceholderNormalString            @"请输入评论内容"
#define kPlaceholderReplyString(name)       [NSString stringWithFormat:@"回复%@", name]

@interface ModCommentStyle1CommentView () <UITextViewDelegate>
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, assign) BOOL alreadyDismss;

@end

@implementation ModCommentStyle1CommentView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        self.alreadyDismss = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillChangeFrame:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        self.bgView = [[UIView alloc] init];
        [self.bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)]];
        [self addSubview:self.bgView];
        
        self.contentView = [[UIView alloc] init];
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.contentView];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:cancelButton];
        
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [confirmButton setTitle:@"提交" forState:UIControlStateNormal];
        [confirmButton setTitleColor:MainColor forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:confirmButton];
        
        self.textView = [[UITextView alloc] init];
        self.textView.delegate = self;
        self.textView.font = [UIFont systemFontOfSize:16];
        self.textView.layer.cornerRadius = 5;
        self.textView.layer.borderWidth = 0.5;
        self.textView.layer.borderColor = [UIColor grayColor].CGColor;
        self.textView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.textView];
        
        self.placeholderLabel = [[UILabel alloc] init];
        self.placeholderLabel.text = kPlaceholderNormalString;
        self.placeholderLabel.textColor = [UIColor lightGrayColor];
        self.placeholderLabel.font = [UIFont systemFontOfSize:16];
        [self.textView addSubview:self.placeholderLabel];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }]; 
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
        }];
        
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(5);
            make.left.equalTo(self.contentView).offset(10);
            make.size.equalTo(@(CGSizeMake(44, 44)));
        }];
        
        [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(5);
            make.right.equalTo(self.contentView).offset(-10);
            make.size.equalTo(@(CGSizeMake(44, 44)));
        }];
        
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cancelButton.mas_bottom);
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-15);
            make.bottom.equalTo(self.contentView).offset(-10);
            make.height.equalTo(@(kTextMinHeight));
        }];
        
        [self.placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textView).offset(8);
            make.left.equalTo(self.textView).offset(5);
        }];
    }
    
    return self;
}

#pragma mark - ButtonClick
- (void)cancelButtonClick {
    [self dismissView];
}

- (void)confirmButtonClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConfirmComment:)]) {
        [self.delegate didConfirmComment:self.textView.text];
    }
    
    [self dismissView];
}

#pragma mark - Animate
- (CATransform3D)firstTransform{
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.0/-900;
    //带点缩小的效果
    t1 = CATransform3DScale(t1, 0.92, 0.92, 1);
    //绕x轴旋转
    t1 = CATransform3DRotate(t1, 15.0 * M_PI/180.0, 1, 0, 0);
    
    return t1;
}

- (CATransform3D)firstTransform2{
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.0/-900;
    
    //带点缩小的效果
    t1 = CATransform3DScale(t1, 0.92, 0.92, 1);
    //绕x轴旋转
    t1 = CATransform3DRotate(t1, 15 * M_PI/180.0, 1, 0, 0);
    
    return t1;
}

- (void)showView {
    self.bgView.backgroundColor = [UIColor clearColor];
    [self.textView becomeFirstResponder];

    [UIView animateWithDuration:0.3
                     animations:^{
                         self.bgView.backgroundColor = [UIColor colorAlphaFromHex:0x00000066];
                         
                         [[UniManager shareManager].topViewController.view.layer setTransform:[self firstTransform]];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3 animations:^{
                             [UniManager shareManager].topViewController.view.transform = CGAffineTransformMakeScale(0.92, 0.92);
                         }];
                     }];
}

- (void)dismissView {
    self.alreadyDismss = YES;
    
    self.bgView.backgroundColor = [UIColor colorAlphaFromHex:0x00000066];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [[UniManager shareManager].topViewController.view.layer setTransform:[self firstTransform2]];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.4 animations:^{
                             [UniManager shareManager].topViewController.view.transform = CGAffineTransformMakeScale(1, 1);
                         } completion:^(BOOL finished) {
                             self.bgView.backgroundColor = [UIColor clearColor];
                             [self removeFromSuperview];
                         }];
                     }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    // 根据文字内容决定placeholderView是否隐藏
    self.placeholderLabel.hidden = textView.text.length > 0;
    
    NSInteger height = ceilf([textView sizeThatFits:CGSizeMake(textView.bounds.size.width, MAXFLOAT)].height);
    // 输入框高度不小于最小高度
    if (height < kTextMinHeight) {
        return;
    }
    
    if (textView.height != height) { // 高度不一样，就改变了高度
        // 当高度大于最大高度时，需要滚动
        textView.scrollEnabled = height > kTextMaxHeight;
        
        //当不可以滚动（即 <= 最大高度）时，传值改变textView高度
        if (textView.scrollEnabled == NO) {
            [textView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(height));
            }];
            
            [self.contentView layoutIfNeeded];
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.alreadyDismss) {
        return;
    }
    
    [self dismissView];
}

#pragma mark - Notification Method
- (void)keyboardWillChangeFrame:(NSNotification *)noti {
    NSDictionary *dict      = noti.userInfo;
    CGRect keyboardFrame    = [dict[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.contentView.transform = CGAffineTransformMakeTranslation(0, -(SCREENHEIGHT-keyboardFrame.origin.y));
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti {
    NSDictionary *dict      = noti.userInfo;
    NSTimeInterval duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.contentView.transform = CGAffineTransformIdentity;
    }];
}

@end
