//
//  CameraData.h
//  Unilife
//
//  Created by 唐琦 on 2019/9/7.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraTaskData : NSObject
@property (nonatomic, assign) long long uid;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, assign) long long  finished;
@property (nonatomic, assign) long long  total;
@property (nullable, nonatomic, copy) NSDate *datePub;
@property (nullable, nonatomic, copy) NSDate *dateEnd;

+ (instancetype)taskWithData:(NSDictionary *)data;

@end

@interface CameraPhotoData : NSObject
@property (nonatomic) NSInteger                 uid;
@property (nonatomic) NSInteger                 taskid;
@property (nullable, nonatomic, copy) NSString  *name;
@property (nullable, nonatomic, copy) NSString  *image_url;
@property (nullable, nonatomic, copy) NSString  *number;

+ (instancetype)dataWithData:(NSDictionary *)data;

@end


NS_ASSUME_NONNULL_END

