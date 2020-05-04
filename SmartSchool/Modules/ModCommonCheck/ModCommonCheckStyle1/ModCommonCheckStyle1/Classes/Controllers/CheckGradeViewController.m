//
//  CheckGradeViewController.m
//  AFNetworking
//
//  Created by lingzhi on 2020/1/13.
//

#import "CheckGradeViewController.h"
#import "GradeCell.h"
#import "GradeProofImageCell.h"
#import "GradeProofVideoCell.h"
#import <ModCommonCheckBase/CommonCheckManager.h>
#import <LibDataModel/CheckGradeData.h>
#import <ModCommonCheckBase/ACMediaPickerManager.h>
#import <LibUpload/UploadManager.h>

#import "CommitCheckSuccessViewController.h"
@interface CheckGradeViewController ()<UITableViewDelegate, UITableViewDataSource,GradeProofImageCellDelegate,GradeProofVideoCellDelegate,GradeCellDelegate,UITextViewDelegate>
{
    int _integer;
    int _score_max;//最大减分数
    int _plus_max;//最大加分数
}
@property (nonatomic ,strong)UITableView *tableView;
/**
 *表head控件
 */
@property (nonatomic, strong) UIImageView       *imageView;
@property (nonatomic, strong) UILabel           *cheackAdminLabel;
@property (nonatomic, strong) UILabel           *cheackTimeLabel;
@property (nonatomic, strong) UILabel           *cheackTailLabel;

/**
 *表foot控件
 */
@property (nonatomic, strong)IQTextView *textView;



@property (nonatomic, strong)NSMutableArray     *subGradeDataArray;

@property (nonatomic, assign)int     maxImageAndVideoCount;


///记录已选中的媒体图片资源
@property (nonatomic, strong) NSMutableArray *selectedImageArray;
///需要先定义一个属性，防止临时变量被释放
@property (nonatomic, strong) ACMediaPickerManager *chooseImageManager;

///记录已选中的媒体视频资源
@property (nonatomic, strong) NSMutableArray *selectedVideoArray;

@property (nonatomic, strong) ACMediaPickerManager *chooseVideoManager;


//提交信息记录
@property (nonatomic, strong) NSMutableArray *commitGradeResultArray;

@property (nonatomic, strong) NSMutableArray *commitImageUrlArray;

@property (nonatomic, strong) NSMutableArray *commitVideoUrlArray;


@end

@implementation CheckGradeViewController

