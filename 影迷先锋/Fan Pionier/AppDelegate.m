//
//  AppDelegate.m
//  Fan Pionier
//
//  Created by 卫宫巨侠欧尼酱 on 2021/2/2.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    SKUserSet(@"AppleLanguages", @[@"zh-Hans"]);
    self.window = [UIWindow.alloc initWithFrame:UIScreen.mainScreen.bounds];
    [self.window makeKeyAndVisible];
    [SMJADmanager.share initWithUMAppkey:@"601ce0ed668f9e17b8a817fe"
                      rootViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"tabbar"]
                    showSplashAdComplete:^{
        if (SMJADmanager.share.isOpenLongImage) {
            self.window.rootViewController = SMJADNavigationController.rootViewController;
        }
    }];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [SMJADmanager.share showVideoAdWhenFromBackgroundBecomeForeground];
}


@end
