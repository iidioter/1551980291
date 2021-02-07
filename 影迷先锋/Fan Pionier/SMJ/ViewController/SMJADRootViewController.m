//
//  SMJADRootViewController.m
//  Demo
//
//  Created by SunSatan on 2020/12/2.
//

#import "SMJADRootViewController.h"
#import "SMJAD.h"

@interface SMJADRootViewController ()

@end

@implementation SMJADRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"首页";
    self.view.backgroundColor = UIColor.whiteColor;
    [self addScrollImageViewWithColor:UIColor.whiteColor];
}

@end