- (void)loadView
{
    [super loadView];
     self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KTopViewHeight, SCREENWIDTH, SCREENHEIGHT-KTopViewHeight-60) style:UITableViewStylePlain];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self.tableView registerClass:[GradeCell class] forCellReuseIdentifier:@"GradeCell"];
        [self.tableView registerClass:[GradeProofImageCell class] forCellReuseIdentifier:@"GradeProofImageCell"];
        [self.tableView registerClass:[GradeProofVideoCell class] forCellReuseIdentifier:@"GradeProofVideoCell"];
        [self.view addSubview:self.tableView];
        
        self.tableView.tableHeaderView = [self tableViewHeadViewLayout];
        self.tableView.tableFooterView = [self tableViewFootViewLayout];
        [self tableViewBottomViewLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    __block MBProgressHUD *hud = [MBProgressHUD showHudOn:self.view
                                                          mode:MBProgressHUDModeIndeterminate
                                                         image:nil
                                                       message:@""
                                                     delayHide:NO
                                                    completion:nil];
    [[CommonCheckManager shareManager] getChildClassCheckProjectWithParentId:self.mainKeyId completion:^(BOOL success, NSDictionary * _Nullable info) {
            [hud hideAnimated:YES];
        if (success) {
                [self.subGradeDataArray removeAllObjects];
                NSArray *dataArray = info[@"data"];
                [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CheckGradeData *gradeData = [CheckGradeData modelWithDictionary:obj];
                    [self.subGradeDataArray addObjectsFromArray:gradeData.sub_items];
                }];
               [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            hud = [MBProgressHUD showFinishHudOn:self.view
                                                 withResult:NO
                                               labelText:info[@"error_msg"]
                                               delayHide:YES
                                               completion:nil];
        }
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.subGradeDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.selectedImageArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.selectedVideoArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.maxImageAndVideoCount = 0;
    
    self.commitGradeResultArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.commitImageUrlArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.commitVideoUrlArray = [[NSMutableArray alloc] initWithCapacity:0];
}

#pragma mark- UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.subGradeDataArray.count;
        case 1:
            return 2;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (indexPath.section == 0) {
        CheckGradeSubItemData *subGradeData = self.subGradeDataArray[indexPath.row];
        GradeCell *gradeCell = [tableView dequeueReusableCellWithIdentifier:@"GradeCell" forIndexPath:indexPath];
        gradeCell.delegate = self;
        gradeCell.subId = subGradeData.subId;
        gradeCell.titleLabel.text = subGradeData.name;
        gradeCell.addButton.hidden = !subGradeData.is_plus;
        gradeCell.gradeLabel.text = [subGradeData.score_total stringValue];
    
        _score_max = [subGradeData.score_max intValue];
        if (subGradeData.plus_max) {
        _plus_max = [subGradeData.plus_max intValue];
        }
        [dic removeAllObjects];
        [dic setObject:subGradeData.subId forKey:@"item_id"];
        [dic setObject:subGradeData.score_total forKey:@"score"];
        [self.commitGradeResultArray addObject:dic];
        return gradeCell;
    }
    else
    {
        if (indexPath.row == 0) {
            GradeProofImageCell *gradeProofImageCell = [tableView dequeueReusableCellWithIdentifier:@"GradeProofImageCell" forIndexPath:indexPath];
            gradeProofImageCell.delegate = self;
            gradeProofImageCell.imageDataArray = self.selectedImageArray;
            return gradeProofImageCell;
        }
        else
        {
            GradeProofVideoCell *gradeProofVideoCell = [tableView dequeueReusableCellWithIdentifier:@"GradeProofVideoCell" forIndexPath:indexPath];
            gradeProofVideoCell.delegate = self;
            gradeProofVideoCell.videoDataArray = self.selectedVideoArray;
            return gradeProofVideoCell;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"TableViewHeaderFooterView"];
    
    if (headView == nil)
    {
        headView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TableViewHeaderFooterView"];
    }
    
    UIView *backView;
    if (backView == nil) {
        backView = [UIView new];
    }
    backView.backgroundColor = [UIColor whiteColor];
    [headView addSubview:backView];
    
    UIImageView * sectionImageView;
    if (sectionImageView == nil) {
        sectionImageView = [[UIImageView alloc] init];
    }
    sectionImageView.image = [UIImage imageNamed:@"GradeSectionImage" bundleName:@"ModCommonCheckStyle1"];
    sectionImageView.contentMode = UIViewContentModeScaleAspectFit;
    [backView addSubview:sectionImageView];
    
    UILabel *sectionTitleLabel;
    if (sectionTitleLabel == nil) {
        sectionTitleLabel = [[UILabel alloc] init];
    }
    sectionTitleLabel.textAlignment = NSTextAlignmentLeft;
    sectionTitleLabel.textColor = [UIColor blackColor];
    sectionTitleLabel.font = [UIFont systemFontOfSize:13];
    [backView addSubview:sectionTitleLabel];
    
    UILabel *proofCountLabel;
    if (proofCountLabel == nil) {
        proofCountLabel = [[UILabel alloc] init];
    }
    proofCountLabel.hidden = YES;
    proofCountLabel.textColor = [UIColor blackColor];
    proofCountLabel.font = [UIFont systemFontOfSize:12];
    [backView addSubview:proofCountLabel];
    
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(headView);
    }];
    
    [sectionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView.mas_left).offset(20);
        make.top.equalTo(headView.mas_top).offset(15);
        make.width.equalTo(@12);
        make.height.equalTo(@20);
    }];
 
    [sectionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(sectionImageView.mas_right).offset(12);
        make.centerY.equalTo(sectionImageView.mas_centerY);
        make.width.equalTo(@140);
        make.height.equalTo(@26);
    }];
    
    [proofCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(sectionTitleLabel.mas_right).offset(-65);
        make.centerY.equalTo(sectionTitleLabel.mas_centerY);
    }];
    
    switch (section) {
         case 0:
         {
             sectionTitleLabel.text = @"眼保健操打分项";
         }
             break;
         case 1:
        {
             sectionTitleLabel.text = @"上传凭证";
             proofCountLabel.hidden = NO;
             proofCountLabel.text = [NSString stringWithFormat:@"(%d/5)",self.maxImageAndVideoCount];
         }
             break;
             
         default:
             break;
     }
    return headView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 55.f;
        case 1:
            return 75.f;
        default:
      return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableViewHeadViewLayout
{
          UIView * headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 100)];
          headView.backgroundColor = [UIColor whiteColor];
    
          self.imageView = [UIImageView new];
          self.imageView.image = [UIImage imageNamed:@"checkClassTopImage" bundleName:@"ModCommonCheckStyle1"];
          self.imageView.layer.cornerRadius = 6;
          self.imageView.layer.masksToBounds = YES;
          self.imageView.contentMode = UIViewContentModeScaleAspectFill;
       
          [headView addSubview:self.imageView];

          self.cheackAdminLabel = [UILabel new];
          self.cheackAdminLabel.textAlignment = NSTextAlignmentLeft;
          self.cheackAdminLabel.font = [UIFont systemFontOfSize:14];
          self.cheackAdminLabel.textColor = [UIColor whiteColor];
          self.cheackAdminLabel.text = [NSString stringWithFormat:@"检查人:%@",ACCOUNT_NAME];
          [self.imageView addSubview:self.cheackAdminLabel];
              
          self.cheackTimeLabel = [UILabel new];
          self.cheackTimeLabel.textAlignment = NSTextAlignmentLeft;
          self.cheackTimeLabel.font = [UIFont systemFontOfSize:11];
          self.cheackTimeLabel.textColor = [UIColor whiteColor];
          self.cheackTimeLabel.text = [NSUserDefaults schoolCalendar];
          [self.imageView addSubview:self.cheackTimeLabel];
              
          self.cheackTailLabel = [UILabel new];
          self.cheackTailLabel.textAlignment = NSTextAlignmentRight;
          self.cheackTailLabel.font = [UIFont systemFontOfSize:11];
          self.cheackTailLabel.textColor = [UIColor whiteColor];
          self.cheackTailLabel.text = @"人工登记";
          [self.imageView addSubview:self.cheackTailLabel];
              
          [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
              make.top.equalTo(headView.mas_top).offset(20);
              make.left.equalTo(headView.mas_left).offset(20);
              make.right.equalTo(headView.mas_right).offset(-20);
              make.bottom.equalTo(headView.mas_bottom);
          }];
              
          [self.cheackAdminLabel mas_makeConstraints:^(MASConstraintMaker *make) {
              make.left.equalTo(self.imageView.mas_left).offset(30);
              make.centerY.equalTo(self.imageView.mas_centerY).offset(-15);
          }];
              
          [self.cheackTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.equalTo(self.imageView.mas_left).offset(30);
             make.centerY.equalTo(self.imageView.mas_centerY).offset(18);
          }];
              
          [self.cheackTailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
              make.right.equalTo(self.imageView.mas_right).offset(-15);
              make.centerY.equalTo(self.imageView);
          }];
    
       return headView;
}


