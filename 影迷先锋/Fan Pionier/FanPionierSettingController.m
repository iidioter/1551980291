//
//  FanPionierSettingController.m
//  Fan Pionier
//
//  Created by 卫宫巨侠欧尼酱 on 2021/2/3.
//  Copyright © 2021 SK. All rights reserved.
//

#import "FanPionierSettingController.h"
#import "FanPionierHomeController.h"
#import "FanPionierQuanController.h"

@interface FanPionierSettingController ()

@property (weak, nonatomic) IBOutlet UILabel *FanPionierName;
@property (weak, nonatomic) IBOutlet UIButton *FanPionierLogin;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *FanPionierViews;

@end

@implementation FanPionierSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    for (UIView *FanPionierView in self.FanPionierViews) {
        FanPionierView.layer.borderColor = SKThemeColor.CGColor;
        FanPionierView.superview.layer.shadowColor = SKThemeColor.CGColor;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.FanPionierLogin.selected = SKLogin;
    self.FanPionierName.text = SKAccountName;
}

- (IBAction)FanPionierActions:(UIButton *)sender {
    [self showADComplete:^{
        switch (sender.tag) {
            case 0:
                [self FanPionierChangeTheme:NO];
                break;
            case 1:
                [self FanPionierChangeTheme:YES];
                break;
            case 2:
                [self FanPionierCollectHome];
                break;
            case 3:
                [self FanPionierCollectShow];
                break;
            case 4:
                [self FanPionierSubmintShow];
                break;
            case 5:
                [self FanPionierClearUpShare];
                break;
            case 6:
                [self FanPionierClearUpRate];
                break;
            case 7:
                [self FanPionierLoginRegist];
                break;
                
            default:
                break;
        }
    }];
}

- (void)FanPionierChangeTheme:(BOOL)isNight {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIWindow animateWithDuration:0.5 animations:^{
            [UIApplication sharedApplication].keyWindow.overrideUserInterfaceStyle = isNight?UIUserInterfaceStyleDark:UIUserInterfaceStyleLight;
            [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
        }];
    });
}

- (void)FanPionierCollectHome {
    [FanPionierLoginController checkLogin:^(BOOL completed) {
        FanPionierHomeController *FanPionierHomeController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FanPionierHomeController"];
        FanPionierHomeController.FanPionierCollect = 1;
        [self.navigationController pushViewController:FanPionierHomeController animated:YES];
    }];
}

- (void)FanPionierCollectShow {
    [FanPionierLoginController checkLogin:^(BOOL completed) {
        FanPionierQuanController *FanPionierQuanController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FanPionierQuanController"];
        FanPionierQuanController.FanPionierCollect = 1;
        [self.navigationController pushViewController:FanPionierQuanController animated:YES];
    }];
}

- (void)FanPionierSubmintShow {
    [FanPionierLoginController checkLogin:^(BOOL completed) {
        FanPionierQuanController *FanPionierQuanController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FanPionierQuanController"];
        FanPionierQuanController.FanPionierCollect = 2;
        [self.navigationController pushViewController:FanPionierQuanController animated:YES];
    }];
}

- (void)FanPionierClearUpShare {
    [SKT shareOrRate:@"1551980291" Shared:NO];
}

- (void)FanPionierClearUpRate {
    [SKT shareOrRate:@"1551980291" Shared:YES];
}

- (void)FanPionierLoginRegist {
    if (self.FanPionierLogin.selected) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FanPionierLogin"];
        self.FanPionierLogin.selected = NO;
        [self.tabBarController setSelectedIndex:0];
    } else {
        [FanPionierLoginController checkLogin:^(BOOL completed) {
            self.FanPionierLogin.selected = YES;
        }];
    }
}

@end
