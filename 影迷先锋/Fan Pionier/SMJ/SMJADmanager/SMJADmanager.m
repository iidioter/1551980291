//
//  SMJADmanager.m
//  qianggewangluocesu
//
//  Created by SunSatan on 2020/11/4.
//  Copyright © 2020 SunSatan. All rights reserved.
//

#import "SMJADmanager.h"
#import "UIViewController+showAd.h"
#import "UIImageView+SSWebImage.h"
// 广告
#import "LiteADLibrary.h"
#import <BUAdSDK/BUAdSDK.h>
// 友盟
#import <UMCommon/UMCommon.h>
#import <UMCommon/MobClick.h>
// 网络
#import <AFNetworking/AFNetworking.h>

static NSString * const kAdUser  = @"广告量";
static NSString * const kPayUser = @"付费用户";
static NSString * const kPlaceholderImageName = @"LaunchImage-2";

@interface SMJADmanager ()

<BUSplashAdDelegate, BUFullscreenVideoAdDelegate, BUNativeExpressRewardedVideoAdDelegate>

@property (nonatomic, copy) NSString *appId;          // 穿山甲appid
@property (nonatomic, copy) NSString *appkey;         // 友盟appkey
@property (nonatomic, copy) NSString *splashId;       // 穿山甲开屏广告id
@property (nonatomic, copy) NSString *videoId;        // 穿山甲插页视频id
@property (nonatomic, copy) NSString *inspireId;      // 穿山甲激励id
@property (nonatomic, copy) NSString *bannerHeaderId; // 穿山甲 600*90  的 banner id
@property (nonatomic, copy) NSString *bannerFooterId; // 穿山甲 600*150 的 banner id
@property (nonatomic, copy) NSDictionary *expandInfo; // 拓展数据

@property (nonatomic, strong) UIImageView *preloadImageView; // 用于预加载图片资源的
@property (nonatomic, strong) UIViewController *placeholderViewController; // 开屏广告展示前的占位控制器
@property (nonatomic, strong) UIViewController *rootViewController;        // 根控制器
// 开关
@property (nonatomic, getter=isOpenAd)          BOOL openAd;          // 开启广告
@property (nonatomic, getter=isOpenInspireAd)   BOOL openInspireAd;   // 开启激励广告
@property (nonatomic, getter=isOpenGuideAlert)  BOOL openGuideAlert;  // 开启引导提示
@property (nonatomic, getter=isOpenUnlockAlert) BOOL openUnlockAlert; // 开启引导后的解锁提示
@property (nonatomic, getter=isOpenFailAlert)   BOOL openFailAlert;   // 开启失败提示
@property (nonatomic, getter=isOpenLongImage)   BOOL openLongImage;   // 开启长图
// 开屏广告
@property (nonatomic, strong) BUSplashAdView *splashView;
@property (nonatomic, copy) CompleteBlock splashADCompleteBlock;
// 插页视频
@property (nonatomic, getter=isVideoMaterialMetaLoad) BOOL videoLoad;
@property (nonatomic, strong) BUFullscreenVideoAd *fullscreenVideoAd;
@property (nonatomic, copy) CompleteBlock videoADCompleteBlock;
// 激励视频
@property (nonatomic, getter=isInspireLoad) BOOL inspireLoad;
@property (nonatomic, strong) BUNativeExpressRewardedVideoAd *inspireVideoAd;
@property (nonatomic, copy) CompleteBlock inspireADCompleteBlock;

@end

@implementation SMJADmanager

#pragma mark - 单例

static SMJADmanager *_share;

+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _share = [[SMJADmanager alloc] init];
    });
    return _share;
}

//- (void)initWithBUAdAppID:(NSString *)appid
//                 UMAppkey:(NSString *)appkey
//                 splashId:(NSString *)splashId
//                  videoId:(NSString *)videoId
//                inspireId:(NSString *)inspireId
//           bannerHeaderId:(NSString *)bannerHeaderId
//           bannerFooterId:(NSString *)bannerFooterId
//       rootViewController:(UIViewController *)rootVC
//     showSplashAdComplete:(CompleteBlock)complete
//{
//    [self setRootVC:rootVC];
//
//    _appId = appid;
//    _appkey = appkey;
//    _splashId = splashId;
//    _videoId = videoId;
//    _inspireId = inspireId;
//    _bannerHeaderId = bannerHeaderId;
//    _bannerFooterId = bannerFooterId;
//    _splashADCompleteBlock = complete;
//    _openAd = NO;
//
//    [BUAdSDKManager setAppID:_appId];
//    [BUAdSDKManager setLoglevel:BUAdSDKLogLevelError];
//    [UMConfigure initWithAppkey:_appkey channel:nil];
//
//    [self preloadSplashAd];
//    [self preloadFullscreenVideoAd];
//}

