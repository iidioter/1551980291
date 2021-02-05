//
//  FanPionierQuanController.m
//  IT Telegram
//
//  Created by 卫宫巨侠欧尼酱 on 2021/1/9.
//  Copyright © 2021 SK. All rights reserved.
//

#import "FanPionierQuanController.h"
#import "FanPionierAddShowController.h"


@interface FanPionierQuanCell ()

@property (weak, nonatomic) IBOutlet UIImageView *FanPionierImage;
@property (weak, nonatomic) IBOutlet UIView *FanPionierBack;
@property (weak, nonatomic) IBOutlet UILabel *FanPionierTitle;
@property (weak, nonatomic) IBOutlet UILabel *FanPionierName;
@property (weak, nonatomic) IBOutlet UILabel *FanPionierTime;
@property (weak, nonatomic) IBOutlet UIStackView *FanPionierStack;
@property (weak, nonatomic) IBOutlet UILabel *FanPionierContent;

@property (strong ,nonatomic) NSArray *FanPionierInfo;

@end

@implementation FanPionierQuanCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.FanPionierImage.layer.borderColor = SKThemeColor.CGColor;
    self.FanPionierBack.layer.shadowColor = SKThemeColor.CGColor;
}

- (void)FanPionierUpdate:(NSArray *)FanPionierInfo {
    
    self.FanPionierInfo = FanPionierInfo;
    self.FanPionierTitle.text = FanPionierInfo[1];
    self.FanPionierContent.text = FanPionierInfo[2];
    self.FanPionierName.text = FanPionierInfo[4];
    self.FanPionierTime.text = FanPionierInfo[3];
    [self.FanPionierImage imageUrl:FanPionierInfo[0] block:nil];
    
    NSArray *FanPionierArr = FanPionierInfo[5];
    for (NSInteger FanPionierIndex = 0; FanPionierIndex<3; FanPionierIndex++) {
        UIImageView *FanPionierImageView = self.FanPionierStack.arrangedSubviews[FanPionierIndex];
        if (FanPionierArr.count > FanPionierIndex) {
            FanPionierImageView.hidden = NO;
            [FanPionierImageView imageUrl:FanPionierArr[FanPionierIndex] block:nil];
        } else {
            FanPionierImageView.hidden = YES;
        }
    }
}


@end


@interface FanPionierQuanController ()<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (strong ,nonatomic) NSMutableArray *FanPionierData;

@end

@implementation FanPionierQuanController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @[@"动态",@"我的收藏",@"我的动态"][self.FanPionierCollect];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
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
    self.FanPionierData = [NSMutableArray array];
    [self.tableView.mj_footer resetNoMoreData];
    [self FanPionierSetupData];
}

- (void)FanPionierSetupData {
    [SKT async:^(SKNormalBlock  _Nullable block) {
        if (self.FanPionierCollect == 1) {
            self.FanPionierData = [NSMutableArray array];
            [self.FanPionierData addObjectsFromArray:SKUserGet(SKAccount(@"CollectQuan"))];
        } else {
            NSMutableArray *FanPionierTemp = [NSMutableArray array];
            [FanPionierTemp addObjectsFromArray:SKUserGet(SKAccount(@"Quan"))];
            [FanPionierTemp addObjectsFromArray:[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Quan" ofType:@"plist"]]];
            
            NSMutableArray *FanPionierArray = [NSMutableArray array];
            for (NSInteger FanPionierIndex=self.FanPionierData.count; FanPionierIndex<((self.FanPionierData.count+10)>FanPionierTemp.count ? FanPionierTemp.count : (self.FanPionierData.count+10)); FanPionierIndex++) {
                [FanPionierArray addObject:FanPionierTemp[FanPionierIndex]];
            }
            
            if (FanPionierArray.count < 10) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                });
            }
            
            for (NSArray *FanPionierArr in SKUserGet(SKAccount(@"Block"))) {
                [FanPionierArray removeObject:FanPionierArr];
            }
            NSArray *FanPionierCount = FanPionierArray.copy;
            for (NSInteger FanPionierIndex=0; FanPionierIndex<FanPionierCount.count; FanPionierIndex++) {
                NSArray *FanPionierArr = FanPionierCount[FanPionierIndex];
                if ([SKUserGet(SKAccount(@"Lahei")) containsObject:FanPionierArr[4]]) {
                    [FanPionierArray removeObject:FanPionierArr];
                }
                if (self.FanPionierCollect == 2) {
                    if (![FanPionierArr[4] isEqualToString:([SKAccountName isEqualToString:@"FanPionier"]?@"影迷先锋":SKAccountName)]) {
                        [FanPionierArray removeObject:FanPionierArr];
                    }
                }
            }
            
            [self.FanPionierData addObjectsFromArray:FanPionierArray];
            if (!SKUserGet(@"CollectQuanFanPionier")) {
                [SKT save:self.FanPionierData[3] Key:@"CollectQuanFanPionier"];
                [SKT save:self.FanPionierData[5] Key:@"CollectQuanFanPionier"];
            }
        }
        block();
    } main:^{
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
        [TableViewAnimationKit showWithAnimationType:7 tableView:self.tableView];
    }];
}

