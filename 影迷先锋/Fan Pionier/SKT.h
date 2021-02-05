//
//  SKT.h
//  SKT
//
//  Created by rose on 2020/7/23.
//  Copyright © 2020 SK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <StoreKit/StoreKit.h>
#import <MessageUI/MessageUI.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define IPhoneX (SKHeight/SKWidth > 2)

#define SKUserGet(x) [[NSUserDefaults standardUserDefaults] objectForKey:x]
#define SKUserSet(x,y) [[NSUserDefaults standardUserDefaults] setObject:y forKey:x];[[NSUserDefaults standardUserDefaults] synchronize]
#define SKUserGetB(x) [[NSUserDefaults standardUserDefaults] boolForKey:x]
#define SKUserSetB(x,y) [[NSUserDefaults standardUserDefaults] setBool:y forKey:x];[[NSUserDefaults standardUserDefaults] synchronize]
#define SKUserGetInt(x) [[NSUserDefaults standardUserDefaults] integerForKey:x]
#define SKUserSetInt(x,y) [[NSUserDefaults standardUserDefaults] setInteger:y forKey:x];[[NSUserDefaults standardUserDefaults] synchronize]

#define SKAccount(x) [((NSString *)x) stringByAppendingString:([[[NSUserDefaults standardUserDefaults] objectForKey:@"FanPionierLogin"] objectForKey:@"FanPionierAccount"])?([[[NSUserDefaults standardUserDefaults] objectForKey:@"FanPionierLogin"] objectForKey:@"FanPionierAccount"]):@"FanPionier"]
#define SKAccountName ([[[NSUserDefaults standardUserDefaults] objectForKey:@"FanPionierLogin"] objectForKey:@"FanPionierAccount"])?([[[[NSUserDefaults standardUserDefaults] objectForKey:@"FanPionierLogin"] objectForKey:@"FanPionierAccount"] isEqualToString:@"FanPionier"]?@"影迷先锋":[[[NSUserDefaults standardUserDefaults] objectForKey:@"FanPionierLogin"] objectForKey:@"FanPionierAccount"]):@"影迷先锋"

#define SKLogin  [[NSUserDefaults standardUserDefaults] objectForKey:@"FanPionierLogin"]

#define SKWidth  UIScreen.mainScreen.bounds.size.width
#define SKHeight UIScreen.mainScreen.bounds.size.height
#define SKBottom (IPhoneX ? 34.f : 10.f)
#define SKNavBarHeight (IPhoneX?88:64)
#define SKTabBarHeight (IPhoneX?88:49)
#define SKColor(x) ((UIColor *)[UIColor colorWithHex:x])

#define SKTitleFont(x)    [UIFont boldSystemFontOfSize:x]
//#define SKTitleFont(x)  [UIFont fontWithName:@"Tensentype-XiChaoYuanJ" size:x]
#define SKContentFont(x)  [UIFont systemFontOfSize:x]
//#define SKContentFont(x)  [UIFont fontWithName:@"Arial" size:x]

#define IS_COLOR SKUserGetB(@"color")
#define SKThemeColor  [UIColor colorWithHex:@"15a89d"]
#define SKTextColor   [UIColor colorWithHex:@"DDA481"]
#define SKBadgeColor   [UIColor colorWithHex:@"C74627"]
#define SKCurrentColor ((UIColor *)([UIColor colorWithHex:SKUserGet(@"SKCurrentColor")?SKUserGet(@"SKCurrentColor"):@"15a89d"]))

typedef void(^SKImageBlock)(UIImage * _Nullable image, NSString * _Nullable imageUrl);
typedef void(^SKColorBlock)(UIColor * _Nullable color);
typedef void(^SKObjectBlock)(id _Nullable object);
typedef void(^SKContentBlock)(NSString * _Nullable content);
typedef void(^SKIndexBlock)(NSInteger index);
typedef void(^SKBoolBlock)(BOOL completed);
typedef void(^SKNormalBlock)(void);
typedef void(^SKNormalBlockBlock)(SKNormalBlock _Nullable block);
typedef void(^SKInfoBlock)(NSDictionary * _Nullable info);
typedef void(^SKDataBlock)(NSArray * _Nullable data);
typedef void(^SKCheckErrorBlock)(NSDictionary * _Nullable info, BOOL isOk);

typedef NS_ENUM(NSUInteger, SKInfoType) {
    SKInfoTypeInfo,
    SKInfoTypeNotice,
    SKInfoTypeLoding,
    SKInfoTypeError,
    SKInfoTypeSuccess
};

