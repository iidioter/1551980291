//
//  UIViewController+showAd.m
//  
//
//  Created by SunSatan on 2020/9/18.
//

#import "UIViewController+showAd.h"
#import "UIImageView+SSWebImage.h"
#import "UIView+action.h"
#import "SMJADmanager.h"
#import "AdBannerHeadView.h"
#import "MBProgressHUD.h"
#import <SDWebImage/SDWebImage.h>
#import <Masonry/Masonry.h>

#define IPHONE_X \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define SafeAreaTopHeight (IPHONE_X ? 88 : 64)

@implementation UIViewController (showAd)

- (void)showADComplete:(completeBlock)block {
    if (SMJADmanager.share.isOpenInspireAd) {
        [SMJADmanager.share showInspireAdWithComplete:^{
            SMJADmanager.share.openAdNumber += 1;
            !block?:block();
        }];
    } else {
        [SMJADmanager.share showVideoAdWithComplete:^{
            SMJADmanager.share.openAdNumber += 1;
            !block?:block();
        }];
    }
}

- (void)showADWithGuideAlert:(completeBlock)block
{
    [self showADWithAlertTitle:[NSString stringWithFormat:@"%@", SMJADmanager.share.expandInfo[@"guide_title"]]
                  alertMessage:[NSString stringWithFormat:@"%@", SMJADmanager.share.expandInfo[@"guide_message"]]
                     sureTitle:[NSString stringWithFormat:@"%@", SMJADmanager.share.expandInfo[@"guide_sure"]]
                   cancelTitle:[NSString stringWithFormat:@"%@", SMJADmanager.share.expandInfo[@"guide_cancel"]]
                      complete:block];
}

- (void)showADWithAlertTitle:(NSString *)alertTitle
                alertMessage:(NSString *)alertMessage
                   sureTitle:(NSString *)sureTitle
                 cancelTitle:(NSString *)cancelTitle
                    complete:(completeBlock)block
{
    if (SMJADmanager.share.isOpenAd) {
        if (SMJADmanager.share.isOpenGuideAlert) {
            __weak typeof(self) selfWeak = self;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [selfWeak showADComplete:^{
                    [selfWeak showUnlockAlert];
                }];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [selfWeak showADComplete:^{
                    [selfWeak showUnlockAlert];
                }];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [self showADWithFailAlert:^{
                !block?:block();
            }];
        }
    }
    else {
        !block?:block();
    }
}

- (void)showUnlockAlert {
    if (SMJADmanager.share.isOpenUnlockAlert) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@", SMJADmanager.share.expandInfo[@"unlock_title"]] message:[NSString stringWithFormat:@"%@", SMJADmanager.share.expandInfo[@"unlock_message"]] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@", SMJADmanager.share.expandInfo[@"unlock_sure"]] style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)showADWithFailAlert:(completeBlock)block {
    [self showADWithFailAlert:[NSString stringWithFormat:@"%@", SMJADmanager.share.expandInfo[@"fail_title"]]
                 alertMessage:[NSString stringWithFormat:@"%@", SMJADmanager.share.expandInfo[@"fail_message"]]
                  cancelTitle:[NSString stringWithFormat:@"%@", SMJADmanager.share.expandInfo[@"fail_sure"]]
                     complete:block];
}

- (void)showADWithFailAlert:(NSString *)alertTitle
               alertMessage:(NSString *)alertMessage
                cancelTitle:(NSString *)cancelTitle
                   complete:(completeBlock)block {
    if (SMJADmanager.share.isOpenAd) {
        __weak typeof(self) selfWeak = self;
        [self showADComplete:^{
            if (SMJADmanager.share.isOpenFailAlert) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    !block?:block();
                }]];
                [selfWeak presentViewController:alert animated:YES completion:nil];
            } else {
                !block?:block();
            }
        }];
    } else {
        !block?:block();
    }
}

- (void)showAdGuideAlertThenFailAlertWithComplete:(completeBlock)block {
    if (SMJADmanager.share.openAdNumber == 0) {
        [self showADWithGuideAlert:nil];
    } else {
        [self showADWithFailAlert:nil];
    }
}

