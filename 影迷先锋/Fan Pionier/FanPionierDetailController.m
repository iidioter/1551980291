//
//  FanPionierDetailController.m
//  FanPionier
//
//  Created by 卫宫巨侠欧尼酱 on 2020/12/27.
//  Copyright © 2020 SK. All rights reserved.
//

#import "FanPionierDetailController.h"
#import <WebKit/WebKit.h>
#import "FlowMenuView.h"


@interface FanPionierDetailController ()

@property (weak, nonatomic) IBOutlet UIButton *FanPionierBack;
@property (weak, nonatomic) IBOutlet UIView *FanPionierDetailBack;

@property (strong ,nonatomic) NSArray *FanPionierInfo;
@property (strong, nonatomic) FlowMenuView *FanPionierFlowMenuView;
@property (strong ,nonatomic) WKWebView *FanPionierDetailWebView;

@end

@implementation FanPionierDetailController

+ (void)FanPionierPush:(NSArray *)FanPionierInfo {
    FanPionierDetailController *FanPionierDetailController =  [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FanPionierDetailController"];
    FanPionierDetailController.FanPionierInfo = FanPionierInfo;
    [[SKT currentNav] pushViewController:FanPionierDetailController animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SKT save:self.FanPionierInfo Key:@"FanPionierRecords"];
    
    WKWebViewConfiguration *FanPionierDetailWebConfiguration = [WKWebViewConfiguration new];
    self.FanPionierDetailWebView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:FanPionierDetailWebConfiguration];
    self.FanPionierDetailWebView.scrollView.showsHorizontalScrollIndicator = NO;
    self.FanPionierDetailWebView.scrollView.showsVerticalScrollIndicator = NO;
    [self.FanPionierDetailBack addSubview:self.FanPionierDetailWebView];
    [self.FanPionierDetailWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.FanPionierDetailBack);
    }];
    self.FanPionierDetailWebView.navigationDelegate = self;
    [self.FanPionierDetailWebView loadHTMLString:[self.FanPionierInfo[5] html] baseURL:nil];
    
    [UIColor colorWithImageUrl:self.FanPionierInfo[3][0] block:^(UIColor * _Nullable color) {
        self.FanPionierBack.backgroundColor = SKThemeColor;
        CellDataModel *tempModel = [CellDataModel new];
        tempModel.myColor_dark      = SKThemeColor;
        tempModel.myColor_normal    = color;
        
        tempModel.myColor_light     = UIColor.clearColor;
        
        self.FanPionierFlowMenuView = [[FlowMenuView alloc] initWithFrame:CGRectMake(0, 0, SKWidth, SKWidth/2+(IPhoneX?44:20)) withDataModel:tempModel block:^(NSInteger index) {
            [FanPionierLoginController checkLogin:^(BOOL completed) {
                [self showADComplete:^{
                    switch (index) {
                        case 0: {
                            if ([SKT update:self.FanPionierInfo Key:SKAccount(@"CollectHome")]) {
                                [SKT showInfo:SKInfoTypeSuccess content:@"收藏成功" block:nil];
                            } else {
                                [SKT showInfo:SKInfoTypeSuccess content:@"取消收藏" block:nil];
                            }
                        }
                            break;
                        case 1: {
                            [SKSheetView show:@"举报内容" sheets:@[@"色情低俗", @"广告骚扰", @"诱导分享", @"谣言", @"政治敏感", @"违法（暴力恐怖、违禁品等）", @"侵权", @"售假", @"其他"] isColor:NO block:^(NSInteger index, NSString * _Nullable content) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    
                                    [SKT save:self.FanPionierInfo Key:SKAccount(@"Block")];
                                    [SKT showInfo:SKInfoTypeLoding content:@"我们将在24小时内审核你的举报的违规信息，如果确定违规将会删除信息，现阶段已帮你屏蔽信息" block:^(BOOL completed) {
                                        [self.navigationController popViewControllerAnimated:YES];
                                    }];
                                });
                            }];
                        }
                            break;
                        case 2: {
                            [SKT showClick:@"拉黑用户" content:@"拉黑用户会屏蔽其相关内容，但这个操作目前是不可逆的，是否确定？" clicks:@[@"确定"] block:^(NSInteger index) {
                                [SKT save:self.FanPionierInfo[0] Key:SKAccount(@"Lahei")];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [SKT showInfo:SKInfoTypeLoding content:@"拉黑成功" block:^(BOOL completed) {
                                        [self.navigationController popViewControllerAnimated:YES];
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
        }];
        [self loadData:tempModel];
        [self.view addSubview:self.FanPionierFlowMenuView];
        
        [self.view bringSubviewToFront:self.FanPionierBack];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)loadData:(CellDataModel *)dataModel
{
    self.FanPionierFlowMenuView.mainInfoView.label.text = dataModel.nameStr;
    self.FanPionierFlowMenuView.mainInfoView.imageView.image = [UIImage imageNamed:dataModel.imageNameStr];
    self.FanPionierFlowMenuView.assignInfoView.assignCellView_1.numLabel.text = dataModel.followersNum;
    self.FanPionierFlowMenuView.assignInfoView.assignCellView_2.numLabel.text = dataModel.favoritesNum;
    self.FanPionierFlowMenuView.assignInfoView.assignCellView_3.numLabel.text = dataModel.viewsNum;
}

- (IBAction)FanPionierBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
