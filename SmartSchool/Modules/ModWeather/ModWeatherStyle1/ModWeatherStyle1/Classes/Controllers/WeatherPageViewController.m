//
//  WeatherPageViewController.m
//  Unilife
//
//  Created by 唐琦 on 2019/7/2.
//  Copyright © 2019年 南京远御网络科技有限公司. All rights reserved.
//

#import "WeatherPageViewController.h"
#import <ModWeatherBase/WeatherManager.h>

@interface WeatherCityCell : UICollectionViewCell

@property (nonatomic, copy) NSString        *name;

@property (nonatomic, strong) UILabel       *nameLabel;

@end

@implementation WeatherCityCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.nameLabel = [UILabel new];
        self.nameLabel.font = [UIFont systemFontOfSize:28];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [CONTENT_VIEW addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(8);
            make.top.equalTo(CONTENT_VIEW);
            make.bottom.equalTo(CONTENT_VIEW);
            make.right.equalTo(CONTENT_VIEW);
        }];
    }
    
    return self;
}

- (void)setName:(NSString *)name {
    self.nameLabel.text = name;
}

@end

#pragma mark - WeatherLiveCell

@interface WeatherLiveCell : UICollectionViewCell

@property (nonatomic, copy)   NSDictionary  *weather;

@property (nonatomic, strong) UILabel       *temperatureLabel;
@property (nonatomic, strong) UILabel       *weatherLabel;
@property (nonatomic, strong) UILabel       *humidityLabel;
@property (nonatomic, strong) UILabel       *windLabel;

@end

@implementation WeatherLiveCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.temperatureLabel = [UILabel new];
        self.temperatureLabel.font = [UIFont systemFontOfSize:68];
        self.temperatureLabel.textColor = [UIColor whiteColor];
        [CONTENT_VIEW addSubview:self.temperatureLabel];
        [self.temperatureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(8);
            make.top.equalTo(CONTENT_VIEW).offset(8);
        }];
        
        self.weatherLabel = [UILabel new];
        self.weatherLabel.font = [UIFont systemFontOfSize:32];
        self.weatherLabel.textColor = [UIColor whiteColor];
        [CONTENT_VIEW addSubview:self.weatherLabel];
        [self.weatherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.temperatureLabel.mas_right).offset(8);
            make.top.equalTo(self.temperatureLabel);
        }];
        
        self.humidityLabel = [UILabel new];
        self.humidityLabel.textColor = [UIColor whiteColor];
        self.humidityLabel.font = [UIFont systemFontOfSize:16];
        [CONTENT_VIEW addSubview:self.humidityLabel];
        [self.humidityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(8);
            make.top.equalTo(self.temperatureLabel.mas_bottom).offset(8);
        }];
        
        self.windLabel = [UILabel new];
        self.windLabel.textColor = [UIColor whiteColor];
        self.windLabel.font = [UIFont systemFontOfSize:16];
        [CONTENT_VIEW addSubview:self.windLabel];
        [self.windLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.humidityLabel.mas_right).offset(8);
            make.top.equalTo(self.humidityLabel);
        }];
    }
    
    return self;
}

- (void)setWeather:(NSDictionary *)weather {
    self.temperatureLabel.text = weather[@"temperature"];
    self.weatherLabel.text = weather[@"weather"];
    self.humidityLabel.text = weather[@"humidity"];
    self.windLabel.text = weather[@"wind"];
}

@end

@interface WeatherForecastCell : UICollectionViewCell

@property (nonatomic, copy)   NSDictionary  *weather;

@property (nonatomic, strong) UILabel       *dateLabel;
@property (nonatomic, strong) UILabel       *temperatureLabel;
@property (nonatomic, strong) UILabel       *weatherLabel;
@property (nonatomic, strong) UIImageView   *weatherImageView;

@end

