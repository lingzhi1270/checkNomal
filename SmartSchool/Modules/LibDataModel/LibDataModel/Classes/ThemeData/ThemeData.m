//
//  ThemeDataSource.m
//  Unilife
//
//  Created by 唐琦 on 2019/7/20.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ThemeData.h"
#import <YYKit/NSObject+YYModel.h>

@interface ThemeData ()

@end

@implementation ThemeData

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return [self modelInitWithCoder:aDecoder];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self modelCopy];
}

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.colors = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (UIColor *)colorForKey:(NSString *)key {
    return self.colors[key];
}

- (UIImage *)imageForKey:(NSString *)key {
    NSURL *cache = [[UIApplication sharedApplication] cachesURL];
    cache = [cache URLByAppendingPathComponent:@"theme"];
    [[NSFileManager defaultManager] createDirectoryAtURL:cache
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:nil];
    
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:cache.path];
    
    NSString *name = self.images[key];
    if (name.length == 0) {
        return nil;
    }
    
    NSString *path = [[NSFileManager defaultManager] currentDirectoryPath];
    path = [path stringByAppendingPathComponent:self.fileName];
    path = [path stringByAppendingPathComponent:@"image"];
    
    NSArray *suffix = @[[NSString stringWithFormat:@"@%.0fx", [UIScreen mainScreen].scale], @"@3x", @"@2x", @""];
    
    NSString *fileName, *filePath;
    for (NSString *item in suffix) {
        fileName = [[name stringByAppendingString:item] stringByAppendingPathExtension:@"png"];
        filePath = [path stringByAppendingPathComponent:fileName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            return image;
        }
    }
    
    return nil;
}

@end
