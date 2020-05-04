//
//  ModCommentStyle1CommentView.h
//  Module_demo
//
//  Created by 唐琦 on 2019/9/16.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ModCommentStyle1CommentViewDelegate <NSObject>

- (void)didConfirmComment:(NSString *)commentString;

@end

@interface ModCommentStyle1CommentView : UIView
@property (nonatomic, assign) BOOL isReply;
@property (nonatomic, weak) id<ModCommentStyle1CommentViewDelegate> delegate;

- (void)showView;

@end

NS_ASSUME_NONNULL_END
