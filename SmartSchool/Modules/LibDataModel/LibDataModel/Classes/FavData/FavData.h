//
//  FavData.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface FavData : NSObject

@property (nonatomic)                   NSInteger   uid;
@property (nullable, nonatomic, copy)   NSString    *content;
@property (nullable, nonatomic, copy)   NSString    *overview;
@property (nullable, nonatomic, copy)   NSString    *imageUrl;
@property (nullable, nonatomic, copy)   NSString    *title;
@property (nullable, nonatomic, copy)   NSString    *type;

+ (instancetype)favWithData:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