- (IBAction)FanPionierAdd:(id)sender {
    [FanPionierLoginController checkLogin:^(BOOL completed) {
        [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FanPionierAddShowController"] animated:YES];
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
    FanPionierQuanCell *FanPionierQuanCell = [tableView dequeueReusableCellWithIdentifier:@"FanPionierQuanCell"];
    FanPionierQuanCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *FanPionierTemp = self.FanPionierData[indexPath.row];
    [FanPionierQuanCell FanPionierUpdate:FanPionierTemp];
    
    
    return FanPionierQuanCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [SKSheetView show:@"你的操作" sheets:@[@[@"取消收藏",@"收藏动态"][[SKUserGet(SKAccount(@"CollectQuan")) containsObject:self.FanPionierData[indexPath.row]]],@"屏蔽动态",@"举报动态",@"拉黑用户"] isColor:NO block:^(NSInteger index, NSString * _Nullable content) {
        [FanPionierLoginController checkLogin:^(BOOL completed) {
            switch (index) {
                case 0: {
                    if ([SKT update:self.FanPionierData[indexPath.row] Key:SKAccount(@"CollectQuan")]) {
                        [SKT showInfo:SKInfoTypeSuccess content:@"收藏成功" block:nil];
                    } else {
                        [SKT showInfo:SKInfoTypeSuccess content:@"取消收藏" block:nil];
                    }
                }
                    break;
                case 1: {
                    [SKT save:self.FanPionierData[indexPath.row] Key:SKAccount(@"Block")];
                    self.FanPionierData = [NSMutableArray array];
                    [self.tableView.mj_footer resetNoMoreData];
                    [self FanPionierSetupData];;
                }
                    break;
                case 2: {
                    
                    [SKSheetView show:@"举报内容" sheets:@[@"色情低俗", @"广告骚扰", @"诱导分享", @"谣言", @"政治敏感", @"违法（暴力恐怖、违禁品等）", @"侵权", @"售假", @"其他"] isColor:NO block:^(NSInteger index, NSString * _Nullable content) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            [SKT save:self.FanPionierData[indexPath.row] Key:SKAccount(@"Block")];
                            [SKT showInfo:SKInfoTypeLoding content:@"我们将在24小时内审核你的举报的违规信息，如果确定违规将会删除信息，现阶段已帮你屏蔽信息" block:^(BOOL completed) {
                                self.FanPionierData = [NSMutableArray array];
                                [self.tableView.mj_footer resetNoMoreData];
                                [self FanPionierSetupData];;
                            }];
                        });
                    }];
                }
                    break;
                case 3: {
                    [SKT showClick:@"拉黑用户" content:@"拉黑用户会屏蔽其相关内容，但这个操作目前是不可逆的，是否确定？" clicks:@[@"确定"] block:^(NSInteger index) {
                        [SKT save:self.FanPionierData[indexPath.row][4] Key:SKAccount(@"Lahei")];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [SKT showInfo:SKInfoTypeLoding content:@"拉黑成功" block:^(BOOL completed) {
                                self.FanPionierData = [NSMutableArray array];
                                [self.tableView.mj_footer resetNoMoreData];
                                [self FanPionierSetupData];
                            }];
                        });
                    }];
                }
                    break;
                    
                default:
                    break;
            }
        }];
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
    
    text = @"数据为空，请点击右上角按钮添加数据";
    font = SKTitleFont(15);
    textColor = [UIColor colorWithHex:@"545454"];
    
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    if (paragraph) [attributes setObject:paragraph forKey:NSParagraphStyleAttributeName];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:SKThemeColor range:[attributedString.string rangeOfString:@"添加数据"]];
    
    return attributedString;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    
    return [UIImage imageNamed:@"icon-1"];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    text = @"添加数据";
    font = SKTitleFont(15);
    textColor = SKThemeColor;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self FanPionierAdd:nil];
}

@end
