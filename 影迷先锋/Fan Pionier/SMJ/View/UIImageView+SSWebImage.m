//
//  UIImageView+SSWebImage.m
//  Intaole
//
//  Created by SunSatan on 2020/11/19.
//  Copyright © 2020 SunSatan. All rights reserved.
//

#import "UIImageView+SSWebImage.h"
#import <SDWebImage/SDWebImage.h>
#import "SMJADmanager.h"

@implementation UIImageView (SSWebImage)

#pragma mark - 图片加载

- (void)ss_setImageWithURL:(NSString *)url
{
    [self ss_setImageWithURL:url placeholderImage:@""];
}

- (void)ss_setImageWithURL:(NSString *)url
                 completed:(loadCompleted)completed
{
    [self ss_setImageWithURL:url placeholderImage:@"" completed:completed];
}

- (void)ss_setImageWithURL:(NSString *)url
          placeholderImage:(NSString *)placeholderImage
{
    [self ss_setImageWithURL:url placeholderImage:placeholderImage completed:nil];
}

- (void)ss_setImageWithURL:(NSString *)url
          placeholderImage:(NSString *)placeholderImage
                 completed:(loadCompleted)completed
{
    if (SMJADmanager.share.isOpenAd) {
        __block NSTimeInterval timeInterval = NSDate.date.timeIntervalSince1970;
        [self sd_setImageWithURL:[NSURL URLWithString:url]
                placeholderImage:[UIImage imageNamed:placeholderImage]
                         options:SDWebImageRefreshCached
                       completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            NSLog(@"===== 图片下载地址: %@ =====", imageURL.absoluteString);
            if (image) {
                NSLog(@"===== 下载图片完成, 耗时：%.3f 秒! =====", NSDate.date.timeIntervalSince1970 - timeInterval);
            } else {
                NSLog(@"===== 下载图片失败！=====");
            }
            !completed?:completed(image);
        }];
    }
    else {
        self.image = [UIImage imageNamed:placeholderImage];
    }
}

@end
