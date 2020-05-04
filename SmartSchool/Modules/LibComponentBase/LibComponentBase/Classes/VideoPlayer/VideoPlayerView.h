//
//  VideoPlayerView.h
//  Unilife
//
//  Created by 唐琦 on 2019/6/23.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class VideoPlayerView;

@protocol VideoPlayerDelegate <NSObject>

- (void)videoPlayerDidFinished:(VideoPlayerView *)player;

@end

@interface VideoPlayerView : UIView

@property (nonatomic, weak) id<VideoPlayerDelegate>     delegate;

- (void)startPlayItemWithUrl:(NSURL *)url repeat:(BOOL)repeat;

- (void)pause;

@end
