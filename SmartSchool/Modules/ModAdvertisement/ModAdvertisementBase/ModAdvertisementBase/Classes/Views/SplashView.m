//
//  SplashView.m
//  Unilife
//
//  Created by 唐琦 on 2016/10/26.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "SplashView.h"
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>

static BOOL splashVisible = NO;

@interface SplashViewController : UIViewController

@property (nonatomic, copy) UIImage         *image;
@property (nonatomic, strong) UIImageView   *imageView;

@end

@implementation SplashViewController

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [self init]) {
        self.image = image;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView = [UIImageView new];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.imageView.image = self.image;
}

@end

#pragma mark - SplashView

@interface SplashView () < UIWebViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, VideoPlayerDelegate >
@property (nonatomic, strong)   WebViewJavascriptBridge     *bridge;
@property (nonatomic, strong)   UIImageView                 *placeHolderView;
@property (nonatomic, strong)   UIWebView                   *webView;
@property (nonatomic, strong)   UIImageView                 *imageView;
@property (nonatomic, strong)   VideoPlayerView             *videoView;

@property (nonatomic, strong)   UIPageViewController        *pageViewController;
@property (nonatomic, strong)   NSMutableArray              *arrPages;
@property (nonatomic, strong)   UIImageView                 *backgroundView;
@property (nonatomic, strong)   UIPageControl               *pageControl;
@property (nonatomic, strong)   UIButton                    *btnEnter;

@end

@implementation SplashView

+ (BOOL)splashVisible {
    return splashVisible;
}

+ (void)setSplashVisible:(BOOL)visible {
    splashVisible = visible;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [SplashView setSplashVisible:YES];
    }
    
    return self;
}

- (void)setPlaceHolder:(UIImage *)placeHolder {
    if (!self.placeHolderView) {
        self.placeHolderView = [[UIImageView alloc] init];
        self.placeHolderView.backgroundColor = [UIColor clearColor];
        self.placeHolderView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.placeHolderView];
        
        [self.placeHolderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    [self bringSubviewToFront:self.placeHolderView];
    self.placeHolderView.image = placeHolder;
}

- (void)setZip:(NSString *)zip {
    _zip = [zip copy];
    
    [[ArchiveManager manager] unzipFile:zip
                            destination:nil
                            complection:^(BOOL success, NSString * _Nonnull destination) {
                                if (success) {
                                    NSString *string = [destination stringByAppendingString:@"/preload/index.html"];
                                    self.url = [NSURL URLWithString:string];
                                }
                                else {
                                    [self dismissSplashView:2];
                                }
                            }];
}

- (void)setUrl:(NSURL *)url {
    if (!self.webView) {
        self.webView = [[UIWebView alloc] init];
        [self addSubview:self.webView];
        
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    if (self.placeHolderView) {
        [self bringSubviewToFront:self.placeHolderView];
    }
    
    WEAK(self, wself);
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setWebViewDelegate:wself];
    
    [self.bridge registerHandler:@"doOpenNativePage"
                         handler:^(id data, WVJBResponseCallback responseCallback) {
                             [wself dismissSplashView:0];
                         }];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)setImage:(UIImage *)image {
    [self setImage:image bottomImage:nil];
}

- (void)setImage:(UIImage *)image bottomImage:(UIImage *)bottomImage {
    _image = image.copy;
    
    if (!self.imageView) {
        self.imageView = [UIImageView new];
        self.imageView.alpha = 0;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        if (bottomImage) {
            UIImageView *bottomView = [UIImageView new];
            bottomView.image = bottomImage;
            bottomView.contentMode = UIViewContentModeScaleAspectFill;
            CGFloat ratio = bottomImage.size.height / bottomImage.size.width;
            [self.imageView addSubview:bottomView];
            [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self.imageView);
                make.height.equalTo(bottomView.mas_width).multipliedBy(ratio);
            }];
        }
        
        [self layoutIfNeeded];
    }
    
    self.imageView.image = image;
    
    if (self.placeHolderView) {
        [UIView animateWithDuration:.3
                         animations:^{
                             self.imageView.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             [self.placeHolderView removeFromSuperview];
                             self.placeHolderView = nil;
                         }];

    }
}

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    [self dismissSplashView:delay];
}

- (void)dismissSplashView:(NSTimeInterval)delay {
    [self.delegate finishSplash:self
                          delay:delay
                     completion:^{
                         [SplashView setSplashVisible:NO];
                     }];
    
}

