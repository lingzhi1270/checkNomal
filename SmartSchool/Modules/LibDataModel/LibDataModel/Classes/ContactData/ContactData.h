//
//  ContactData.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactData : NSObject

@property (nonatomic, strong)   NSNumber    *uid;
@property (nonatomic, copy)     NSString    *category;
@property (nonatomic, copy)     NSString    *phone;
@property (nonatomic, assign)   NSInteger   section;
@property (nonatomic, copy)     NSString    *title;
@property (nonatomic, assign)   NSInteger   index;
@property (nonatomic, copy)     NSString    *avatarUrl;
@property (nonatomic, copy)     NSString    *placeholder;
@property (nonatomic, copy)     NSString    *note;
@property (nonatomic, copy)     NSString    *shortNo;
@property (nonatomic, copy)     NSString    *email;

@property (nonatomic, assign)   NSInteger   status;
@property (nonatomic, copy)     NSString    *sectionKey; 

@property (nonatomic, copy)     NSString    *pinyin;
@property (nonatomic, copy)     NSString    *shengmu;
@property (nonatomic, copy)     NSString    *givenName;
@property (nonatomic, copy)     NSString    *givenPinyin;
@property (nonatomic, copy)     NSString    *orgName;
@property (nonatomic, copy)     NSString    *orgNamePinyin;

+ (instancetype)contactWithData:(NSDictionary *)data;

@end

@interface ContactStatusData : NSObject

@property (nonatomic, assign) NSInteger     uid;
@property (nonatomic, copy)   NSString      *title;
@property (nonatomic, copy)   UIColor       *color;

+ (instancetype)statusWithData:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