NS_ASSUME_NONNULL_BEGIN

#pragma mark ######## --SKT扩展-- ########

@interface UIColor (SKColor)
+ (UIColor *)colorWithHex:(NSString *)string;
+ (void)colorWithImageUrl:(NSString *)url block:(SKColorBlock)block;
- (UIColor *)light;
- (UIColor *)dark;
- (UIColor *)checkColor:(UIColor *)color;
- (UIColor *)alpha:(CGFloat)alpha;
- (NSString *)hexString;
@end

@interface UIImage (SKImage)
+ (void)image:(id)sender Path:(NSString *)path;
+ (NSArray *)images:(NSArray *)urls;
+ (UIImage *)image:(NSString *)path;
- (void)color:(SKColorBlock)block;
- (UIColor *)color;
- (NSString *)imageUrl;
- (UIImage *)spinImage:(UIImageOrientation)orientation;
- (UIImage *)initwithColor:(UIColor *)color;
- (UIImage *)combineImage:(UIImage *)upImage DownImage:(UIImage *)downImage;
- (UIImage *)zoom:(CGFloat)size;
@end

@interface UIScrollView (SKScrollView)
- (UIImage *)snapshotScrollView;
@end

@interface UIView (SKView)
- (void)radiusWithRadius:(CGFloat)radius  corner:(UIRectCorner)corner;
- (void)layoutHeight:(CGFloat)height;
- (void)layoutWidth:(CGFloat)width;
- (void)layoutWidth:(CGFloat)width withView:(UIView *)view multipler:(CGFloat)multipler;
- (void)radian:(UISwipeGestureRecognizerDirection)direction radian:(CGFloat)radian;
- (void)gradualLayer:(NSArray *)colors;
- (void)shaw:(BOOL)down;
- (UIImage *)image;
@end

@interface UIImageView(SKImageView)
- (void)imageUrl:(NSString *)imageurl block:(_Nullable SKImageBlock)block;
@end

@interface NSString (SKString)
- (NSString *)pinyin;
- (NSString *)imageUrl;
- (NSString *)bundleUrl;
- (NSString *)arrayIndex:(NSInteger)index;
- (NSString *)stars;
- (NSString *)https;
- (NSString *)html;
@end

@interface NSDate (SKDate)
+ (NSString *)format:(NSString *)format;
@end

#pragma mark ######## --SKT类别-- ########

@interface SKView : UIView
@property (nonatomic, assign) IBInspectable BOOL topLeft;
@property (nonatomic, assign) IBInspectable BOOL topRight;
@property (nonatomic, assign) IBInspectable BOOL bottomLeft;
@property (nonatomic, assign) IBInspectable BOOL bottomRight;
@property (nonatomic, assign) IBInspectable CGFloat radius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, strong) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable BOOL fill;
@end

@interface SKBarButtonItem : UIBarButtonItem
- (void)badgeValue:(NSString *)value block:(SKObjectBlock)block;
@end

@interface SKPhotoPicker : UIViewController
+ (void)push:(UIViewController *)vc block:(SKImageBlock)block;
@end

@interface SKNavigationController : UINavigationController
- (void)gradualLayer:(NSArray *)colors;
@end

@interface SKTabBarController : UITabBarController
@property (nonatomic, assign) IBInspectable BOOL clickAnimal;
- (void)gradualLayer:(NSArray *)colors;
@end


#pragma mark ######## --SKT工具-- ########

@interface SKSheetView : UIView
typedef void(^SKSheetBlock)(NSInteger index,  NSString * _Nullable content);
+ (void)show:(NSString *)title sheets:(NSArray *)array isColor:(BOOL)IsColor block:(SKSheetBlock)block;
@end

