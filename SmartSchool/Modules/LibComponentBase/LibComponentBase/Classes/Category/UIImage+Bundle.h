//
//  UIImage+Bundle.h
//  Pods
//
//  Created by 唐琦 on 2020/1/6.
//

#import "ConfigureHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Bundle)

+ (UIImage *)imageNamed:(NSString *)imageName bundleName:(NSString *)bundleName;

@end

NS_ASSUME_NONNULL_END
