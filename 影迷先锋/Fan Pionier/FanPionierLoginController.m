//
//  FanPionierLoginController.m
//  FanPionier
//
//  Created by 谢国威 on 2020/10/15.
//  Copyright © 2020 LiliumL. All rights reserved.
//

#import "FanPionierLoginController.h"


@interface FanPionierPEController ()

@end

@implementation FanPionierPEController

- (IBAction)FanPionierPe:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end


@interface FanPionierLoginController ()

@property (weak, nonatomic) IBOutlet UITextField *FanPionierAC;
@property (weak, nonatomic) IBOutlet UITextField *FanPionierPW;
@property (weak, nonatomic) IBOutlet UIButton *FanPionierPE;
@property (weak, nonatomic) IBOutlet UIView *FanPionierMineTop;
@property (weak, nonatomic) IBOutlet UIView *FanPionierBack;

@property (strong ,nonatomic) SKBoolBlock FanPionierBlock;

@end

@implementation FanPionierLoginController

+ (void)checkLogin:(SKBoolBlock)block {
    
    if (SKUserGet(@"FanPionierLogin")) {
        block(YES);
    } else {
        FanPionierLoginController *FanPionierVC =  [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FanPionierLogin"];
        FanPionierVC.FanPionierBlock = block;
        [[SKT currentNav] pushViewController:FanPionierVC animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!SKUserGet(@"Accounts")) {
        [SKT save:@{@"FanPionierAccount":@"FanPionier",@"FanPionierPassword":@"123456"} Key:@"Accounts"];
    }
    self.FanPionierBack.layer.shadowColor = SKThemeColor.CGColor;
    [self.FanPionierMineTop radian:UISwipeGestureRecognizerDirectionDown radian:SKWidth/10];
}

- (IBAction)FanPionierPe:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)FanPionierShowPE:(id)sender {
    self.FanPionierPE.hidden = NO;
}

- (IBAction)FanPionierSign:(id)sender {
    
    if (!self.FanPionierPE.selected) {
        [SKT showInfo:SKInfoTypeError content:@"请查看用户协议并确认" block:nil];
        return;
    }
    
    NSArray *FanPionierArray = SKUserGet(@"Accounts");
    
    for (NSDictionary *FanPionierDic in FanPionierArray) {
        if ([self.FanPionierAC.text isEqualToString:(FanPionierDic[@"FanPionierAccount"])] &&
            [self.FanPionierPW.text isEqualToString:(FanPionierDic[@"FanPionierPassword"])]) {
            SKUserSet(@"FanPionierLogin", FanPionierDic);
            
            [SKT showInfo:SKInfoTypeLoding content:nil block:^(BOOL completed) {
                [self.navigationController popViewControllerAnimated:YES];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.FanPionierBlock(YES);
                });
            }];
            
            return;;
        }
    }
    
    [SKT showInfo:SKInfoTypeError content:@"密码错误或者账号不存在" block:nil];
}

- (IBAction)FanPionierRegist:(id)sender {
    
    NSArray *temp = SKUserGet(@"Accounts");
    for (NSDictionary *dic in temp) {
        if ([(dic[@"FanPionierAccount"]) isEqualToString:self.FanPionierAC.text]) {
            [SKT showInfo:SKInfoTypeError content:@"账号已存在" block:nil];
            return;
        }
    }
    
    [SKT checkError:@[self.FanPionierAC,self.FanPionierPW] Title:@"注册" Contents:@[@"Account",@"Password"] ReInfo:YES Block:^(NSDictionary * _Nullable info) {
        
        [SKT save:info Key:@"Accounts"];
        SKUserSet(@"FanPionierLogin", info);
        [SKT showInfo:SKInfoTypeLoding content:nil block:^(BOOL completed) {
            [self.navigationController popViewControllerAnimated:YES];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.FanPionierBlock(YES);
            });
        }];
    }];
}


- (IBAction)FanPionierEye:(UIButton *)sender {

    self.FanPionierPW.secureTextEntry = sender.selected;
    sender.selected = !sender.selected;
}


@end