- (UIView *)tableViewFootViewLayout
{
    UIView * footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 160)];
    footView.backgroundColor = [UIColor whiteColor];
    
    UIImageView * sectionImageView = [[UIImageView alloc] init];
    sectionImageView.image = [UIImage imageNamed:@"GradeSectionImage" bundleName:@"ModCommonCheckStyle1"];
    sectionImageView.contentMode = UIViewContentModeScaleAspectFit;
    [footView addSubview:sectionImageView];

    UILabel *sectionTitleLabel = [[UILabel alloc] init];
    sectionTitleLabel.text = @"检查评价";
    sectionTitleLabel.textAlignment = NSTextAlignmentLeft;
    sectionTitleLabel.textColor = [UIColor blackColor];
    sectionTitleLabel.font = [UIFont systemFontOfSize:13];
    [footView addSubview:sectionTitleLabel];

    
    self.textView = [[IQTextView alloc] init];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.delegate = self;
    NSMutableAttributedString *placeholderText = [[NSMutableAttributedString alloc] initWithString:@"  请输入评价(不超过30个字)"];
    [placeholderText addAttribute:NSFontAttributeName
                     value:[UIFont boldSystemFontOfSize:13.0]
                     range:NSMakeRange(0, placeholderText.length)];
    [self.textView setAttributedPlaceholder:placeholderText];
    [self.textView setPlaceholderTextColor:[UIColor colorFromHex:0xDCDCDC]];
    self.textView.layer.borderWidth = 0.8f;
    self.textView.layer.borderColor = [UIColor colorFromHex:0xBCBCBC].CGColor;
    self.textView.layer.cornerRadius = 6;
    self.textView.layer.masksToBounds = YES;
    [footView addSubview:self.textView];
    
    
    
    [sectionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(footView.mas_left).offset(20);
           make.top.equalTo(footView.mas_top).offset(15);
           make.width.equalTo(@12);
           make.height.equalTo(@20);
       }];
    
    [sectionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(sectionImageView.mas_right).offset(12);
          make.centerY.equalTo(sectionImageView.mas_centerY);
          make.width.equalTo(@140);
          make.height.equalTo(@26);
      }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footView.mas_left).offset(20);
        make.right.equalTo(footView.mas_right).offset(-20);
        make.top.equalTo(sectionImageView.mas_bottom).offset(15);
        make.bottom.equalTo(footView);
    }];
    
    
    return footView;
}

