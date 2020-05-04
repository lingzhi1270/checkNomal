//
//  SpeechEditView.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/27.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "SpeechEditView.h"
#import <LibComponentBase/ConfigureHeader.h>

@interface SpeechEditView ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UISlider *rateSlider;
@property (nonatomic, strong) UISlider *pitchSlider;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) UILabel *rateLabel;
@property (nonatomic, strong) UILabel *pitchLabel;
@property (nonatomic, strong) UILabel *volumeLabel;
@property (nonatomic, strong) UIButton *transformButton;
@property (nonatomic, assign) float rate;
@property (nonatomic, assign) float pitch;
@property (nonatomic, assign) float volume;

@end

@implementation SpeechEditView

- (instancetype)init {
    if (self = [super init]) {
        self.rate = 0.5;
        self.pitch = 1.0;
        self.volume = 1.0;
        
        self.bgView = [[UIView alloc] init];
        self.bgView.backgroundColor = [UIColor colorWithRGB:0xF9F9F9];
        self.bgView.layer.cornerRadius = 8;
        self.bgView.layer.masksToBounds = YES;
        self.bgView.hidden = YES;
        [self addSubview:self.bgView];
 
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"文字转语音";
        titleLabel.textColor = [UIColor colorWithRGB:0x333333];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgView addSubview:titleLabel];
        
        UILabel *brifeLabel = [[UILabel alloc] init];
        brifeLabel.text = @"语速、音调、音量可调，输入文字后点击转换按钮即可试听";
        brifeLabel.textColor = [UIColor colorWithRGB:0x333333];
        brifeLabel.font = [UIFont systemFontOfSize:16];
        brifeLabel.numberOfLines = 0;
        brifeLabel.preferredMaxLayoutWidth = SCREENWIDTH-25*2-20*2;
        [self.bgView addSubview:brifeLabel];
        
        self.textField = [[UITextField alloc] init];
        self.textField.text = @"《求是》杂志发表习近平总书记重要文章《在解决“两不愁三保障”突出问题座谈会上的讲话》,新华社北京8月15日电 8月16日出版的第16期《求是》杂志将发表中共中央总书记、国家主席、中央军委主席习近平的重要文章《在解决“两不愁三保障”突出问题座谈会上的讲话》。文章强调，脱贫攻坚战进入决胜的关键阶段，各地区各部门务必高度重视，统一思想，抓好落实，一鼓作气，顽强作战，越战越勇，着力解决“两不愁三保障”突出问题，扎实做好今明两年脱贫攻坚工作，为如期全面打赢脱贫攻坚战、如期全面建成小康社会作出新的更大贡献。文章指出，总的看，脱贫攻坚成效是明显的：一是脱贫摘帽有序推进；二是“两不愁”总体实现；三是易地扶贫搬迁建设任务即将完成；四是党在农村的执政基础更加巩固。在肯定成绩的同时，也要清醒认识全面打赢脱贫攻坚战面临的困难和问题：第一类是直接影响脱贫攻坚目标任务实现的问题；第二类是工作中需要进一步改进的问题；第三类是需要长期逐步解决的问题。文章指出，到2020年稳定实现农村贫困人口不愁吃、不愁穿，义务教育、基本医疗、住房安全有保障，是贫困人口脱贫的基本要求和核心指标，直接关系攻坚战质量。总的看，“两不愁”基本解决了，“三保障”还存在不少薄弱环节。要摸清底数，聚焦突出问题，明确时间表、路线图，加大工作力度，拿出过硬举措和办法，确保如期完成任务。文章指出，脱贫攻坚战进入决胜的关键阶段，打法要同初期的全面部署、中期的全面推进有所区别，最要紧的是防止松懈、防止滑坡。一要强化责任落实；二要攻克坚中之坚；三要认真整改问题；四要提高脱贫质量；五要稳定脱贫攻坚政策；六要切实改进作风。";
        self.textField.placeholder = @"请输入要转换的文字";
        self.textField.layer.borderColor = [UIColor colorWithRGB:0x333333].CGColor;
        self.textField.layer.borderWidth = 0.5;
        self.textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        self.textField.leftViewMode = UITextFieldViewModeAlways;
        [self.bgView addSubview:self.textField];
        
        self.rateSlider = [[UISlider alloc] init];
        self.rateSlider.value = self.rate;
        self.rateSlider.minimumValue = 0;
        self.rateSlider.maximumValue = 1;
        [self.rateSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.bgView addSubview:self.rateSlider];
        
        self.pitchSlider = [[UISlider alloc] init];
        self.pitchSlider.value = self.pitch;
        self.pitchSlider.minimumValue = 0.5;
        self.pitchSlider.maximumValue = 2.0;
        [self.pitchSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.bgView addSubview:self.pitchSlider];
        
        self.volumeSlider = [[UISlider alloc] init];
        self.volumeSlider.value = self.volume;
        self.volumeSlider.minimumValue = 0;
        self.volumeSlider.maximumValue = 1;
        [self.volumeSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.bgView addSubview:self.volumeSlider];
        
        self.rateLabel = [[UILabel alloc] init];
        self.rateLabel.font = [UIFont systemFontOfSize:13];
        self.rateLabel.text = [NSString stringWithFormat:@"语速调节区间(0.0 ~ 1.0) 当前语速:%.1f", self.rate];
        [self.bgView addSubview:self.rateLabel];
        
        self.pitchLabel = [[UILabel alloc] init];
        self.pitchLabel.font = [UIFont systemFontOfSize:13];
        self.pitchLabel.text = [NSString stringWithFormat:@"音调调节区间(0.5 ~ 2.0) 当前音调:%.1f", self.pitch];
        [self.bgView addSubview:self.pitchLabel];
        
        self.volumeLabel = [[UILabel alloc] init];
        self.volumeLabel.font = [UIFont systemFontOfSize:13];
        self.volumeLabel.text = [NSString stringWithFormat:@"音量调节区间(0.0 ~ 1.0) 当前音量:%.1f", self.volume];
        [self.bgView addSubview:self.volumeLabel];
        
        UIImageView *lineView = [[UIImageView alloc] init];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [self.bgView addSubview:lineView];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor colorWithRGB:0x097AEC] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:cancelButton];
        
        self.transformButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.transformButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [self.transformButton setTitle:@"转换" forState:UIControlStateNormal];
        [self.transformButton setTitleColor:[UIColor colorWithRGB:0x097AEC] forState:UIControlStateNormal];
        [self.transformButton addTarget:self action:@selector(transformButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:self.transformButton];
        
        if (!self.textField.text.length) {
            [self.transformButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            self.transformButton.enabled = NO;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidChanged:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:nil];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(25);
            make.right.equalTo(self).offset(-25);
        }];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgView).offset(20);
            make.centerX.equalTo(self.bgView);
        }];
        
        [brifeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(5);
            make.left.equalTo(self.bgView).offset(20);
            make.right.equalTo(self.bgView).offset(-20);
        }];
        
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(brifeLabel.mas_bottom).offset(25);
            make.left.equalTo(self.bgView).offset(20);
            make.right.equalTo(self.bgView).offset(-20);
            make.height.equalTo(@35);
        }];
        
        [self.rateSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textField.mas_bottom).offset(15);
            make.left.right.equalTo(self.textField);
            make.height.equalTo(@30);
        }];
        
        [self.rateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.rateSlider.mas_bottom).offset(5);
            make.left.equalTo(self.rateSlider);
        }];
        
        [self.pitchSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.rateLabel.mas_bottom).offset(15);
            make.left.right.equalTo(self.textField);
            make.height.equalTo(@30);
        }];
        
        [self.pitchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.pitchSlider.mas_bottom).offset(5);
            make.left.equalTo(self.rateSlider);
        }];
        
        [self.volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.pitchLabel.mas_bottom).offset(15);
            make.left.right.equalTo(self.textField);
            make.height.equalTo(@30);
        }];
        
        [self.volumeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.volumeSlider.mas_bottom).offset(5);
            make.left.equalTo(self.rateSlider);
        }];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.volumeLabel.mas_bottom).offset(10);
            make.left.right.equalTo(self.bgView);
            make.height.equalTo(@0.5);
        }];
        
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lineView.mas_bottom);
            make.left.bottom.equalTo(self.bgView);
            make.width.equalTo(self.bgView).multipliedBy(0.5);
            make.height.equalTo(@44.f);
        }];
        
        [self.transformButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lineView.mas_bottom);
            make.right.bottom.equalTo(self.bgView);
            make.width.equalTo(self.bgView).multipliedBy(0.5);
            make.height.equalTo(@44.f);
        }];
    }
    
    return self;
}