@implementation WeatherForecastCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorAlphaFromHex:0x00000050];
        
        self.dateLabel = [UILabel new];
        self.dateLabel.textColor = [UIColor whiteColor];
        [CONTENT_VIEW addSubview:self.dateLabel];
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(CONTENT_VIEW).offset(8);
            make.top.equalTo(CONTENT_VIEW);
            make.bottom.equalTo(CONTENT_VIEW.mas_centerY);
        }];
        
        self.temperatureLabel = [UILabel new];
        self.temperatureLabel.textAlignment = NSTextAlignmentRight;
        self.temperatureLabel.textColor = [UIColor whiteColor];
        [CONTENT_VIEW addSubview:self.temperatureLabel];
        [self.temperatureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.dateLabel.mas_right);
            make.top.equalTo(CONTENT_VIEW);
            make.bottom.equalTo(CONTENT_VIEW.mas_centerY);
            make.right.equalTo(CONTENT_VIEW).offset(-8);
        }];
        
        self.weatherLabel = [UILabel new];
        self.weatherLabel.font = [UIFont systemFontOfSize:14];
        self.weatherLabel.textColor = [UIColor whiteColor];
        [CONTENT_VIEW addSubview:self.weatherLabel];
        [self.weatherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.dateLabel);
            make.top.equalTo(CONTENT_VIEW.mas_centerY);
            make.bottom.equalTo(CONTENT_VIEW);
        }];
        
        self.weatherImageView = [UIImageView new];
        self.weatherImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [CONTENT_VIEW addSubview:self.weatherImageView];
        [self.weatherImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.weatherLabel.mas_right).offset(-8);
            make.right.equalTo(self.temperatureLabel);
            make.top.equalTo(self.temperatureLabel.mas_bottom);
            make.bottom.equalTo(CONTENT_VIEW).offset(-8);
            make.width.equalTo(self.weatherImageView.mas_height);
        }];
        
        UIView *sepLine = [UIView new];
        sepLine.backgroundColor = [UIColor colorAlphaFromHex:0xfffffff0];
        [CONTENT_VIEW addSubview:sepLine];
        [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(CONTENT_VIEW).offset(1);
            make.top.equalTo(CONTENT_VIEW).offset(8);
            make.bottom.equalTo(CONTENT_VIEW).offset(-8);
            make.width.equalTo(@1.);
        }];
    }
    
    return self;
}

- (void)setWeather:(NSDictionary *)weather future:(NSInteger)futureIndex {
    NSDictionary *future = weather[@"future"][futureIndex];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"H:mm";
    
    NSDate *sunrise = [formatter dateFromString:weather[@"sunrise"]];
    NSDate *sunset = [formatter dateFromString:weather[@"sunset"]];
    
    NSDate *now = [NSDate date];
    BOOL day = NO;
    if (now.hour > sunrise.hour && now.hour < sunset.hour) {
        day = YES;
    }
    
    self.dateLabel.text = future[@"week"];
    self.temperatureLabel.text = future[@"temperature"];
    
    NSString *string = day?future[@"dayTime"]:future[@"night"];
    self.weatherLabel.text = string;
    NSString *imageUrl = [[WeatherManager shareManager] iconForWeather:string date:[NSDate date]];
    if (imageUrl.length) {
        [self.weatherImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                                 placeholderImage:nil
                                        completed:nil];
    }
    else {
        self.weatherImageView.image = nil;
//        DDLog(@"icon not define for: %@", string);
    }
}

@end

@interface WeatherForecastView : UICollectionViewCell < UICollectionViewDataSource, UICollectionViewDelegateFlowLayout >

@property (nonatomic, copy) NSDictionary        *weather;

@property (nonatomic, strong) UICollectionView  *collectionView;

@end

@implementation WeatherForecastView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorAlphaFromHex:0x00000050];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                 collectionViewLayout:layout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[WeatherForecastCell class]
                forCellWithReuseIdentifier:[WeatherForecastCell reuseIdentifier]];
        
        [CONTENT_VIEW addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(CONTENT_VIEW);
        }];
    }
    
    return self;
}