#pragma mark- UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.length >= 30 && ![text isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length >= 30) {
    }
}

#pragma mark- GradeCellDelegate
- (void)clickDeductionButton:(NSIndexPath *)indexPath
{
    GradeCell *gradeCell = [self.tableView cellForRowAtIndexPath:indexPath];
    _integer = [gradeCell.gradeLabel.text intValue];
    CheckGradeSubItemData *subGradeData = self.subGradeDataArray[indexPath.row];
        if (_integer > [subGradeData.score_total intValue]-_score_max) {
            _integer = _integer - 1 ;
            
            gradeCell.addButton.hidden = NO;
            gradeCell.gradeLabel.text = [NSString stringWithFormat:@"%d",_integer];
            
            
            
             NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
            [dic removeAllObjects];
            [dic setObject:gradeCell.subId forKey:@"item_id"];
            [dic setObject:[NSNumber numberWithInt:_integer - [subGradeData.score_total intValue]] forKey:@"score"];//传相对值
            [self.commitGradeResultArray replaceObjectAtIndex:indexPath.row withObject:dic];
        }
        else{
            [MBProgressHUD showFinishHudOn:[UIApplication sharedApplication].keyWindow
              withResult:NO
            labelText:@"已达到减分最大值"
            delayHide:YES
            completion:nil];
        }
}

- (void)clickAddButton:(NSIndexPath *)indexPath
{
       GradeCell *gradeCell = [self.tableView cellForRowAtIndexPath:indexPath];
       _integer = [gradeCell.gradeLabel.text intValue];
        CheckGradeSubItemData *subGradeData = self.subGradeDataArray[indexPath.row];
        if (_integer < [subGradeData.score_total intValue]+_plus_max) {
          _integer = _integer + 1 ;
          gradeCell.gradeLabel.text = [NSString stringWithFormat:@"%d",_integer];
            
          NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
          [dic removeAllObjects];
          [dic setObject:gradeCell.subId forKey:@"item_id"];
          [dic setObject:[NSNumber numberWithInt:_integer - [subGradeData.score_total intValue]] forKey:@"score"];//传相对值
          [self.commitGradeResultArray replaceObjectAtIndex:indexPath.row withObject:dic];
        }
        else
        {
            [MBProgressHUD showFinishHudOn:[UIApplication sharedApplication].keyWindow
                     withResult:NO
                   labelText:@"已达到加分最大值"
                   delayHide:YES
                   completion:nil];
        }
}

