//
//  MultiLineLabel.m
//  Bang
//
//  Created by 唐琦 on 2019/1/14.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "MultiLineLabel.h"

@interface MultiLineLabel ()

@end

@implementation MultiLineLabel

- (CGSize)intrinsicContentSize {
    UIEdgeInsets margins = self.layoutMargins;
    if (self.preferredMaxLayoutWidth == 0) {
        self.preferredMaxLayoutWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    }
    
    CGSize size = CGSizeMake(self.preferredMaxLayoutWidth - (margins.left + margins.right), CGFLOAT_MAX);
    if (self.attributedText) {
        CGRect rect = [self.attributedText boundingRectWithSize:size
                                                        options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                        context:nil];
        
        CGSize charSize = [self.attributedText boundingRectWithSize:size
                                                            options:0
                                                            context:nil].size;
        
        NSInteger lines = rect.size.height / charSize.height;
        
        if (self.numberOfLines != 0) {
            lines = MIN(lines, self.numberOfLines);
        }
        
        size = CGSizeMake(CGRectGetWidth(rect) + margins.left + margins.right, charSize.height * lines + margins.top + margins.bottom);
        return size;
    }
    else {
        return [self.text boundingRectWithSize:size
                                       options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                    attributes:@{NSFontAttributeName: self.font}
                                       context:nil].size;
    }
}

@end
