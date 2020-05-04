//
//  AVPlayer+SeekSmoothly.h
//  Pods
//
//  Created by 唐琦 on 2020/1/9.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVPlayer (SeekSmoothly)

- (void)ss_seekToTime:(CMTime)time;

- (void)ss_seekToTime:(CMTime)time
      toleranceBefore:(CMTime)toleranceBefore
       toleranceAfter:(CMTime)toleranceAfter
    completionHandler:(void (^)(BOOL))completionHandler;

@end

NS_ASSUME_NONNULL_END
