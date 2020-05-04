//
//  PreviewModel.h
//  Conversation
//
//  Created by qlon 2019/4/16.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    PreviewTypeImage = 1,
    PreviewTypeVideo,
    PreviewTypeGif
} PreviewType;

@interface PreviewModel : NSObject
@property (nonatomic, strong) NSString      *url;               // 资源链接
@property (nonatomic, strong) UIImage       *image;             // 已下载的图片
@property (nonatomic, strong) UIButton      *tapView;           // 当前点击的图片控件
@property (nonatomic, strong) UIImage       *thumbnailImage;    // 视频缩略图
@property (nonatomic, assign) PreviewType   type;               // 预览类型
@property (nonatomic, assign) BOOL          firstLoad;          // 是否第一次加载

- (instancetype)initWithUrl:(NSString *)url
                      image:(UIImage *)image
                    tapView:(UIButton *)tapView
             thumbnailImage:(UIImage *)thumbnailImage
                       type:(PreviewType)type;

@end