#pragma mark- GradeProofImageCellDelegate,GradeProofVideoCellDelegate
- (void)recordImageDataSourceCount
{
    if (self.maxImageAndVideoCount < 5)
    {
          if (!self.chooseImageManager) {
             self.chooseImageManager = [[ACMediaPickerManager alloc] init];
          }
          //外观
          self.chooseImageManager.naviBgColor = [UIColor whiteColor];
          self.chooseImageManager.naviTitleColor = [UIColor blackColor];
          self.chooseImageManager.naviTitleFont = [UIFont boldSystemFontOfSize:18.0f];
          self.chooseImageManager.barItemTextColor = [UIColor blackColor];
          self.chooseImageManager.barItemTextFont = [UIFont systemFontOfSize:15.0f];
          self.chooseImageManager.statusBarStyle = UIStatusBarStyleDefault;
          
          self.chooseImageManager.pickerSource = ACMediaPickerSourceFromAll;
          self.chooseImageManager.allowPickingImage = YES;
          self.chooseImageManager.allowTakePicture = YES;
          self.chooseImageManager.maxImageSelected = 1;
          
          __weak typeof(self) weakSelf = self;
          self.chooseImageManager.didFinishPickingBlock = ^(NSArray<ACMediaModel *> * _Nonnull list) {
              [list enumerateObjectsUsingBlock:^(ACMediaModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ACMediaModel *model = list[idx];
                if (self.maxImageAndVideoCount < 5) {
                  [weakSelf.selectedImageArray addObject:model];
                  self.maxImageAndVideoCount = self.maxImageAndVideoCount + 1;
                }
                else
                {
                  [MBProgressHUD showFinishHudOn:[UIApplication sharedApplication].keyWindow
                                 withResult:NO
                               labelText:@"已达最大选择数"
                               delayHide:YES
                               completion:nil];
              }
              }];
            [self.tableView reloadSection:1 withRowAnimation:UITableViewRowAnimationNone];
          };
          [self.chooseImageManager picker];
    }
    else
    {
        [MBProgressHUD showFinishHudOn:[UIApplication sharedApplication].keyWindow
                        withResult:NO
                        labelText:@"已达最大选择数"
                        delayHide:YES
                        completion:nil];
    }
}

-(void)ClickCellImageDeleteButton:(NSIndexPath *)indexPath
{
    [self.selectedImageArray removeObjectAtIndex:indexPath.row];
    self.maxImageAndVideoCount = self.maxImageAndVideoCount - 1;
    [self.tableView reloadSection:1 withRowAnimation:UITableViewRowAnimationNone];
}

- (void)recordVideoDataSourceCount
{
    if (self.maxImageAndVideoCount < 5) {
         if (!self.chooseVideoManager) {
                  self.chooseVideoManager = [[ACMediaPickerManager alloc] init];
               }
               //外观
               self.chooseVideoManager.naviBgColor = [UIColor whiteColor];
               self.chooseVideoManager.naviTitleColor = [UIColor blackColor];
               self.chooseVideoManager.naviTitleFont = [UIFont boldSystemFontOfSize:18.0f];
               self.chooseVideoManager.barItemTextColor = [UIColor blackColor];
               self.chooseVideoManager.barItemTextFont = [UIFont systemFontOfSize:15.0f];
               self.chooseVideoManager.statusBarStyle = UIStatusBarStyleDefault;
               
               self.chooseVideoManager.pickerSource = ACMediaPickerSourceFromAll;
               self.chooseVideoManager.allowPickingImage = NO;
               self.chooseVideoManager.allowPickingGif = YES;
               self.chooseVideoManager.allowPickingVideo = YES;
               self.chooseVideoManager.allowTakeVideo = YES;
               self.chooseVideoManager.maxImageSelected = 1;

               __weak typeof(self) weakSelf = self;
               self.chooseVideoManager.didFinishPickingBlock = ^(NSArray<ACMediaModel *> * _Nonnull list) {

                   [list enumerateObjectsUsingBlock:^(ACMediaModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                       ACMediaModel *model = list[idx];
                       if (weakSelf.selectedVideoArray.count < 5) {
                          [weakSelf.selectedVideoArray addObject:model];
                         self.maxImageAndVideoCount = self.maxImageAndVideoCount + 1;
                       }
                       else
                       {
                           [MBProgressHUD showFinishHudOn:[UIApplication sharedApplication].keyWindow
                             withResult:NO
                           labelText:@"已达最大选择数"
                           delayHide:YES
                           completion:nil];
                       }
                   }];
                    [self.tableView reloadSection:1 withRowAnimation:UITableViewRowAnimationNone];
               };
               [self.chooseVideoManager picker];
    }
    else
    {
        [MBProgressHUD showFinishHudOn:[UIApplication sharedApplication].keyWindow
                        withResult:NO
                        labelText:@"已达最大选择数"
                        delayHide:YES
                        completion:nil];
    }
}

- (void)clickCellVideoDeleteButton:(NSIndexPath *)indexPath
{
    [self.selectedVideoArray removeObjectAtIndex:indexPath.row];
    self.maxImageAndVideoCount = self.maxImageAndVideoCount - 1;
    [self.tableView reloadSection:1 withRowAnimation:UITableViewRowAnimationNone];
}