- (void)addScrollImageViewWithColor:(UIColor *)backgroundColor {
    if (SMJADmanager.share.isOpenAd &&
        SMJADmanager.share.isOpenLongImage) {
        __weak typeof(self) selfWeak = self;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        AdBannerHeadView *bannerAd = [AdBannerHeadView.alloc initWithRootViewController:self];
        bannerAd.backgroundColor = UIColor.clearColor;
        
        //滚动长图
        UIScrollView *scrollView = UIScrollView.new;
        scrollView.backgroundColor = backgroundColor?backgroundColor:UIColor.whiteColor;
        scrollView.showsHorizontalScrollIndicator = NO;//隐藏水平滚动条
        scrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:scrollView];
        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view);
        }];
        [scrollView ss_addAction:^{
            [selfWeak showAdGuideAlertThenFailAlertWithComplete:nil];
        }];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        UIImageView *homeImage = UIImageView.new;
        homeImage.contentMode = UIViewContentModeScaleAspectFill;
        [homeImage ss_setImageWithURL:[NSString stringWithFormat:@"%@", SMJADmanager.share.expandInfo[@"home_image"]]
                            completed:^(UIImage * _Nonnull image) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (image) {
                CGFloat imageHeight = image.size.height * (self.view.bounds.size.width / image.size.width);
                CGRect frame = CGRectMake(0,
                                          0,
                                          self.view.bounds.size.width,
                                          imageHeight);
                homeImage.frame = frame;
                scrollView.contentSize = frame.size;
                [scrollView addSubview:homeImage];
                [homeImage ss_addAction:^{
                    [selfWeak showAdGuideAlertThenFailAlertWithComplete:nil];
                }];
                // 第一张图加载出来以后，再添加横幅广告
                CGRect bannerFrame = CGRectMake(0,
                                                frame.size.height,
                                                self.view.bounds.size.width,
                                                bannerAd.size.height);
                bannerAd.frame = bannerFrame;
                scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,
                                                    bannerFrame.size.height +
                                                    frame.size.height);
                [scrollView addSubview:bannerAd];
                
                // 第一张图加载出来以后，再添加加载第二张图
                UIImageView *secondImage = UIImageView.new;
                secondImage.contentMode = UIViewContentModeScaleAspectFill;
                [secondImage ss_setImageWithURL:[NSString stringWithFormat:@"%@", SMJADmanager.share.expandInfo[@"second_image"]]
                                      completed:^(UIImage * _Nonnull image) {
                    if (image) {
                        CGFloat imageHeight = image.size.height * (self.view.bounds.size.width / image.size.width);
                        CGRect secondFrame = CGRectMake(0,
                                                        bannerAd.frame.origin.y + bannerAd.frame.size.height,
                                                        self.view.bounds.size.width,
                                                        imageHeight);
                        secondImage.frame = secondFrame;
                        scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,
                                                            bannerFrame.size.height +
                                                            frame.size.height +
                                                            secondFrame.size.height);
                        [scrollView addSubview:secondImage];
                        [secondImage ss_addAction:^{
                            [selfWeak showAdGuideAlertThenFailAlertWithComplete:nil];
                        }];
                    }
                }];
            }
        }];
    }
}

#pragma mark - Current Display ViewController

+ (UIViewController *)currentDisplayViewController {
    UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
    UIViewController *currentShowVC = [self findCurrentDisplayViewController:rootVC];
    return currentShowVC;
}

/** 递归查找当前显示的VC*/
+ (UIViewController *)findCurrentDisplayViewController:(UIViewController *)fromVC {
    if ([fromVC isKindOfClass:UINavigationController.class]) {
        return [self findCurrentDisplayViewController:[((UINavigationController *)fromVC) visibleViewController]];
    } else if ([fromVC isKindOfClass:UITabBarController.class]) {
        return [self findCurrentDisplayViewController:((UITabBarController *)fromVC).selectedViewController];
    } else {
        if (fromVC.presentedViewController) {
            return [self findCurrentDisplayViewController:fromVC.presentedViewController];
        } else {
            return fromVC;
        }
    }
}

@end
