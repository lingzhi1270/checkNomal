//
//  CameraPhotoView.m
//  Unilife
//
//  Created by 唐琦 on 2019/9/8.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "CameraPhotoView.h"
#import "MultiLineLabel.h"

@interface CameraInfoView : UIView

@property (nonatomic, strong) CameraPhotoData       *photo;
@property (nonatomic, strong) CameraTemplateData    *templateData;

@property (nonatomic, strong) UILabel           *label;

@end

@implementation CameraInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        
        self.label = [UILabel new];
        self.label.numberOfLines = 3;
        CGFloat height = 64 * [UIScreen mainScreen].scale / 2;
        [self addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(32);
            make.height.equalTo(@(height));
            make.centerY.equalTo(self).offset(-32);
        }];
    }
    
    return self;
}

- (void)setPhoto:(CameraPhotoData *)photo {
    _photo = photo;
    
    [self updateInfo];
}

- (void)setTemplateData:(CameraTemplateData *)templateData {
    _templateData = templateData;
    
    [self updateInfo];
}

- (void)updateInfo {
    NSString *stringName = [NSString stringWithFormat:@"%@: %@", self.templateData.nameTitle, self.photo.name];
    NSString *stringNumber = [NSString stringWithFormat:@"\n\n%@: %@", self.templateData.numberTitle, self.photo.number?:@""];
    
    CGFloat fontSize = 17 * [UIScreen mainScreen].scale / 2;
    self.label.attributedText = [NSAttributedString attributedStringWithStrings:stringName, [UIFont boldSystemFontOfSize:fontSize], self.templateData.textColor,
                                 stringNumber, [UIFont boldSystemFontOfSize:fontSize], self.templateData.textColor, nil];
}

@end

@interface CameraPhotoView () < UIScrollViewDelegate >

@property (nonatomic, strong) UIImageView           *photoView;
@property (nonatomic, strong) UIScrollView          *scrollView;
@property (nonatomic, strong) UIImageView           *backgroundView;
@property (nonatomic, strong) CameraInfoView        *infoView;

@end

@implementation CameraPhotoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.bounces = YES;
        self.scrollView.layer.anchorPoint = CGPointMake(.5, .5);
        self.scrollView.alwaysBounceHorizontal = YES;
        self.scrollView.alwaysBounceVertical = YES;
        self.scrollView.delegate = self;
        self.scrollView.zoomScale = 1.;
        self.scrollView.minimumZoomScale = .3;
        self.scrollView.maximumZoomScale = 50;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.clipsToBounds = NO;
        self.scrollView.backgroundColor = [UIColor whiteColor];
        
        [self.scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        self.scrollView.layer.masksToBounds = YES;
        [self addSubview:self.scrollView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self);
            make.bottom.equalTo(self).offset(-160);
        }];
        
        self.photoView = [UIImageView new];
        self.photoView.contentMode = UIViewContentModeScaleAspectFit;
        self.photoView.userInteractionEnabled = YES;
        [self.scrollView addSubview:self.photoView];
        
        self.backgroundView = [UIImageView new];
        [self addSubview:self.backgroundView];
        
        self.infoView = [CameraInfoView new];
        [self addSubview:self.infoView];
        [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.bottom.equalTo(self);
            make.height.equalTo(self).multipliedBy(.3);
        }];
    }
    
    return self;
}

- (void)setTemplateData:(CameraTemplateData *)templateData {
    _templateData = templateData;
    
    self.infoView.templateData = templateData;
    
    UIImage *image = [templateData backgroundImage];
    self.backgroundView.image = image;
    CGFloat ratioImage = image.size.width / image.size.height;
    
    CGFloat offset = 64;
    if ([UIScreen resolution] == UIDeviceResolution_iPhoneRetinaX) {
        offset += 24;
    }
    
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds) - offset;
    CGFloat ratioScreen = width / height;
    [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        if (ratioImage > ratioScreen) {
            make.width.equalTo(@(width));
            make.height.equalTo(self.backgroundView.mas_width).multipliedBy(1 / ratioImage);
        }
        else {
            make.height.equalTo(@(height));
            make.width.equalTo(self.backgroundView.mas_height).multipliedBy(ratioImage);
        }
    }];
}

- (void)setPhoto:(CameraPhotoData *)photo {
    [self.infoView setPhoto:photo];
}

- (UIImage *)image {
    return self.photoView.image;
}

- (void)setImage:(UIImage *)image {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize contentSize = CGSizeMake(image.size.width * image.scale / scale, image.size.height * image.scale / scale);
    contentSize = CGSizeMake(image.size.width, image.size.height);
    self.scrollView.contentSize = contentSize;
    
    self.photoView.image = image;
    self.photoView.frame = CGRectMake(30, 30, image.size.width / scale * 2, image.size.height / scale * 2);
    
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoView;
}

@end
