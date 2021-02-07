//
//  AdBannerHeadView.m
//  PasswordManagement
//
//  Created by SunSatan on 2020/10/28.
//  Copyright © 2020 SunSatan. All rights reserved.
//

#import "AdBannerHeadView.h"
#import <Masonry/Masonry.h>
#import <BUAdSDK/BUAdSDK.h>
#import "SMJADmanager.h"

#define BUD_Log(frmt, ...)   \
do {                                                      \
NSLog(@"【ADLib】%@", [NSString stringWithFormat:frmt,##__VA_ARGS__]);  \
} while(0)

@interface AdBannerHeadView () <BUNativeExpressBannerViewDelegate>

@property (nonatomic, weak)   UIViewController *rootVC;
@property (nonatomic, strong) BUNativeExpressBannerView *bannerView;

@end

@implementation AdBannerHeadView

- (instancetype)initWithRootViewController:(UIViewController *)vc
{
    if (self = [super init]) {
        
        self.backgroundColor = UIColor.clearColor;
        
        _rootVC = vc;
        _bannerView = [BUNativeExpressBannerView.alloc initWithSlotID:SMJADmanager.share.bannerHeaderId rootViewController:_rootVC adSize:[self BUSize]];
        _bannerView.delegate = self;
        [_bannerView loadAdData];
        [self addSubview:_bannerView];
        
        [_bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

- (CGSize)size
{
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat bannerHeight = screenWidth * [self BUSize].height / [self BUSize].width;
    return CGSizeMake(screenWidth, bannerHeight);
}

- (CGSize)BUSize
{
    BUSize *size = [BUSize sizeBy:BUProposalSize_Banner600_260];
    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    CGFloat height = UIScreen.mainScreen.bounds.size.width/size.width * size.height;
    return CGSizeMake(width, height);
}

#pragma BUNativeExpressBannerViewDelegate
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    [self pbud_logWithSEL:_cmd msg:@""];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *)error {
    [self pbud_logWithSEL:_cmd msg:[NSString stringWithFormat:@"error:%@", error]];
}

- (void)nativeExpressBannerAdViewRenderSuccess:(BUNativeExpressBannerView *)bannerAdView {
    [self pbud_logWithSEL:_cmd msg:@""];
}

- (void)nativeExpressBannerAdViewRenderFail:(BUNativeExpressBannerView *)bannerAdView error:(NSError *)error {
    [self pbud_logWithSEL:_cmd msg:[NSString stringWithFormat:@"error:%@", error]];
}

- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    [self pbud_logWithSEL:_cmd msg:@""];
}

- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    [self pbud_logWithSEL:_cmd msg:@""];
}

//- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterwords {
//    [self pbud_logWithSEL:_cmd msg:@""];
//}

- (void)nativeExpressBannerAdViewDidCloseOtherController:(BUNativeExpressBannerView *)bannerAdView interactionType:(BUInteractionType)interactionType {
    NSString *str;
    if (interactionType == BUInteractionTypePage) {
        str = @"ladingpage";
    } else if (interactionType == BUInteractionTypeVideoAdDetail) {
        str = @"videoDetail";
    } else {
        str = @"appstoreInApp";
    }
    [self pbud_logWithSEL:_cmd msg:str];
}

- (void)pbud_logWithSEL:(SEL)sel msg:(NSString *)msg {
    BUD_Log(@"SDKDemoDelegate BUNativeExpressBannerView In VC (%@) extraMsg:%@", NSStringFromSelector(sel), msg);
}

@end