- (UIView *)tableViewBottomViewLayout
{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT-60, SCREENWIDTH, 60)];
    footView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:footView];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setFont:[UIFont systemFontOfSize:15]];
    [submitButton setBackgroundColor:[UIColor colorFromHex:0x4D7BFD]];
    submitButton.layer.cornerRadius = 12;
    submitButton.layer.masksToBounds = YES;
    [submitButton addTarget:self action:@selector(submitButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [footView addSubview:submitButton];
    
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footView.mas_top).offset(10);
        make.left.equalTo(footView.mas_left).offset(50);
        make.right.equalTo(footView.mas_right).offset(-50);
        make.height.equalTo(@40);
    }];
    return footView;
}

- (void)submitButtonAction
{
    if(self.maxImageAndVideoCount == 0)
    {
        [MBProgressHUD showFinishHudOn:self.view
           withResult:NO
        labelText:@"上传凭证为空"
        delayHide:YES
        completion:nil];
    }
    else
    {
        __block MBProgressHUD *hud = [MBProgressHUD showHudOn:self.view
                                                                mode:MBProgressHUDModeIndeterminate
                                                               image:nil
                                                             message:@"正在提交中..."
                                                           delayHide:NO
                                                          completion:nil];
        NSString *key = [NSString stringWithFormat:@"CommonCheck/%@",ACCOUNT_NAME];
        dispatch_group_t group = dispatch_group_create();
    
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //上传图片
           if(self.selectedImageArray.count != 0)
           {
              [self.selectedImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                dispatch_group_enter(group);
                ACMediaModel *model = self.selectedImageArray[idx];
                  [[UploadManager shareManager] uploadData:model.data key:key fileExt:nil progress:^(NSUInteger completedBytes, NSUInteger totalBytes) {
                      
                  } completion:^(BOOL success, NSDictionary * _Nullable info) {
//                      DDLog(@"%@",info);
                      if (success) {
                        [self.commitImageUrlArray addObject:[info objectForKey:@"url"]];
                      }
                      dispatch_group_leave(group);
                  }];
              }];
           }
        });

        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //上传视频
            if (self.selectedVideoArray.count!= 0) {
                [self.selectedVideoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    dispatch_group_enter(group);
                    ACMediaModel *model = self.selectedVideoArray[idx];
                    [[UploadManager shareManager] uploadData:model.data key:key fileExt:@"mov" progress:^(NSUInteger completedBytes, NSUInteger totalBytes) {
                        
                    } completion:^(BOOL success, NSDictionary * _Nullable info) {
//                        DDLog(@"%@",info);
                        if (success) {
                           [self.commitVideoUrlArray addObject:[info objectForKey:@"url"]];
                        }
                        dispatch_group_leave(group);
                    }];
                }];
            }
        });

        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            // 提交信息
            NSString *commitImageUrlString = [self.commitImageUrlArray componentsJoinedByString:@","];
            NSString *commitVideoUrlString = [self.commitVideoUrlArray componentsJoinedByString:@","];
        
            [[CommonCheckManager shareManager] commitCheckClassResultInfoWithFromType:self.cheackGradeFromType classId:self.classId studentId:self.studentId areaId:self.areaId imagesIds:commitImageUrlString videoIds:commitVideoUrlString comment:self.textView.text reportUserNo:ACCOUNT_USERID items:self.commitGradeResultArray completion:^(BOOL success, NSDictionary * _Nullable info) {
                [hud hideAnimated:YES];
                if (success) {
//                     DDLog(@"%@",info);
                    [MBProgressHUD showFinishHudOn:self.view
                      withResult:NO
                    labelText:@"提交成功"
                    delayHide:YES
                    completion:nil];
                    ///
                    CommitCheckSuccessViewController *commitSuccessVC = [[CommitCheckSuccessViewController alloc] initWithTitle:self.title rightItem:nil];
                    commitSuccessVC.mainKeyId = self.mainKeyId;
                    commitSuccessVC.tipGradesData = self.tipGradesData;
                    commitSuccessVC.tipClassData = self.tipClassData;
                    commitSuccessVC.cheackGradeFromType = self.cheackGradeFromType;
                    [self.navigationController pushViewController:commitSuccessVC animated:YES];
                }
                else
                {
                    [MBProgressHUD showFinishHudOn:self.view
                                         withResult:NO
                                       labelText:@"提交失败,请重新提交"
                                       delayHide:YES
                                       completion:nil];
                }
            }];
        });
    }
}
@end
