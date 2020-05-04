//
//  CheckGradeData.h
//  AFNetworking
//
//  Created by lingzhi on 2020/1/14.
//

#import <LibComponentBase/ConfigureHeader.h>
NS_ASSUME_NONNULL_BEGIN

@class CheckGradeSubItemData;
@interface CheckGradeData : NSObject
@property (nullable, nonatomic, copy)  NSString         *name;
@property (nullable, nonatomic, strong)NSArray<CheckGradeSubItemData *>  *sub_items;
@property (nullable, nonatomic, strong)NSNumber         *gradeId;
@property (nullable, nonatomic, copy)  NSString         *start_time;
@property (nullable, nonatomic, copy)  NSString         *end_time;
@end

@interface CheckGradeSubItemData : NSObject
@property (nullable, nonatomic, strong)NSNumber         *score_min;
@property (nullable, nonatomic, strong)NSNumber         *subId;
@property (nullable, nonatomic, strong)NSNumber         *score_max;
@property (nullable, nonatomic, copy)  NSString         *name;
@property (nonatomic, assign)BOOL                       is_plus;
@property (nullable, nonatomic, strong)NSNumber         *plus_min;
@property (nullable, nonatomic, strong)NSNumber         *plus_max;
@property (nullable, nonatomic, strong)NSNumber         *score_total;
@end

NS_ASSUME_NONNULL_END
