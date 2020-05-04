//
//  CameraBrowseViewController.m
//  Unilife
//
//  Created by 唐琦 on 2019/9/14.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "CameraBrowseViewController.h"
#import "CameraManager.h"

@interface CameraPageView : UIViewController < UIScrollViewDelegate >

@property (nonatomic, strong) CameraPhotoData   *photo;

@property (nonatomic, strong) UIScrollView      *scrollView;
@property (nonatomic, strong) UIImageView       *imageView;

@property (nonatomic, copy)   UIImage           *image;

@end

@implementation CameraPageView

- (instancetype)initWithPhoto:(CameraPhotoData *)photo {
    if (self = [super init]) {
        self.photo = photo;
    }
    
    return self;
}

- (void)loadView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.bounces = YES;
    self.scrollView.layer.anchorPoint = CGPointMake(.5, .5);
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 3.;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.clipsToBounds = NO;
    
    [self.scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    self.scrollView.layer.masksToBounds = YES;
    [view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    self.imageView = [UIImageView new];
    self.imageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.imageView];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:self.photo.image_url];
    if (image) {
        self.image = image;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)setImage:(UIImage *)image {
    CGSize contentSize = CGSizeMake(image.size.width, image.size.height);
    
    self.imageView.image = image;
    self.imageView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    
    self.scrollView.contentSize = contentSize;
    
    CGFloat zoomScale = CGRectGetWidth([UIScreen mainScreen].bounds) / self.scrollView.contentSize.width;
    self.scrollView.minimumZoomScale = zoomScale;
    [self.scrollView setZoomScale:zoomScale animated:NO];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end

@interface CameraBrowseViewController () < UIPageViewControllerDataSource, UIPageViewControllerDelegate >

@property (nonatomic, assign) NSInteger                 taskid;
@property (nonatomic, assign) CameraPhotoData           *photo;

@property (nonatomic, strong) UIPageViewController      *pageViewController;
@property (nonatomic, strong) NSMutableArray            *arrPages;

@property (nonatomic, copy)   NSArray<CameraPhotoData *>    *photos;

@end

@implementation CameraBrowseViewController

- (instancetype)initWithTask:(NSInteger)taskid photo:(NSInteger)photoid {
    if (self = [self init]) {
        self.taskid = taskid;
        
        [[CameraManager shareManager] photosWithTask:taskid completion:^(BOOL success, NSArray * _Nullable resultArray) {
            self.photos = resultArray;
            for (CameraPhotoData *item in self.photos) {
                if (item.uid == photoid) {
                    self.photo = item;
                    break;
                }
            }
        }];
    }
    
    return self;
}

- (void)loadView {
    ThemeView *view = [ThemeView new];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [view addSubview:self.pageViewController.view];
    [self.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.right.equalTo(view);
        make.top.equalTo(view).offset(64);
        make.bottom.equalTo(view);
    }];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"浏览";
    
    CameraPageView *page = [[CameraPageView alloc] initWithPhoto:self.photo];
    self.arrPages = @[page].mutableCopy;
    [self.pageViewController setViewControllers:@[page]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPageViewControllerDataSource, UIPageViewControllerDelegate
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController
               viewControllerBeforeViewController:(CameraPageView *)viewController {
    NSInteger index = [self.arrPages indexOfObject:viewController];
    if (index > 0) {
        return self.arrPages[index - 1];
    }
    else {
        index = [self.photos indexOfObject:viewController.photo];
        if (index > 0) {
            CameraPhotoData *photo = self.photos[index - 1];
            CameraPageView *page = [[CameraPageView alloc] initWithPhoto:photo];
            [self.arrPages insertObject:page atIndex:0];
            
            return page;
        }
    }
    
    return nil;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController
                viewControllerAfterViewController:(CameraPageView *)viewController {
    NSInteger index = [self.arrPages indexOfObject:viewController];
    if (index < self.arrPages.count - 1) {
        return self.arrPages[index + 1];
    }
    else {
        index = [self.photos indexOfObject:viewController.photo];
        if (index < self.photos.count - 1) {
            CameraPhotoData *photo = self.photos[index + 1];
            CameraPageView *page = [[CameraPageView alloc] initWithPhoto:photo];
            [self.arrPages addObject:page];
            
            return page;
        }
    }
    
    return nil;
}

@end
