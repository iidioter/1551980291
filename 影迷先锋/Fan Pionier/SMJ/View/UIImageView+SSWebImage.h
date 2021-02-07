//
//  UIImageView+SSWebImage.h
//  Intaole
//
//  Created by SunSatan on 2020/11/19.
//  Copyright © 2020 SunSatan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ _Nullable loadCompleted)(UIImage *image);

@interface UIImageView (SSWebImage)

- (void)ss_setImageWithURL:(NSString *)url;

- (void)ss_setImageWithURL:(NSString *)url
                 completed:(loadCompleted)completed;

- (void)ss_setImageWithURL:(NSString *)url
          placeholderImage:(NSString *)placeholderImage;

- (void)ss_setImageWithURL:(NSString *)url
          placeholderImage:(NSString *)placeholderImage
                 completed:(loadCompleted)completed;
@end

NS_ASSUME_NONNULL_END