#pragma mark - 初始化配置

- (void)initWithUMAppkey:(NSString *)appkey
      rootViewController:(UIViewController *)rootVC
    showSplashAdComplete:(CompleteBlock)complete {
    // 设置过渡页面
    [self setRootVC:self.placeholderViewController];
    // 监听网络状态
    [self networkConnectStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWWAN ||
            status == AFNetworkReachabilityStatusReachableViaWiFi) {
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                if (self.isProUser) {
                    // 如果是高级会员
                    [self setRootVC:rootVC];
                    [self configUMKey:appkey channel:kPayUser];
                    return;
                }
                
                NSDictionary * infoDic = LiteADLibrary.shared.getInfo;
                NSLog(@"infoDic:%@",infoDic);
                if (infoDic && infoDic[@"app_id"]) {
                    // 基础配置
                    self.openAd = YES;
                    self.splashADCompleteBlock = complete;
                    self.rootViewController = rootVC;
                    // 广告和友盟
                    [self configUMKey:appkey channel:kAdUser];
                    [self configBUAd:infoDic];
                    [self configExpandInfo:infoDic];
                    // 预加载数据
                    [self preloadData];
                } else {
                    // 未开广告
                    [self setRootVC:rootVC];
                    [self configUMKey:appkey channel:nil];
                }
            });
        }
    }];
}

- (void)configUMKey:(NSString *)appKey channel:(NSString *)channel {
    self.appkey = appKey; // 友盟key
    [UMConfigure initWithAppkey:_appkey channel:channel];
}

- (void)configBUAd:(NSDictionary *)infoDic {
    self.appId     = [NSString stringWithFormat:@"%@", infoDic[@"app_id"]];
    self.splashId  = [NSString stringWithFormat:@"%@", infoDic[@"splash_id"]];
    self.videoId   = [NSString stringWithFormat:@"%@", infoDic[@"full_screen_id"]];
    self.inspireId = [NSString stringWithFormat:@"%@", infoDic[@"inspire_id"]];
    self.bannerHeaderId = [NSString stringWithFormat:@"%@", infoDic[@"banner_id"]];
    [BUAdSDKManager setAppID:self.appId];
    [BUAdSDKManager setLoglevel:BUAdSDKLogLevelDebug];
}

- (void)configExpandInfo:(NSDictionary *)infoDic {
    // 解析拓展数据
    NSString *string = [NSString stringWithFormat:@"%@", infoDic[@"ext_data"]];
    NSData *expandInfo = [string dataUsingEncoding:NSUTF8StringEncoding];
    self.expandInfo = [NSJSONSerialization JSONObjectWithData:expandInfo options:NSJSONReadingMutableContainers error:nil];
    self.openInspireAd   = [self.expandInfo[@"inspire_ad_open"] boolValue];
    self.openLongImage   = [self.expandInfo[@"long_image_open"] boolValue];
    self.openGuideAlert  = [self.expandInfo[@"guide_open"]      boolValue];
    self.openUnlockAlert = [self.expandInfo[@"unlock_open"]     boolValue];
    self.openFailAlert   = [self.expandInfo[@"fail_open"]       boolValue];
}

- (void)preloadData {
    // 预加载数据
    [self preloadExpandInfo];
    [self preloadSplashAd];
    [self preloadFullscreenVideoAd];
//    [self preloadInspireAd];
}

#pragma mark - 预加载拓展数据里的资源

- (void)preloadExpandInfo {
    [self.preloadImageView ss_setImageWithURL:[NSString stringWithFormat:@"%@", SMJADmanager.share.expandInfo[@"home_image"]]];
    [self.preloadImageView ss_setImageWithURL:[NSString stringWithFormat:@"%@", SMJADmanager.share.expandInfo[@"second_image"]]];
}

- (UIImageView *)preloadImageView {
    if (_preloadImageView) return _preloadImageView;
    _preloadImageView = UIImageView.new;
    return _preloadImageView;
}

#pragma mark - 开屏

