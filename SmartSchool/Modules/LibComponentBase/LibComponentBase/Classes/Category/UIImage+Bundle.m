//
//  UIImage+Bundle.m
//  Pods
//
//  Created by 唐琦 on 2020/1/6.
//

#import "UIImage+Bundle.h"

@implementation UIImage (Bundle)

+ (UIImage *)imageNamed:(NSString *)imageName bundleName:(NSString *)bundleName {
    NSBundle *bundle = nil;
    if (!bundleName.length) {
        bundle = [NSBundle mainBundle];
    }
    else {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    
    return [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
}

@end
