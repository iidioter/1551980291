//
//  SMJADmanager.h
//  qianggewangluocesu
//
//  Created by SunSatan on 2020/11/4.
//  Copyright © 2020 SunSatan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIViewController;

typedef void(^CompleteBlock)(void);

@interface SMJADmanager : NSObject

@property (nonatomic, readonly) NSString *appId;          // 穿山甲appid
@property (nonatomic, readonly) NSString *appkey;         // 友盟appkey
@property (nonatomic, readonly) NSString *splashId;       // 穿山甲开屏广告id
@property (nonatomic, readonly) NSString *videoId;        // 穿山甲插页视频id
@property (nonatomic, readonly) NSString *inspireId;      // 穿山甲激励id
@property (nonatomic, readonly) NSString *bannerHeaderId; // 穿山甲高90的banner id
@property (nonatomic, readonly) NSString *bannerFooterId; // 穿山甲高150的banner id
@property (nonatomic, readonly) NSDictionary *expandInfo; // 拓展数据

@property (nonatomic, readonly, getter=isOpenAd)          BOOL openAd; // 是否开启广告
@property (nonatomic, readonly, getter=isOpenInspireAd)   BOOL openInspireAd;   // 开启激励广告
@property (nonatomic, readonly, getter=isOpenGuideAlert)  BOOL openGuideAlert;  // 是否开启引导提示框
@property (nonatomic, readonly, getter=isOpenUnlockAlert) BOOL openUnlockAlert; // 是否开启解锁提示框
@property (nonatomic, readonly, getter=isOpenFailAlert)   BOOL openFailAlert;   // 是否开启失败提示框
@property (nonatomic, readonly, getter=isOpenLongImage)   BOOL openLongImage;   // 是否开启长图

@property (nonatomic) NSUInteger openAdNumber; // 自己手动控制视频广告展示次数
@property (nonatomic, getter=isProUser) BOOL proUser; // 高级用户关闭所有广告

+ (instancetype)share;

//自动配置广告id时使用
- (void)initWithUMAppkey:(NSString *)appkey
      rootViewController:(UIViewController *)rootVC
    showSplashAdComplete:(CompleteBlock)complete;
// 展示插页视频广告
- (void)showVideoAdWithComplete:(CompleteBlock)complete;
// 展示激励视频广告
- (void)showInspireAdWithComplete:(CompleteBlock)complete;
// 后台进入前台自动展示插页视频广告
- (void)showVideoAdWhenFromBackgroundBecomeForeground;

//需要自己配置广告id时使用，已弃用
//- (void)initWithBUAdAppID:(NSString *)appid
//                 UMAppkey:(NSString *)appkey
//                 splashId:(NSString *)splashId
//                  videoId:(NSString *)videoId
//                inspireId:(NSString *)inspireId
//           bannerHeaderId:(NSString *)bannerHeaderId
//           bannerFooterId:(NSString *)bannerFooterId
//       rootViewController:(UIViewController *)rootVC
//     showSplashAdComplete:(CompleteBlock)complete;

@end

NS_ASSUME_NONNULL_END
