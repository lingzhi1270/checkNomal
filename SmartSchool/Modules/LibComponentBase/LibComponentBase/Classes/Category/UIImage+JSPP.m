//
//  UIImage+JSPP.m
//  Conversation
//
//  Created by qlon 2019/5/17.
//

#import "UIImage+JSPP.h"
#import <GPUImage/GPUImagePicture.h>
#import <GPUImage/GPUImageSketchFilter.h>

// 由角度转换弧度
#define kDegreesToRadian(x)         (M_PI * (x) / 180.0)
// 由弧度转换角度
#define kRadianToDegrees(radian)    (radian * 180.0) / (M_PI)

@implementation UIImage (JSPP)

- (UIImage *)imageMaskedWithColor:(UIColor *)maskColor
{
    NSParameterAssert(maskColor != nil);
    
    CGRect imageRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, self.scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, 0.0f, -(imageRect.size.height));
        
        CGContextClipToMask(context, imageRect, self.CGImage);
        CGContextSetFillColorWithColor(context, maskColor.CGColor);
        CGContextFillRect(context, imageRect);
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color
                       size:(CGSize)size
          byRoundingCorners:(UIRectCorner)corners
                cornerRadii:(CGSize)cornerRadii {
    UIImage *image = [UIImage imageWithColor:color size:size];
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect
                           byRoundingCorners:corners
                                 cornerRadii:cornerRadii] addClip];
    
    // Draw your image
    [image drawInRect:rect];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

+ (UIImage *)imageWithColor:(UIColor *)color
                       size:(CGSize)size
          byRoundingCorners:(UIRectCorner)corners
                cornerRadii:(CGSize)cornerRadii
                      title:(NSString *)title
                  titleFont:(UIFont *)titleFont
                 titleColor:(UIColor *)titleColor {
    UIImage *image = [UIImage imageWithColor:color size:size];
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect
                           byRoundingCorners:corners
                                 cornerRadii:cornerRadii] addClip];
    
    // Draw your image
    [image drawInRect:rect];
    
    // Draw text
    NSDictionary *attributes = @{NSFontAttributeName:titleFont, NSForegroundColorAttributeName:titleColor};
    CGSize txtSize = [title sizeWithAttributes:attributes];
    CGRect rectTxt = CGRectInset(rect, (CGRectGetWidth(rect) - txtSize.width) / 2, (CGRectGetHeight(rect) - txtSize.height) / 2);
    [title drawInRect:rectTxt withAttributes:attributes];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

// 图片黑白处理
- (UIImage *)sketchImage {
    UIImage *image = [self fixOrientation];
    GPUImageSketchFilter * filter = [[GPUImageSketchFilter alloc] init];
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture * picture = [[GPUImagePicture alloc] initWithImage:image];
    [picture addTarget:filter];
    [picture processImage];
    [filter useNextFrameForImageCapture];
    UIImage * outImage = [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    return outImage;
}

// 等比压缩
- (UIImage *)imageScaleAspectToMaxSize:(CGFloat)newSize {
    CGSize size = [self size];
    CGFloat ratio;
    if (size.width > size.height) {
        ratio = newSize / size.width;
    } else {
        ratio = newSize / size.height;
    }
    CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    [self drawInRect:rect];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

// 添加边框
- (UIImage *)imageAddBorderByIndex:(NSInteger)index {
    // 边框图片
    UIImage * borderImage = [UIImage imageNamed:[NSString stringWithFormat:@"border_%ld",(long)index]];
    // 对中间点像素拉伸
    borderImage = [borderImage stretchableImageWithLeftCapWidth:floorf(borderImage.size.width/2) topCapHeight:floorf(borderImage.size.height/2)];
    // 合成
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    [borderImage drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    // 刨去边框的宽度
    CGFloat margin  = 40;
    [self drawInRect:CGRectMake(margin, margin, self.size.width-2*margin, self.size.height-2*margin)];
    // 输出
    UIImage * outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outImage;
}

// 将图片旋转
- (UIImage *)rotateImage {
    // 90度向右旋转，-90度向左旋转
    UIImage *image = [self fixOrientation];
    return [self imageRotatedByRadians:kDegreesToRadian(-90) withImage:image];
}

// 将图片旋转弧度radians
- (UIImage *)imageRotatedByRadians:(CGFloat)radians withImage:(UIImage *)image{
    UIView * containView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGAffineTransform transform = CGAffineTransformMakeRotation(radians);
    containView.transform = transform;
    CGSize rotatedSize = containView.frame.size;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, radians);
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
    UIImage * outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outImage;
}

- (UIImage *)fixOrientation {
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    //我们需要计算出适当的变换使图像直立。
    //我们在2个步骤：如果左/右/下就旋转，如果镜像就翻转。
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
