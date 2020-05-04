//
//  CameraControlPane.m
//  Unilife
//
//  Created by 唐琦 on 2019/9/11.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "CameraControlPane.h"

@interface CameraTemplateCell : UICollectionViewCell

@property (nonatomic, strong) CameraTemplateData    *data;
@property (nonatomic, strong) UILabel               *label;

@end

@implementation CameraTemplateCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = THEME_BUTTON_BACKGROUND_COLOR;
        
        self.label = [UILabel new];
        self.label.font = [UIFont systemFontOfSize:15];
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        [CONTENT_VIEW addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(CONTENT_VIEW);
            make.bottom.equalTo(CONTENT_VIEW);
            make.left.equalTo(CONTENT_VIEW).offset(4);
            make.right.equalTo(CONTENT_VIEW).offset(-4);
        }];
        
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
    }
    
    return self;
}

- (void)setData:(CameraTemplateData *)data {
    self.label.text = data.name;
}

@end

@interface CameraControlPane () < UICollectionViewDataSource, UICollectionViewDelegateFlowLayout >

@property (nonatomic, strong) UICollectionView      *collectionView;
@property (nonatomic, copy)   NSArray               *templates;

@end

@implementation CameraControlPane

- (instancetype)initWithTemplates:(NSArray *)templates {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.templates = templates;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 8;
        layout.minimumInteritemSpacing = 8;
        layout.sectionInset = UIEdgeInsetsZero;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[CameraTemplateCell class]
                forCellWithReuseIdentifier:[CameraTemplateCell reuseIdentifier]];
        
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(32);
            make.right.equalTo(self).offset(-32);
            make.top.equalTo(self).offset(16);
            make.height.equalTo(@38);
        }];
        
        UIButton *btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnConfirm setImage:[UIImage imageNamed:@"ic_avatar_confirm"] forState:UIControlStateNormal];
        [btnConfirm addTarget:self
                       action:@selector(touchConfirm)
             forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnConfirm];
        [btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.collectionView.mas_bottom).offset(16);
            make.bottom.equalTo(self).offset(-16);
            make.height.equalTo(@62);
            make.width.equalTo(btnConfirm.mas_height);
        }];
        
        UIButton *btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnCamera setImage:[UIImage imageNamed:@"ic_avatar_shot"] forState:UIControlStateNormal];
        [btnCamera addTarget:self
                      action:@selector(touchSelectPhoto)
            forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnCamera];
        [btnCamera mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(32);
            make.centerY.equalTo(btnConfirm);
        }];
        
        UIButton *btnHide = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnHide setImage:[UIImage imageNamed:@"ic_avatar_pane_hide"] forState:UIControlStateNormal];
        [btnHide addTarget:self
                    action:@selector(touchHide)
          forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnHide];
        [btnHide mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-32);
            make.centerY.equalTo(btnConfirm);
        }];
    }
    
    return self;
}

- (void)selectTemplateAtIndex:(NSInteger)index {
    [self.delegate controlPane:self didSelectedTemplate:self.templates[index % self.templates.count]];
}

- (void)touchSelectPhoto {
    [self.delegate controlPaneSelectPhoto];
}

- (void)touchConfirm {
    [self.delegate controlPaneConfirmPhoto];
}

- (void)touchHide {
    [self.delegate controlPaneHide];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.templates.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:[CameraTemplateCell reuseIdentifier]
                                                     forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = CGRectGetHeight(collectionView.frame);
    CameraTemplateData *templateData = self.templates[indexPath.item];
    NSString *string = templateData.name;
    CGSize size = [string sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
    return CGSizeMake(size.width + 16, height);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(CameraTemplateCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.data = self.templates[indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate controlPane:self didSelectedTemplate:self.templates[indexPath.item]];
}

@end