- (void)setImages:(NSArray<UIImage *> *)images {
    _images = [images copy];
    self.backgroundColor = [UIColor whiteColor];
    
    self.backgroundView = [UIImageView new];
    [self addSubview:self.backgroundView];
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    UIImage *image = images.firstObject;
    SplashViewController *view = [[SplashViewController alloc] initWithImage:image];
    self.arrPages = @[view].mutableCopy;
    
    [self.pageViewController setViewControllers:@[view]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    [self addSubview:self.pageViewController.view];
    self.backgroundView.image = [UIImage imageWithColor:self.backgroundColors.firstObject size:CGSizeMake(2, 2)];
    [self.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self).offset(0);
        make.right.equalTo(self);
    }];
    
    self.pageControl = [UIPageControl new];
    self.pageControl.numberOfPages = images.count;
    [self addSubview:self.pageControl];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pageViewController.view.mas_bottom).offset(22);
        make.bottom.equalTo(self).offset(-38);
        make.centerX.equalTo(self);
    }];
    
    self.btnEnter = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnEnter.backgroundColor = [UIColor clearColor];
    [self.btnEnter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    CALayer *layer = self.btnEnter.layer;
    layer.borderWidth = 1.;
    layer.borderColor = [UIColor whiteColor].CGColor;
    layer.cornerRadius = 20;
    layer.masksToBounds = YES;
    
    [self.btnEnter setTitle:@"开始体验" forState:UIControlStateNormal];
    [self.btnEnter addTarget:self action:@selector(touchCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    self.btnEnter.hidden = YES;
    [self addSubview:self.btnEnter];
    [self.btnEnter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.pageControl);
        make.width.equalTo(@128);
        make.height.equalTo(@40);
    }];
    
    if (self.placeHolderView) {
        [self bringSubviewToFront:self.placeHolderView];
        [UIView animateWithDuration:.3
                              delay:1
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             self.placeHolderView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [self.placeHolderView removeFromSuperview];
                             self.placeHolderView = nil;
                         }];
    }
}

- (void)touchCloseBtn {
    [self.videoView pause];
    
    [self hideAnimated:YES afterDelay:0];
}

- (void)setVideoUrl:(NSURL *)videoUrl {
    if (!_videoView) {
        _videoView = [VideoPlayerView new];
        _videoView.delegate = self;
        [self addSubview:_videoView];
        [_videoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self layoutIfNeeded];
    }
    
    if (self.placeHolderView) {
        [self bringSubviewToFront:self.placeHolderView];
        [UIView animateWithDuration:.3
                              delay:1
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             self.placeHolderView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [self.placeHolderView removeFromSuperview];
                             self.placeHolderView = nil;
                         }];
    }
    
    [self.videoView startPlayItemWithUrl:videoUrl repeat:NO];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIView animateWithDuration:1
                     animations:^{
                         self.placeHolderView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.placeHolderView removeFromSuperview];
                     }];
}

#pragma mark - VideoPlayerDelegate

- (void)videoPlayerDidFinished:(VideoPlayerView *)player {
    [self.delegate finishSplash:self
                          delay:.3
                     completion:^{
                         [SplashView setSplashVisible:NO];
                     }];
}

#pragma mark - UIPageViewControllerDataSource, UIPageViewControllerDelegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(SplashViewController *)viewController {
    NSInteger index = [self.arrPages indexOfObject:viewController];
    if (index != NSNotFound && index > 0) {
        return self.arrPages[index - 1];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(SplashViewController *)viewController {
    NSInteger index = [self.arrPages indexOfObject:viewController];
    if (index != NSNotFound && index < self.arrPages.count - 1) {
        return self.arrPages[index + 1];
    }
    
    index = [self.images indexOfObject:viewController.image];
    if (index != NSNotFound && index < self.images.count - 1) {
        SplashViewController *view = [[SplashViewController alloc] initWithImage:self.images[index + 1]];
        [self.arrPages addObject:view];
        
        return view;
    }
    
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    SplashViewController *view = pageViewController.viewControllers.firstObject;
    
    NSInteger index = [self.images indexOfObject:view.image];
    self.pageControl.currentPage = index;
    
    UIImage *image = [UIImage imageWithColor:self.backgroundColors[index] size:CGSizeMake(2, 2)];
    [self.backgroundView setImage:image fade:YES];
    
    if (index >= self.images.count - 1) {
        if (self.btnEnter.hidden) {
            //need to show the button
            self.btnEnter.hidden = NO;
            self.btnEnter.alpha = 0;
            [UIView animateWithDuration:.3
                             animations:^{
                                 self.btnEnter.alpha = 1;
                                 self.pageControl.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 self.pageControl.hidden = YES;
                             }];
        }
    }
    else {
        if (self.pageControl.hidden) {
            //need to hide the button
            self.pageControl.hidden = NO;
            self.pageControl.alpha = 0;
            [UIView animateWithDuration:.3
                             animations:^{
                                 self.btnEnter.alpha = 0;
                                 self.pageControl.alpha = 1;
                             } completion:^(BOOL finished) {
                                 self.btnEnter.hidden = YES;
                             }];
        }
    }
}

- (void)dealloc {
    [self.videoView pause];
}

@end
