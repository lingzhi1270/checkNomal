//
//  UserCenterManager.h
//  Module_demo
//
//  Created by 唐琦 on 2019/8/20.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>
#import <LibDataModel/FavData.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserCenterManager : BaseManager

- (FavData *)favWithId:(NSNumber *)uid;

- (FavData *)favWithContent:(NSString *)content;

- (void)requestFavWithAction:(YuCloudDataActions)action
                         uid:(NSNumber *)uid
                        data:(nullable NSDictionary *)data
                  completion:(CommonBlock)completion;

- (void)submitFeedback:(NSString *)feedback
                  name:(NSString *)name
                 phone:(NSString *)phone
                images:(NSArray *)images
            completion:(nullable CommonBlock)completion;

@end

NS_ASSUME_NONNULL_END
