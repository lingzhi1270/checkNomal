//
//  ModWeatherStyle1ViewController.m
//  Unilife
//
//  Created by 唐琦 on 2019/7/2.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "ModWeatherStyle1ViewController.h"
#import "WeatherOptionsViewController.h"
#import "WeatherPageViewController.h"
#import <ModWeatherBase/WeatherManager.h>
#import <CoreLocation/CoreLocation.h>
#import <LibTheme/ThemeManager.h>
#import <LibDataModel/CityData.h>

@interface ModWeatherStyle1ViewController () < UIPageViewControllerDataSource, UIPageViewControllerDelegate, WeatherOptionsDelegate >
@property (nonatomic, strong) UIImageView               *backgroundView;
@property (nonatomic, strong) UIPageViewController      *pageViewController;
@property (nonatomic, strong) NSMutableArray            *arrPages;

@property (nonatomic, copy)   NSArray<CityData *>       *cities;
@property (nonatomic, strong) CLLocationManager         *locationManager;

@end

@implementation ModWeatherStyle1ViewController

- (void)loadView {
    UIView *view = [UIView new];
    
    UIView *squareView = [UIView new];
    [view addSubview:squareView];
    CALayer *layer = squareView.layer;
    layer.borderColor = THEME_TEXT_PRIMARY_COLOR.CGColor;
    layer.borderWidth = .5;
    layer.cornerRadius = 6;
    [squareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(32);
        make.right.equalTo(view).offset(-32);
        make.height.equalTo(squareView.mas_width).multipliedBy(.5);
        make.centerY.equalTo(view);
    }];
    
    [squareView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(appShowOptions)]];
    
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = THEME_TEXT_PRIMARY_COLOR;
    label.numberOfLines = 3;
    label.text = @"当前城市列表为空，请点触此处选择你想要关注的城市";
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(squareView).offset(16);
        make.right.equalTo(squareView).offset(-16);
        make.centerY.equalTo(squareView);
    }];
    
    self.backgroundView = [UIImageView new];
    self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundView.layer.masksToBounds = YES;
    
    [view addSubview:self.backgroundView];
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    [view addSubview:self.pageViewController.view];
    [self.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestWhenInUseAuthorization];
    
    [[WeatherManager shareManager] cityDataWithCompletion:^(BOOL success, NSDictionary * _Nullable info) {
        [self dataChangedWithCity:nil];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)dataChangedWithCity:(nullable CityData *)oneCity {
    self.cities = [[WeatherManager shareManager] allCitiesWithSelected:YES];
    CityData *city = self.cities.firstObject;
    if (oneCity) {
        for (CityData *item in self.cities) {
            if ([item.district isEqualToString:oneCity.district] && [item.city isEqualToString:oneCity.city]) {
                city = item;
                break;
            }
        }
    }
    
    dispatch_async_on_main_queue(^{
        WeatherPageViewController *page = [[WeatherPageViewController alloc] initWithCity:city];
        self.arrPages = @[page].mutableCopy;
        
        [self.pageViewController setViewControllers:@[page]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO completion:nil];
        if (self.cities.count) {
            WeatherPageViewController *page = [[WeatherPageViewController alloc] initWithCity:city];
            self.arrPages = @[page].mutableCopy;
            
            self.pageViewController.view.hidden = NO;
            self.backgroundView.hidden = NO;
            
            WEAK(self, wself);
            [self.pageViewController setViewControllers:@[page]
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:NO
                                             completion:^(BOOL finished) {
                                                 [wself upadateBackImage:city.weather];
                                             }];
        }
        else {
            self.arrPages = nil;
            self.pageViewController.view.hidden = YES;
            self.backgroundView.hidden = YES;
        }
    });
}

- (void)upadateBackImage:(NSDictionary *)weather {
    NSString *string = [[WeatherManager shareManager] imageForWeather:weather[@"weather"] date:[NSDate date]];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:string];
    if (image) {
        [self.backgroundView setImage:image fade:YES];
    }
    else {
//        DDLog(@"");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeTop;
}

- (void)appShowOptions {
    NSArray *resultArray = [[WeatherManager shareManager] allCitiesWithSelected:NO];
    if (resultArray.count > 0) {
        dispatch_async_on_main_queue(^{
            WeatherOptionsViewController *options = [[WeatherOptionsViewController alloc] init];
            options.delegate = self;
            [self.navigationController pushViewController:options animated:YES];
        });
    }
}

- (void)appShowLoading:(BOOL)show {
    
}

#pragma mark - UIPageViewControllerDataSource, UIPageViewControllerDelegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(WeatherPageViewController *)viewController {
    NSUInteger index = [self.arrPages indexOfObject:viewController];
    if (index > 0) {
        return self.arrPages[index - 1];
    }
    
    NSArray *cities = self.cities;
    index = [cities indexOfObject:viewController.city];
    if (index != NSNotFound && index > 0) {
        WeatherPageViewController *page = [[WeatherPageViewController alloc] initWithCity:cities[index - 1]];
        [self.arrPages insertObject:page atIndex:0];
        return page;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(WeatherPageViewController *)viewController {
    NSUInteger index = [self.arrPages indexOfObject:viewController];
    if (index < self.arrPages.count - 1) {
        return self.arrPages[index + 1];
    }
    
    NSArray *cities = self.cities;
    index = [cities indexOfObject:viewController.city];
    if (index != NSNotFound && index < cities.count - 1) {
        WeatherPageViewController *page = [[WeatherPageViewController alloc] initWithCity:cities[index + 1]];
        [self.arrPages addObject:page];
        return page;
    }
    
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<WeatherPageViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    
    WeatherPageViewController *page = pageViewController.viewControllers.firstObject;
    [self upadateBackImage:page.city.weather];
}

#pragma mark - WeatherOptionsDelegate

- (void)weatherSelectCity:(CityData *)city {
    [self dataChangedWithCity:city];
}

@end
