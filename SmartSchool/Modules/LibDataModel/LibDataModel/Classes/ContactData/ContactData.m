//
//  ContactData.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "ContactData.h"

@implementation ContactData

+ (instancetype)contactWithData:(NSDictionary *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSDictionary *)data {
    if(self = [self init]) {
        self.uid = VALIDATE_NUMBER(data[@"uid"]);
        self.category = VALIDATE_STRING_WITH_DEFAULT(data[@"category"], @"");
        self.phone = VALIDATE_STRING(data[@"phone"]);
        NSNumber *number = VALIDATE_NUMBER(data[@"section"]);
        self.section = [number integerValue];
        
        NSString *title = VALIDATE_STRING(data[@"title"]);
        self.title = [title stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSString *string = VALIDATE_STRING(data[@"avatar_url"]);
        if (string.length && ![string containsString:@"%"]) {
            string = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        }
        self.avatarUrl = string;
        
        number = VALIDATE_NUMBER_WITH_DEFAULT(data[@"index"], @(10));
        self.index = [number integerValue];
        
        self.note = VALIDATE_STRING(data[@"note"]);
        self.shortNo = VALIDATE_STRING(data[@"short_no"]);
        self.email = VALIDATE_STRING(data[@"email"]);
        
        number = VALIDATE_NUMBER(data[@"status"]);
        self.status = [number integerValue];
        
        if (!self.uid || self.title.length == 0) {
            return nil;
        }
    }
    
    return self;
}

- (NSString *)cacheKey {
    if (self.avatarUrl.length) {
        return [NSString stringWithFormat:@"%@-cached", self.avatarUrl];
    }
    
    return nil;
}

@end

@implementation ContactStatusData

+ (instancetype)statusWithData:(NSDictionary *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        NSNumber *uid = data[@"uid"];
        self.uid = [uid integerValue];
        
        self.title = data[@"title"];
        
        NSString *string = data[@"color"];
        self.color = [self colorFromString:string];
    }
    
    return self;
}

- (UIColor *)colorFromString:(NSString *)string {
  if (string.length == 0) {
      return [UIColor clearColor];
  }
  
  if (![string containsString:@"0x"]) {
      string = [@"0x" stringByAppendingString:string];
  }
  
  if (string.length == 8) {
      long long value = 0;
      sscanf([string cStringUsingEncoding:NSASCIIStringEncoding], "%llx", &value);
      
      return [UIColor colorWithRGB:value];
  }
  
  return [UIColor clearColor];
}
                      
@end
