//
//  FanPionierAddShowController.m
//  Guoman Society
//
//  Created by 卫宫巨侠欧尼酱 on 2020/12/9.
//  Copyright © 2020 Guoman Society. All rights reserved.
//

#import "FanPionierAddShowController.h"

@interface FanPionierAddShowController ()

@property (weak, nonatomic) IBOutlet UIImageView *FanPionierHead;
@property (weak, nonatomic) IBOutlet UITextField *FanPionierTitle;
@property (weak, nonatomic) IBOutlet UITextView *FanPionierContent;
@property (weak, nonatomic) IBOutlet UIImageView *FanPionierImage1;
@property (weak, nonatomic) IBOutlet UIImageView *FanPionierImage2;
@property (weak, nonatomic) IBOutlet UIImageView *FanPionierImage3;
@property (weak, nonatomic) IBOutlet UIView *FanPionierBack;

@end

@implementation FanPionierAddShowController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.FanPionierContent.layer.borderColor = UIColor.lightGrayColor.light.CGColor;
    self.FanPionierBack.layer.shadowColor = SKThemeColor.CGColor;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"动态内容"]) {
        textView.text = nil;
        textView.textColor = SKCurrentColor.dark;
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (!textView.text.length) {
        textView.text = @"动态内容";
        
        textView.textColor = UIColor.lightGrayColor;
    }
    
    return YES;
}

- (IBAction)FanPionierSelectHead:(UITapGestureRecognizer *)sender {
    [SKT selectImage:sender.view Block:nil];
}

- (IBAction)FanPionierSelectImage1:(UITapGestureRecognizer *)sender {
    [SKT selectImage:sender.view Block:nil];
}

- (IBAction)FanPionierSelectImage2:(UITapGestureRecognizer *)sender {
    [SKT selectImage:sender.view Block:nil];
}

- (IBAction)FanPionierSelectImage3:(UITapGestureRecognizer *)sender {
    [SKT selectImage:sender.view Block:nil];
}

- (IBAction)FanPionierSave:(UIButton *)sender {
    if ([self.FanPionierContent.text isEqualToString:@"动态内容"]) {
        [SKT showInfo:SKInfoTypeNotice content:@"请输入动态内容" block:nil];
        return;
    }
    [SKT checkError:@[self.FanPionierHead,self.FanPionierTitle,self.FanPionierContent,[NSDate format:@"yyyy/mm/dd hh:mm:ss"],SKAccountName] Title:@"添加动态" Contents:@[@"头像",@"标题",@"内容",@"时间",@"姓名"] ReInfo:NO Block:^(NSMutableArray *data) {
        NSMutableArray *FanPionierArr = [NSMutableArray array];
        if (self.FanPionierImage1.tag) {
            [FanPionierArr addObject:self.FanPionierImage1.image.imageUrl];
        }
        if (self.FanPionierImage2.tag) {
            [FanPionierArr addObject:self.FanPionierImage2.image.imageUrl];
        }
        if (self.FanPionierImage3.tag) {
            [FanPionierArr addObject:self.FanPionierImage3.image.imageUrl];
        }
        if (!FanPionierArr.count) {
            [SKT showInfo:SKInfoTypeNotice content:@"至少提供一张内容图片" block:nil];
            return;
        }
        [data addObject:FanPionierArr];
        [SKT save:data Key:SKAccount(@"Quan")];
        [SKT showInfo:SKInfoTypeLoding content:nil block:^(BOOL completed) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}


@end