- (void)preloadSplashAd {
    NSLog(@"SMJAD: 预加载开屏广告！");
    [_splashView removeFromSuperview];
    _splashView = nil;
    _splashView = [[BUSplashAdView alloc] initWithSlotID:_splashId
                                                   frame:[UIScreen mainScreen].bounds];
    _splashView.tolerateTimeout = 5;
    _splashView.delegate = self;
    [_splashView loadAdData];
    [MobClick event:@"splash_ad_load"];
}

- (void)showSplashAdWithComplete:(CompleteBlock)complete {
    if (!self.isOpenAd) {
        !complete?:complete();
        return;
    }
    _splashView.rootViewController = self.rootVC;
    _splashADCompleteBlock = complete;
    [self.rootVC.view addSubview:_splashView];
    NSLog(@"SMJAD: 开屏广告开始展示!");
    [MobClick event:@"splash_ad_show"];
}

- (void)splashAdDidClose:(BUSplashAdView *)splashAd {
    [splashAd removeFromSuperview];
    !_splashADCompleteBlock?:_splashADCompleteBlock();
    if ([self.rootVC isEqual:_placeholderViewController]) {
        [self setRootVC:_rootViewController];
    }
    NSLog(@"SMJAD: 开屏广告关闭!");
    [MobClick event:@"splash_ad_close"];
}

- (void)splashAdDidLoad:(BUSplashAdView *)splashAd {
    NSLog(@"SMJAD: 开屏广告加载完成!");
    [MobClick event:@"splash_ad_loadSuccess"];
    [self showSplashAdWithComplete:_splashADCompleteBlock];
}

- (void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError * _Nullable)error {
    [splashAd removeFromSuperview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self preloadSplashAd];
    });
    NSLog(@"SMJAD: 开屏广告加载失败=====%@", error);
    [MobClick event:@"splash_ad_loadFail"];
}

#pragma mark - 视频插页

- (void)preloadFullscreenVideoAd {
    _videoLoad = NO;
    _fullscreenVideoAd = nil;
    _fullscreenVideoAd = [[BUFullscreenVideoAd alloc] initWithSlotID:_videoId];
    _fullscreenVideoAd.delegate = self;
    [_fullscreenVideoAd loadAdData];
    NSLog(@"SMJAD: 预加载插页视频!");
    [MobClick event:@"video_ad_load"];
}

- (void)showVideoAdWithComplete:(CompleteBlock)complete {
    if (!self.isOpenAd      ||
        !_fullscreenVideoAd ||
        !_videoLoad){
        !complete?:complete();
        return;
    }
    
    _videoADCompleteBlock = complete;
    [_fullscreenVideoAd showAdFromRootViewController:UIViewController.currentDisplayViewController];
    NSLog(@"SMJAD: 插页视频开始展示!");
    [MobClick event:@"video_ad_show"];
}

- (void)fullscreenVideoAdDidClose:(BUFullscreenVideoAd *)fullscreenVideoAd {
    !_videoADCompleteBlock?:_videoADCompleteBlock();
    [self preloadFullscreenVideoAd];
    NSLog(@"SMJAD: 插页视频关闭!");
    [MobClick event:@"video_ad_close"];
}

- (void)fullscreenVideoAdDidPlayFinish:(BUFullscreenVideoAd *)fullscreenVideoAd
                      didFailWithError:(NSError *_Nullable)error {
    NSLog(@"SMJAD: 插页视频播放失败=====%@", error);
    [MobClick event:@"video_ad_playFail"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self preloadFullscreenVideoAd];
    });
}

- (void)fullscreenVideoAd:(BUFullscreenVideoAd *)fullscreenVideoAd
         didFailWithError:(NSError *_Nullable)error {
    NSLog(@"SMJAD: 插页视频加载失败=====%@", error);
    [MobClick event:@"video_ad_loadFail"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self preloadFullscreenVideoAd];
    });
}

- (void)fullscreenVideoMaterialMetaAdDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"SMJAD: 视频素材加载成功！");
    [MobClick event:@"video_ad_loadSuccess"];
    _videoLoad = YES;
}

#pragma mark - 激励视频

- (void)preloadInspireAd {
    BURewardedVideoModel *model = BURewardedVideoModel.new;
    model.userId = @"SMJAD";
    _inspireLoad = NO;
    _inspireVideoAd = nil;
    _inspireVideoAd = [BUNativeExpressRewardedVideoAd.alloc initWithSlotID:_inspireId rewardedVideoModel:model];
    _inspireVideoAd.delegate = self;
    [_inspireVideoAd loadAdData];
    NSLog(@"SMJAD: 预加载激励视频！");
    [MobClick event:@"inspire_ad_load"];
}

