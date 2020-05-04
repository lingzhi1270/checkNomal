//
//  RecordManager.h
//  Module_demo
//
//  Created by 唐琦 on 2019/9/2.
//  Copyright © 2019 唐琦. All rights reserved.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RecordManagerDelegate <NSObject>
// 录音中音量变化
- (void)recordVolumneChanged:(float)volumne;
// 录音结束
- (void)recordFinish:(NSData *)audioData;
// 录音失败
- (void)recordFailed:(NSError *)error;

@end

@interface RecordManager : BaseManager
@property (nonatomic, assign) id<RecordManagerDelegate> delegate;
// 开始录音
- (void)startVoiceRecord;
// 结束录音
- (void)finishVoiceRecord;

@end

NS_ASSUME_NONNULL_END