@interface SKBannerSubiew : UIView
@property (nonatomic, strong) UIImageView *mainImageView;
@property (nonatomic, strong) UILabel *mainContent;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIView *shawView;
@property (nonatomic, copy) void (^didSelectCellBlock)(NSInteger tag, SKBannerSubiew *cell);
- (void)setSubviewsWithSuperViewBounds:(CGRect)superViewBounds;
@end
@protocol SKBannerViewDataSource;
@protocol SKBannerViewDelegate;
typedef enum{
    SKBannerViewOrientationHorizontal = 0,
    SKBannerViewOrientationVertical
}SKBannerViewOrientation;
@interface SKBannerView : UIView<UIScrollViewDelegate>
@property (nonatomic,assign) SKBannerViewOrientation orientation;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic,assign) BOOL needsReload;
@property (nonatomic,assign) NSInteger pageCount;
@property (nonatomic,strong) NSMutableArray *cells;
@property (nonatomic,assign) NSRange visibleRange;
@property (nonatomic,strong) NSMutableArray *reusableCells;
@property (nonatomic,assign)   id <SKBannerViewDataSource> dataSource;
@property (nonatomic,assign)   id <SKBannerViewDelegate>   delegate;
@property (nonatomic,retain)  UIPageControl *pageControl;
@property (nonatomic, assign) CGFloat minimumPageAlpha;
@property (nonatomic, assign) CGFloat leftRightMargin;
@property (nonatomic, assign) CGFloat topBottomMargin;
@property (nonatomic, assign) BOOL isOpenAutoScroll;
@property (nonatomic, assign) BOOL isCarousel;
@property (nonatomic, assign, readonly) NSInteger currentPageIndex;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) CGFloat autoTime;
@property (nonatomic, assign) NSInteger orginPageCount;
- (void)reloadData;
- (SKBannerSubiew *)dequeueReusableCell;
- (void)scrollToPage:(NSUInteger)pageNumber;
- (void)stopTimer;
- (void)adjustCenterSubview;
+ (UIView *)banner:(NSArray *)images contents:(NSArray * _Nullable)contents block:(SKIndexBlock)block;
+ (UIView *)banner:(NSArray *)images contents:(NSArray * _Nullable)contents orientation:(SKBannerViewOrientation)orientation autoTime:(CGFloat)autoTime frame:(CGRect)frame block:(SKIndexBlock)block;
@end
@protocol  SKBannerViewDelegate<NSObject>
@optional
- (CGSize)sizeForPageInFlowView:(SKBannerView *)flowView;
- (void)didScrollToPage:(NSInteger)pageNumber inFlowView:(SKBannerView *)flowView;
- (void)didSelectCell:(SKBannerSubiew *)subView withSubViewIndex:(NSInteger)subIndex;
@end
@protocol SKBannerViewDataSource <NSObject>
- (NSInteger)numberOfPagesInFlowView:(SKBannerView *)flowView;
- (SKBannerSubiew *)flowView:(SKBannerView *)flowView cellForPageAtIndex:(NSInteger)index;
@end


@interface SKT : NSObject
@property (strong ,nonatomic) NSMutableDictionary *info;
@property (strong ,nonatomic) UIColor *color;

+ (instancetype)skt;
+ (UIViewController *)currentVC;
+ (UINavigationController *)currentNav;
+ (void)save:(id)value Key:(NSString *)key;
+ (BOOL)update:(id)value Key:(NSString *)key;
+ (void)remove:(id)value Key:(NSString *)key;
+ (void)update:(id)value1 value2:(id)value2 Key:(NSString *)key;
+ (BOOL)contains:(id)value Key:(NSString *)key;
+ (void)showInfo:(SKInfoType)type content:(NSString * _Nullable)content block:(SKBoolBlock _Nullable)block;
+ (void)showClick:(NSString *)title content:(NSString *)content clicks:(NSArray *)clicks block:(SKIndexBlock)block;
+ (void)showEdit:(NSArray *)contents content:(NSString *)title block:(SKDataBlock)block;
+ (void)shareOrRate:(NSString *)appid Shared:(BOOL)shared;
+ (void)selectImage:(id _Nullable)sender Block:(__nullable SKImageBlock)block;
+ (BOOL)checkError:(id)sender Content:(NSString *)content;
+ (BOOL)checkError:(NSArray *)senders Contents:(NSArray *)contents;
+ (void)checkError:(NSArray *)senders Title:(NSString *)title Contents:(NSArray *)contents ReInfo:(BOOL)reInfo Block:(SKObjectBlock)block;
+ (void)sendEmail:(NSArray *)titles Images:(NSArray *)images;
+ (void)callPhone:(NSString *)phone;
+ (void)playAudio:(NSInteger)soundID;
+ (void)async:(SKNormalBlockBlock)asyncBlock main:(SKNormalBlock)mainBlock;
+ (void)saveData:(NSArray *)data name:(NSString *)name;
+ (void)copy:(NSString *)content notice:(NSString *)notice;

@end

NS_ASSUME_NONNULL_END
