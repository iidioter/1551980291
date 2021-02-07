//
//  UIViewController+showAd.h
//  
//
//  Created by SunSatan on 2020/9/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef  void(^ _Nullable completeBlock)(void);

@interface UIViewController (showAd)

@property(class, nonatomic, readonly) UIViewController *currentDisplayViewController;

// 直接弹广告，没有弹窗
- (void)showADComplete:(completeBlock)block;
// 引导弹窗点击展示广告
- (void)showADWithGuideAlert:(completeBlock)block;
- (void)showADWithAlertTitle:(NSString *)alertTitle
                alertMessage:(NSString *)alertMessage
                   sureTitle:(NSString *)sureTitle
                 cancelTitle:(NSString *)cancelTitle
                    complete:(completeBlock)block;
// 先广告再弹出失败弹窗
- (void)showADWithFailAlert:(completeBlock)block;
- (void)showADWithFailAlert:(NSString *)alertTitle
               alertMessage:(NSString *)alertMessage
                cancelTitle:(NSString *)cancelTitle
                   complete:(completeBlock)block;
// 首次点击先弹出引导框，再次点击就是失败框，block只有在未开启广告时才会调用
- (void)showAdGuideAlertThenFailAlertWithComplete:(completeBlock)block;
// 添加滚动长图
- (void)addScrollImageViewWithColor:(UIColor *)backgroundColor;
@end

NS_ASSUME_NONNULL_END
