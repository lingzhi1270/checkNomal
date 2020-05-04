//
//  UIImage+JSPP.h
//  Conversation
//
//  Created by qlon 2019/5/17.
//

#import "ConfigureHeader.h"

NS_ASSUME_NONNULL_BEGIN

// 由角度转换弧度
#define kDegreesToRadian(x)         (M_PI * (x) / 180.0)
// 由弧度转换角度
#define kRadianToDegrees(radian)    (radian * 180.0) / (M_PI)

@interface UIImage (JSPP)

- (UIImage *)imageMaskedWithColor:(UIColor *)maskColor;

+ (UIImage *)imageWithColor:(UIColor *)color
                       size:(CGSize)size
          byRoundingCorners:(UIRectCorner)corners
                cornerRadii:(CGSize)cornerRadii;

+ (UIImage *)imageWithColor:(UIColor *)color
                       size:(CGSize)size
          byRoundingCorners:(UIRectCorner)corners
                cornerRadii:(CGSize)cornerRadii
                      title:(NSString *)title
                  titleFont:(UIFont *)titleFont
                 titleColor:(UIColor *)titleColor;

// 图像黑白处理
- (UIImage *)sketchImage;
// 等比压缩
- (UIImage *)imageScaleAspectToMaxSize:(CGFloat)newSize;
// 添加边框
- (UIImage *)imageAddBorderByIndex:(NSInteger)index;
// 图片选择90度
- (UIImage *)rotateImage;
// 图片旋转
- (UIImage *)imageRotatedByRadians:(CGFloat)radians withImage:(UIImage *)image;

- (UIImage *)fixOrientation;

@end

NS_ASSUME_NONNULL_END
