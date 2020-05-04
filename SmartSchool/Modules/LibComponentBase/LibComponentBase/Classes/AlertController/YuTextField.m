//
//  UITextField.m
//  YuCloud
//
//  Created by 唐琦 on 15/11/20.
//  Copyright © 2015年 VIROYAL-ELEC. All rights reserved.
//

#import "YuTextField.h"

YuTextFieldCommonTarget *textCommonDelegateTarget = nil;


@interface YuTextFieldCommonTarget () < YuTextFieldDelegate >

@end

@implementation YuTextFieldCommonTarget

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *lang = [[textField textInputMode] primaryLanguage];
    
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *marked = [textField markedTextRange];
        if (marked) {
            //正在拼音输入中，
            return YES;
        }
    }
    
#if YUCLOUD_WEILIAO
    //过滤 emoji
    NSInteger len = [string length];
    BOOL emojiFound = NO;
    
    size_t size = (len + 1) * sizeof(unichar);
    unichar *buffer = malloc(size);
    memset(buffer, 0, size);
    [string getCharacters:buffer];
    
    for (int i = 0; i < len; i++) {
        if (
            (buffer[i] >= 0x2600 && buffer[i] <= 0x26ff) ||
            (buffer[i] >= 0x2700 && buffer[i] <= 0x27ff) ||
            (buffer[i] >= 0xf100 && buffer[i] <= 0xf9ff) ||
            (buffer[i] >= 0xd100 && buffer[i] <= 0xd9ff)
            ) {
            emojiFound = YES;
            break;
        }
    }
    
    free(buffer);
    if (emojiFound) {
        return NO;
    }
#endif //YUCLOUD_WEILIAO

    if ([textField isKindOfClass:[YuTextField class]]) {
        YuTextField *field = (YuTextField *)textField;
        
        if (field.maxInputLength && field.maxInputLength < [field.text length] + [string length] - range.length) {
            [self shakeView:field];
            return NO;
        }
    }
    
    return YES;
}

- (void)shakeView:(UIView *)view {
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint x = CGPointMake(position.x + 10, position.y);
    CGPoint y = CGPointMake(position.x - 10, position.y);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    
    [animation setAutoreverses:YES];
    [animation setDuration:.05];
    [animation setRepeatCount:3];
    
    [viewLayer addAnimation:animation forKey:nil];
}

@end



@interface YuTextField ()

@property (nonatomic, copy)     NSString        *preContent;

@end

@implementation YuTextField

@synthesize maxInputLength = _maxInputLength;
@synthesize upperCase = _upperCase;


+ (id <YuTextFieldDelegate>)commonYuTextTarget {
    if (textCommonDelegateTarget == nil) {
        textCommonDelegateTarget = [[YuTextFieldCommonTarget alloc] init];
    }
    
    return textCommonDelegateTarget;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        //add extra initialization code here
    }
    
    return self;
}

- (void)setLeftPadding:(NSInteger)padding mode:(UITextFieldViewMode)mode
{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, padding, padding)];
    self.leftView = paddingView;
    self.leftViewMode = mode;
}

- (void)setRightPadding:(NSInteger)padding mode:(UITextFieldViewMode)mode
{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, padding, padding)];
    self.rightView = paddingView;
    self.rightViewMode = mode;
}

- (void)setLeftImage:(UIImage *)image padding:(NSInteger)padding mode:(UITextFieldViewMode)mode
{
    UIView *view = [[UIView alloc] init];
    self.leftView = view;
    self.leftViewMode = mode;
    [self addSubview:view];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [view addSubview:imageView];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.mas_left);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.width.equalTo(self.mas_height);
    }];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(view);
    }];
}

- (NSInteger)maxInputLength
{
    return _maxInputLength;
}

- (void)setMaxInputLength:(NSInteger)maxInputLength delegate:(id<YuTextFieldDelegate>)delegate
{
    self.maxInputLength = maxInputLength;
    self.delegate = delegate;
}

- (void)setMaxInputLength:(NSInteger)maxInputLength
{
    _maxInputLength = maxInputLength;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidBeginEditingNotification:) name:UITextFieldTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidEndEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:self];
}

- (BOOL)upperCase {
    return _upperCase;
}

- (void)setUpperCase:(BOOL)upperCase {
    _upperCase = upperCase;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldTextDidChangeNotification:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self];
}

- (void)setFilterEmoji:(BOOL)filterEmoji delegate:(id<YuTextFieldDelegate>)delegate {
    _filterEmoji = filterEmoji;
    self.delegate = delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldTextDidChangeNotification:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self];
}

- (void)textFieldTextDidBeginEditingNotification:(NSNotification *)notification
{
    YuTextField *textField = notification.object;
    
    self.preContent = textField.text;
}

- (void)textFieldTextDidEndEditingNotification:(NSNotification *)notification
{
    
}

- (void)textFieldTextDidChangeNotification:(NSNotification *)notification
{
    YuTextField *textField = notification.object;
    
    NSString *lang = [[textField textInputMode] primaryLanguage];
    
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *marked = [textField markedTextRange];
        if (marked) {
            //正在拼音输入中，
            return;
        }
    }
    
    if (_maxInputLength > 0 && [textField.text length] > _maxInputLength) {
        textField.text = self.preContent;
        
        [self shakeView:textField];
        return;
    }
    
    NSString *content = textField.text;
    if (_upperCase) {
        content = [content uppercaseString];
    }
    
    textField.text = content;
    self.preContent = content;
}

- (void)shakeView:(UIView *)view {
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint x = CGPointMake(position.x + 10, position.y);
    CGPoint y = CGPointMake(position.x - 10, position.y);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    
    [animation setAutoreverses:YES];
    [animation setDuration:.05];
    [animation setRepeatCount:3];
    
    [viewLayer addAnimation:animation forKey:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

@end

