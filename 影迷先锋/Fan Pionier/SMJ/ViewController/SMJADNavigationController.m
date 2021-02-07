//
//  SMJADNavigationController.m
//  Demo
//
//  Created by SunSatan on 2020/12/2.
//

#import "SMJADNavigationController.h"
#import "SMJADRootViewController.h"

@interface SMJADNavigationController ()

@end

@implementation SMJADNavigationController

+ (instancetype)rootViewController
{
    SMJADNavigationController *nav = [SMJADNavigationController.alloc initWithRootViewController:SMJADRootViewController.new];
    nav.navigationBar.shadowImage = UIImage.new;
    nav.navigationBar.barTintColor = UIColor.whiteColor;
    return nav;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end
