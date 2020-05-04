//
//  ContactLocalData.m
//  Module_demo
//
//  Created by 唐琦 on 2019/8/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import "ContactLocalData.h"

@implementation CNContact (name)

- (NSString *)name {
    if (self.familyName.length || self.givenName.length) {
        return [NSString stringWithFormat:@"%@%@", self.familyName?:@"", self.givenName?:@""];
    }
    else if (self.organizationName.length) {
        return self.organizationName;
    }
    else {
        return @"no name";
    }
}

@end

@implementation CNLabeledValue (label)

- (NSString *)localizedLabel {
    NSString *label = self.label;
    if ([label isEqualToString:@"_$!<Mobile>!$_"]) {
        return @"手机";
    }
    
    return label;
}

@end

@implementation ContactLocalData
                      
@end