- (void)valueChanged:(UISlider *)slider {
    if (slider == self.rateSlider) {
        self.rate = slider.value;
        self.rateLabel.text = [NSString stringWithFormat:@"语速调节区间(0.0 ~ 1.0) 当前语速:%.1f", slider.value];
    }
    else if (slider == self.pitchSlider) {
        self.pitch = slider.value;
        self.pitchLabel.text = [NSString stringWithFormat:@"音调调节区间(0.0 ~ 2.0) 当前音调:%.1f", slider.value];
    }
    else {
        self.volume = slider.value;
        self.volumeLabel.text = [NSString stringWithFormat:@"音量调节区间(0.0 ~ 1.0) 当前音量:%.1f", slider.value];
    }
}

- (void)showView {
    self.backgroundColor = [UIColor clearColor];
    self.bgView.hidden = NO;
    self.bgView.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIColor colorAlphaFromHex:0x00000099];
        self.bgView.alpha = 1.0;
    }];
}

- (void)dismiss {
    self.backgroundColor = [UIColor colorAlphaFromHex:0x00000099];
    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.bgView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)cancelButtonClick {
    [self dismiss];
}

- (void)transformButtonClick {
    if (self.block) {
        self.block(self.textField.text, self.rate, self.pitch, self.volume);
    }
    
    [self dismiss];
}

- (void)textFieldDidChanged:(NSNotification *)noti {
    if (self.textField.text.length) {
        [self.transformButton setTitleColor:[UIColor colorWithRGB:0x097AEC] forState:UIControlStateNormal];
        self.transformButton.enabled = YES;
    }
    else {
        [self.transformButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.transformButton.enabled = NO;
    }
}

@end