- (void)setWeather:(NSDictionary *)weather {
    _weather = weather.copy;
    
    [self.collectionView reloadData];
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *future = self.weather[@"future"];
    return future.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:[WeatherForecastCell reuseIdentifier]
                                                     forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    CGFloat height = CGRectGetHeight(collectionView.bounds);
    return CGSizeMake(width / 2.1, height);
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(WeatherForecastCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell setWeather:self.weather future:indexPath.item];
}

@end

#pragma mark - ModWeatherStyle1ViewController

typedef enum : NSUInteger {
    WeatherSectionCity = 0,
    WeatherSectionLive,
    WeatherSectionForecast,
    WeatherSectionLife,
    
} WeatherSections;

@interface WeatherPageViewController () < UICollectionViewDataSource, UICollectionViewDelegateFlowLayout >

@property (nonatomic, strong) NSArray               *data;

@property (nonatomic, strong) CityData              *city;
@property (nonatomic, strong) UICollectionView      *collectionView;

@end

@implementation WeatherPageViewController

- (instancetype)initWithCity:(CityData *)city {
    if (self = [self init]) {
        self.city = city;
        
        if (city) {
            [[WeatherManager shareManager] requestWeatherWithCity:city
                                                       completion:^(BOOL success, NSDictionary * _Nullable info) {
                                                           if (success) {
                                                               if (self.collectionView) {
                                                                   [self.collectionView reloadData];
                                                               }
                                                           }
                                                       }];
        }
    }
    
    return self;
}

- (void)loadView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.collectionView registerClass:[WeatherCityCell class]
            forCellWithReuseIdentifier:[WeatherCityCell reuseIdentifier]];
    
    [self.collectionView registerClass:[WeatherLiveCell class]
            forCellWithReuseIdentifier:[WeatherLiveCell reuseIdentifier]];
    
    [self.collectionView registerClass:[WeatherForecastView class]
            forCellWithReuseIdentifier:[WeatherForecastView reuseIdentifier]];
    
    [self.collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:[UICollectionViewCell reuseIdentifier]];
    
    [view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.right.equalTo(view);
        make.top.equalTo(view).offset(64);
        make.bottom.equalTo(view);
    }];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = @[@(WeatherSectionCity), @(WeatherSectionLive), @(WeatherSectionForecast)];
}

- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeTop;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.data.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [UICollectionViewCell reuseIdentifier];
    NSNumber *number = self.data[indexPath.section];
    switch ([number integerValue]) {
        case WeatherSectionCity:
            reuseIdentifier = [WeatherCityCell reuseIdentifier];
            break;
            
        case WeatherSectionLive:
            reuseIdentifier = [WeatherLiveCell reuseIdentifier];
            break;
            
        case WeatherSectionForecast:
            reuseIdentifier = [WeatherForecastView reuseIdentifier];
            break;
            
        case WeatherSectionLife:
            reuseIdentifier = [UICollectionViewCell reuseIdentifier];
            break;
            
        default:
            break;
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    CGFloat height = CGRectGetHeight(collectionView.bounds);
    
    NSNumber *number = self.data[indexPath.section];
    switch ([number integerValue]) {
        case WeatherSectionCity:
            return CGSizeMake(width, 48);
            
        case WeatherSectionLive:
            return CGSizeMake(width, height - 48 - 98);
            
        case WeatherSectionForecast:
            return CGSizeMake(width, 98);
            
        case WeatherSectionLife:
            return CGSizeMake(width, 120);
            
        default:
            return CGSizeMake(width, height / 10);
    }
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *number = self.data[indexPath.section];
    switch ([number integerValue]) {
        case WeatherSectionCity: {
            WeatherCityCell *city = (WeatherCityCell *)cell;
            city.name = self.city.district;
        }
            break;
            
        case WeatherSectionLive: {
            WeatherLiveCell *liveCell = (WeatherLiveCell *)cell;
            liveCell.weather = self.city.weather;
        }
            break;
            
        case WeatherSectionForecast: {
            WeatherForecastView *forecastView = (WeatherForecastView *)cell;
            forecastView.weather = self.city.weather;
        }
            break;
            
        default:
            break;
    }
}


@end
