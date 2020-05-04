//
//  ScratchCardView.h
//  RGBTool
//
//  Created by admin on 23/08/2017.
//  Copyright © 2017 gcg. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

@interface XScratchView : UIView

/** masoicImage(放在底层) */
@property (nonatomic, strong) UIImage *mosaicImage;
/** surfaceImage(放在顶层) */
@property (nonatomic, strong) UIImage *surfaceImage;

@property (nonatomic, copy) void (^XScratchViewDidMove)(BOOL canRecover);

/** 恢复 */
- (void)recover;

- (void)changeRectWithFrame:(CGRect)rect;
@end
