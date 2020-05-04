//
//  VideoPlayView.h
//  Conversation
//
//  Created by qlon 2019/4/16.
//

#import <LibComponentBase/ConfigureHeader.h>
#import "PreviewModel.h"

typedef enum : NSUInteger {
    VideoTypeNormal,
    VideoTypePreview
} VideoType;

@interface VideoPlayView : UIView
@property (nonatomic, strong) UIImageView   *thumbnailImageView;

- (instancetype)initWithFrame:(CGRect)frame model:(PreviewModel *)model type:(VideoType)type;
- (void)play;
- (void)pause;
- (void)replacePlayWithUrl:(NSURL *)url;

@end
