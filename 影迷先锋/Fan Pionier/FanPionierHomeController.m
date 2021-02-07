//
//  FanPionierHomeController.m
//  FanPionier
//
//  Created by 卫宫巨侠欧尼酱 on 2021/1/10.
//  Copyright © 2021 SK. All rights reserved.
//

#import "FanPionierHomeController.h"
#import "FanPionierBannerCell.h"
#import "FanPionierDetailController.h"

@interface FanPionierHomeCell ()

@property (weak, nonatomic) IBOutlet UIView *FanPionierBannerView;
@property (weak, nonatomic) IBOutlet UILabel *FanPionierTitle;
@property (weak, nonatomic) IBOutlet UILabel *FanPionierContent;
@property (weak, nonatomic) IBOutlet UILabel *FanPionierName;
@property (weak, nonatomic) IBOutlet UILabel *FanPionierTime;

@end

@implementation FanPionierHomeCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)FanPionierUpdate:(NSArray *)FanPionierInfo {
    if (self.FanPionierBannerView.subviews.count) {
        [self.FanPionierBannerView.subviews[0] removeFromSuperview];
    }
    
    [self.FanPionierBannerView addSubview:[SKBannerView banner:FanPionierInfo[3] contents:nil orientation:(SKBannerViewOrientationVertical) autoTime:3.0 frame:CGRectMake(0, 0, 100, 100) block:^(NSInteger index) {
        
    }]];
    
    self.FanPionierBannerView.layer.borderColor = SKThemeColor.CGColor;
    self.FanPionierTitle.text = FanPionierInfo[0];
    self.FanPionierTime.text = FanPionierInfo[1];
    self.FanPionierName.text = FanPionierInfo[2];
    self.FanPionierContent.text = FanPionierInfo[4];
}


@end


@interface FanPionierHomeController ()<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (strong ,nonatomic) NSMutableArray *FanPionierData;
@property (assign ,nonatomic) NSInteger index;

@end

@implementation FanPionierHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.FanPionierCollect) {
        self.title = @[@"我的收藏",@"浏览记录"][self.FanPionierCollect-1];
    }
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.index = 0;
        self.FanPionierData = [NSMutableArray array];
        [self.tableView.mj_footer resetNoMoreData];
        [self FanPionierSetupData];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self FanPionierSetupData];
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.index = 0;
    self.FanPionierData = [NSMutableArray array];
    [self.tableView.mj_footer resetNoMoreData];
    [self FanPionierSetupData];
}

- (void)FanPionierSetupData {
    [SKT async:^(SKNormalBlock  _Nullable block) {
        if (self.FanPionierCollect == 1) {
            self.FanPionierData = [NSMutableArray array];
            [self.FanPionierData addObjectsFromArray:SKUserGet(SKAccount(@"CollectHome"))];
        } else if (self.FanPionierCollect == 2) {
            self.FanPionierData = [NSMutableArray array];
            [self.FanPionierData addObjectsFromArray:SKUserGet(@"FanPionierRecords")];
        } else {
            
            NSArray *FanPionierTemp = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Home" ofType:@"plist"]];
            NSMutableArray *FanPionierArray = [NSMutableArray array];
            for (NSInteger FanPionierIndex=self.index*10; FanPionierIndex<((self.index*10+10)>FanPionierTemp.count ? FanPionierTemp.count : (self.index*10+10)); FanPionierIndex++) {
                [FanPionierArray addObject:FanPionierTemp[FanPionierIndex]];
            }
            
            self.index ++;
            
            if (FanPionierArray.count < 10) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                });
            }
            
            for (NSArray *FanPionierArr in SKUserGet(SKAccount(@"Block"))) {
                [FanPionierArray removeObject:FanPionierArr];
            }
            NSArray *FanPionierCount = FanPionierTemp.copy;
            for (NSInteger FanPionierIndex=0; FanPionierIndex<FanPionierCount.count; FanPionierIndex++) {
                NSArray *FanPionierArr = FanPionierCount[FanPionierIndex];
                if ([SKUserGet(SKAccount(@"Lahei")) containsObject:FanPionierArr[2]]) {
                    [FanPionierArray removeObject:FanPionierArr];
                }
            }
            
            [self.FanPionierData addObjectsFromArray:FanPionierArray];
            if (!SKUserGet(@"CollectHomeFanPionier")) {
                [SKT save:self.FanPionierData[3] Key:@"CollectHomeFanPionier"];
                [SKT save:self.FanPionierData[5] Key:@"CollectHomeFanPionier"];
                [SKT save:self.FanPionierData[7] Key:@"CollectHomeFanPionier"];
            }
        }
        block();
    } main:^{
        [self FanPionierSetupBanner];
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
        [TableViewAnimationKit showWithAnimationType:2 tableView:self.tableView];
    }];
}

- (void)FanPionierSetupBanner {
    if ((self.FanPionierData.count > 1) && (!self.FanPionierCollect)) {
        NSMutableArray *FanPionierHomeImages = [NSMutableArray array];
        NSMutableArray *FanPionierHomeTitles = [NSMutableArray array];
        for (NSInteger FanPionierIndex=self.FanPionierData.count-1; FanPionierIndex>=0; FanPionierIndex--) {
            if (FanPionierHomeImages.count < 5) {
                [FanPionierHomeImages addObject:[self.FanPionierData[FanPionierIndex][3] lastObject]];
                [FanPionierHomeTitles addObject:self.FanPionierData[FanPionierIndex][0]];
            }
        }
        
        self.tableView.tableHeaderView = [SKBannerView banner:FanPionierHomeImages contents:FanPionierHomeTitles orientation:(SKBannerViewOrientationHorizontal) autoTime:7 frame:CGRectMake(0, 0, SKWidth, SKWidth/2) block:^(NSInteger index) {
            [FanPionierDetailController FanPionierPush:self.FanPionierData[self.FanPionierData.count-index-1]];
        }];
         
    } else {
        self.tableView.tableHeaderView = [UIView new];
    }
}

- (void)FanPionierClick:(NSInteger)FanPionierIndex {
    [self showADComplete:^{
        if (self.FanPionierData.count > FanPionierIndex) {
            [FanPionierDetailController FanPionierPush:self.FanPionierData[FanPionierIndex]];
        }
    }];
}

- (IBAction)FanPionierAdd:(id)sender {
    [self showADComplete:^{
                
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.FanPionierData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FanPionierHomeCell *FanPionierHomeCell = [tableView dequeueReusableCellWithIdentifier:@"FanPionierHomeCell"];
    FanPionierHomeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [FanPionierHomeCell FanPionierUpdate:self.FanPionierData[indexPath.row]];
    
    return FanPionierHomeCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showADComplete:^{
        [FanPionierDetailController FanPionierPush:self.FanPionierData[indexPath.row]];
    }];
}

#pragma mark - DZNEmptyDataSetSource Methods

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    text = @"空数据";
    font = SKTitleFont(17);
    textColor = [UIColor colorWithHex:@"545454"];
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    text = @"数据为空，平台会尽快为您推送资讯，请耐心等待";
    font = SKTitleFont(15);
    textColor = [UIColor colorWithHex:@"545454"];
    
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    if (paragraph) [attributes setObject:paragraph forKey:NSParagraphStyleAttributeName];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:SKTextColor range:[attributedString.string rangeOfString:@"耐心等待"]];
    
    return attributedString;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    
    return [[UIImage imageNamed:@"icon-1"] initwithColor:UIColor.systemBackgroundColor];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    text = @"耐心等待";
    font = SKTitleFont(15);
    textColor = SKTextColor;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self FanPionierAdd:nil];
}

@end
