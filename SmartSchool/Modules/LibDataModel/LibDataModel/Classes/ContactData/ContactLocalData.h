//
//  ContactLocalData.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <Contacts/Contacts.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNContact (name)

- (nullable NSString *)name;

@end

@interface CNLabeledValue (label)

- (NSString *)localizedLabel;

@end

@interface ContactLocalData : NSObject

@property (nonatomic, strong)   NSNumber    *uid;
@property (nonatomic, copy)     NSString    *category;
@property (nonatomic, copy)     NSString    *phone;
@property (nonatomic, assign)   NSInteger   section;
@property (nonatomic, copy)     NSString    *title;

@property (nonatomic, copy)     NSString    *sectionKey; 

@property (nonatomic, copy)     NSString    *pinyin;
@property (nonatomic, copy)     NSString    *shengmu;
@property (nonatomic, copy)     NSString    *givenName;
@property (nonatomic, copy)     NSString    *givenPinyin;
@property (nonatomic, copy)     NSString    *orgName;
@property (nonatomic, copy)     NSString    *orgNamePinyin;

+ (instancetype)contactWithData:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