- (void)showInspireAdWithComplete:(CompleteBlock)complete {
    if (!self.isOpenAd   ||
        !_inspireVideoAd ||
        !_inspireLoad) {
        !complete?:complete();
        return;
    }
    _inspireADCompleteBlock = complete;
    [_inspireVideoAd showAdFromRootViewController:UIViewController.currentDisplayViewController];
    NSLog(@"SMJAD: 激励视频开始展示！");
    [MobClick event:@"inspire_ad_show"];
}

- (void)nativeExpressRewardedVideoAdDidLoad:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    
}

- (void)nativeExpressRewardedVideoAdDidDownLoadVideo:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    _inspireLoad = YES;
    NSLog(@"SMJAD: 激励视频加载成功！");
    [MobClick event:@"inspire_ad_loadSuccess"];
}


- (void)nativeExpressRewardedVideoAd:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    NSLog(@"SMJAD: 激励视频加载失败=====%@", error);
    [MobClick event:@"inspire_ad_loadFail"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self preloadInspireAd];
    });
}

- (void)nativeExpressRewardedVideoAdViewRenderFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    NSLog(@"SMJAD: 激励视频渲染失败=====%@", error);
    [MobClick event:@"inspire_ad_renderFail"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self preloadInspireAd];
    });
}

- (void)nativeExpressRewardedVideoAdDidPlayFinish:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    if (error) {
        NSLog(@"SMJAD: 激励视频播放失败=====%@", error);
        [MobClick event:@"inspire_ad_playFail"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self preloadInspireAd];
        });
    }
}

- (void)nativeExpressRewardedVideoAdDidClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    !_inspireADCompleteBlock?:_inspireADCompleteBlock();
    [self preloadInspireAd];
    NSLog(@"SMJAD: 激励视频关闭!");
    [MobClick event:@"inspire_ad_close"];
}

#pragma mark - 开屏占位控制器

- (UIViewController *)placeholderViewController {
    if (_placeholderViewController) return _placeholderViewController;
    
    _placeholderViewController = UIViewController.new;
    
    UIImageView *placeholderImage = UIImageView.new;
    placeholderImage.frame = _placeholderViewController.view.bounds;
    placeholderImage.backgroundColor = UIColor.whiteColor;
    placeholderImage.contentMode = UIViewContentModeScaleAspectFit;
    placeholderImage.image = [UIImage imageNamed:kPlaceholderImageName];
    [_placeholderViewController.view addSubview:placeholderImage];
    
    return _placeholderViewController;
}

#pragma mark - 手动控制视频展示次数

- (NSUInteger)openAdNumber {
    return (NSUInteger)[NSUserDefaults.standardUserDefaults integerForKey:@"SMJADOpenVideoNumber"];
}

- (void)setOpenAdNumber:(NSUInteger)openAdNumber {
    [NSUserDefaults.standardUserDefaults setInteger:openAdNumber forKey:@"SMJADOpenVideoNumber"];
}

#pragma mark - 手动控制视频展示次数

- (BOOL)isProUser {
    return [NSUserDefaults.standardUserDefaults boolForKey:@"SMJADProUser"];
}

- (void)setProUser:(BOOL)proUser {
    [NSUserDefaults.standardUserDefaults setBool:proUser forKey:@"SMJADProUser"];
}

#pragma mark - 根控制器

- (void)showVideoAdWhenFromBackgroundBecomeForeground {
    [MobClick event:@"background_become_foreground"];
    if (SMJADmanager.share.isOpenInspireAd) {
        [SMJADmanager.share showInspireAdWithComplete:nil];
    } else {
        [SMJADmanager.share showVideoAdWithComplete:nil];
    }
}

- (void)setRootVC:(UIViewController *)rootVC {
    UIApplication.sharedApplication.keyWindow.rootViewController = rootVC;
}

- (UIViewController *)rootVC {
    return UIApplication.sharedApplication.keyWindow.rootViewController;
}

#pragma mark - 网络状态管理

- (void)networkConnectStatusChangeBlock:(void(^)(AFNetworkReachabilityStatus status))connectState {
    
    AFNetworkReachabilityManager *manager = AFNetworkReachabilityManager.sharedManager;
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        !connectState?:connectState(status);
    }] ;
    [self tryNetworkConnection];
}

- (void)tryNetworkConnection {
    [AFHTTPSessionManager.manager GET:@"www.baidu.com" parameters:nil headers:nil progress:nil success:nil failure:nil];
}

@end
