//
//  AdData.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/26.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "AdData.h"

@implementation AdData

+ (instancetype)splashWithData:(NSDictionary *)data {
    return [[self alloc] initSplashWithData:data];
}

- (instancetype)initSplashWithData:(NSDictionary *)data {
    if (self = [self init]) {
        self.type = AdsSplash;
        NSString *string = data[@"cycle_mode"];
        if ([string isEqualToString:@"once"]) {
            self.cycle = AdsCycleOnce;
        }
        else if ([string isEqualToString:@"daily"]) {
            self.cycle = AdsCycleDaily;
        }
        else if ([string isEqualToString:@"weekly"]) {
            self.cycle = AdsCycleWeekly;
        }
        else if ([string isEqualToString:@"hourly"]) {
            self.cycle = AdsCycleHourly;
        }
        else {
//            DDLog(@"not supported mode: %@", string);
        }
        
        NSString *url = VALIDATE_STRING(data[@"media_url"]);
        NSString *type = VALIDATE_STRING(data[@"media_type"]);
        if ([type isEqualToString:@"video"]) {
            self.mediaVideo = YES;
            self.mediaUrl = url;
        }
        else {
            self.mediaVideo = NO;
            self.mediaUrl = [self urlOfThumbWithSize:CGSizeMake(1080, 1080)
                                                mode:UIViewContentModeScaleAspectFit
                                                type:nil
                                              forUrl:url];
        }
        
        self.targetUrl = data[@"target_url"];
        self.targetType = data[@"target_type"];
        
        NSNumber *number = data[@"uid"];
        self.uid = [number integerValue];
        
        number = data[@"time_on"];
        if (number) {
            self.timeOn = [NSDate dateWithTimeIntervalSince1970:[number integerValue]];
        }
        
        number = data[@"time_off"];
        if (number) {
            self.timeOff = [NSDate dateWithTimeIntervalSince1970:[number integerValue]];
        }
        
        number = data[@"duration"];
        if (number) {
            self.duration = [number integerValue];
        }
    }
    
    return self;
}

- (NSString *)urlOfThumbWithSize:(CGSize)size
                            mode:(UIViewContentMode)mode
                            type:(NSString *)type
                          forUrl:(NSString *)urlString {
    if (![urlString containsString:@".aliyuncs.com"]) {
        return urlString;
    }

    switch (mode) {
        case UIViewContentModeScaleAspectFit: {
            // 按长边缩略
            return [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_lfit,w_%ld,h_%ld/format,%@", urlString, (long)size.width, (long)size.height, type?:@"jpg"];
        }
            
        case UIViewContentModeScaleAspectFill: {
            // 按短边压缩
            return [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_mfit,w_%ld,h_%ld/format,%@", urlString, (long)size.width, (long)size.height, type?:@"jpg"];
        }
            break;
            
        default: {
            // 按短边压缩，居中裁剪
            return [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fill,w_%ld,h_%ld/format,%@", urlString, (long)size.width, (long)size.height, type?:@"jpg"];
        }
    }
}

@end

