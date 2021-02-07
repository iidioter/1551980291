//
//  FanPionierTopController.m
//  IT Telegram
//
//  Created by 卫宫巨侠欧尼酱 on 2021/1/9.
//  Copyright © 2021 SK. All rights reserved.
//

#import "FanPionierTopController.h"
#import "FanPionierHomeController.h"
#import "FanPionierDetailController.h"

@interface FanPionierTopController ()<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *FanPionierTopSeg;
@property (strong ,nonatomic) NSMutableArray *FanPionierData;
@end


@implementation FanPionierTopController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIFont *font = SKTitleFont(15);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [self.FanPionierTopSeg setTitleTextAttributes:attributes
                                        forState:UIControlStateNormal];
    [self.FanPionierTopSeg setTitleTextAttributes:@{NSForegroundColorAttributeName:SKThemeColor}forState:UIControlStateSelected];
    [self FanPionierHomeUpdate:0];
}

- (IBAction)FanPionierTopSeg:(UISegmentedControl *)sender {
    [self FanPionierHomeUpdate:sender.selectedSegmentIndex];
}

- (void)FanPionierHomeUpdate:(NSInteger)FanPionierHomeType {
    [SKT async:^(SKNormalBlock  _Nullable block) {
        NSMutableArray *FanPionierTemp = [NSMutableArray arrayWithArray:[[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TOP" ofType:@"plist"]] objectAtIndex:FanPionierHomeType]];
        for (NSArray *FanPionierArr in SKUserGet(SKAccount(@"Block"))) {
            [FanPionierTemp removeObject:FanPionierArr];
        }
        NSArray *FanPionierCount = FanPionierTemp.copy;
        for (NSInteger FanPionierIndex=0; FanPionierIndex<FanPionierCount.count; FanPionierIndex++) {
            NSArray *FanPionierArr = FanPionierCount[FanPionierIndex];
            if ([SKUserGet(SKAccount(@"Lahei")) containsObject:FanPionierArr[2]]) {
                [FanPionierTemp removeObject:FanPionierArr];
            }
        }
        self.FanPionierData = [NSMutableArray array];
        [self.FanPionierData addObjectsFromArray:FanPionierTemp];
        block();
    } main:^{
        [self.tableView reloadData];
        [TableViewAnimationKit showWithAnimationType:self.FanPionierTopSeg.selectedSegmentIndex+2 tableView:self.tableView];
    }];
    
    [self.FanPionierData addObjectsFromArray:SKUserGet(SKAccount(@"CollectHome"))];
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
    return (self.FanPionierData.count >= 10)?10:self.FanPionierData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FanPionierHomeCell *FanPionierHomeCell = [tableView dequeueReusableCellWithIdentifier:@"FanPionierHomeCell"];
    FanPionierHomeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [FanPionierHomeCell FanPionierUpdate:self.FanPionierData[indexPath.row]];
    
    if (indexPath.row < 3) {
        FanPionierHomeCell.FanPionierLeft.backgroundColor = SKThemeColor;
    } else {
        FanPionierHomeCell.FanPionierLeft.backgroundColor = UIColor.lightGrayColor;;
    }
    FanPionierHomeCell.FanPionierCount.text = @(indexPath.row+1).stringValue;
    
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
    
    text = @"数据为空，影迷先锋会尽快推送新的资讯给您，请耐心等待";
    font = SKTitleFont(15);
    textColor = [UIColor colorWithHex:@"545454"];
    
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    if (paragraph) [attributes setObject:paragraph forKey:NSParagraphStyleAttributeName];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:SKThemeColor range:[attributedString.string rangeOfString:@"耐心等待"]];
    
    return attributedString;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    
    return [UIImage imageNamed:@"icon-1"];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    text = @"请耐心等待";
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
