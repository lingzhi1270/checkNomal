//
//  CameraButtonView.h
//  Conversation
//
//  Created by qlon 2019/4/24.
//

#import <LibComponentBase/ConfigureHeader.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CameraButtonViewDelegate <NSObject>
- (void)dismiss;
- (void)removeData;
- (void)sendData;
- (void)takePhoto;
- (void)editAction;
- (void)startTakeVideo;
- (void)stopTakeVideo;

@end

@interface CameraButtonView : UIView
@property (nonatomic, assign) id<CameraButtonViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
