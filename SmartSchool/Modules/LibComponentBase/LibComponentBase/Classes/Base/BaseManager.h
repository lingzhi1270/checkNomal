//
//  BaseManager.h
//  Conversation
//
//  Created by ql on 2019/1/15.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ShareMediaType) {
    ShareMediaText,
    ShareMediaImage,
    ShareMediaMusic,
    ShareMediaVideo,
    ShareMediaUrl
};

typedef NS_ENUM(NSUInteger, ShareActivity) {
    ShareToWechatFriends,
    ShareToWechatMoments,
    ShareToQQFriends,
    ShareToQQZone,
    
    ShareFavourite,
    ShareEdit,
    ShareDelete,
    ShareCopyURL,
    ShareSaveImage
};

typedef void(^ShareCompletionBlock)(BOOL completed, ShareActivity activity);

typedef enum : NSUInteger {
    CameraTypeDefault,
    CameraTypeBack,
    CameraTypeFront,
} CameraType;

typedef enum : NSUInteger {
    SourceTypeDefault,
    SourceTypePhoto = SourceTypeDefault,
    SourceTypeVideo,
} SourceType;

typedef enum : NSUInteger {
    NavigationTypeDrive,
    NavigationTypeRide,
    NavigationTypeWalk,
} NavigationType;

@interface BaseManager : NSObject

+ (instancetype)shareManager;

@end

