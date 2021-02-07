//
//  UIView+action.h
//  Demo
//
//  Created by SunSatan on 2020/11/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^actionBlock)(void);

@interface UIView (action)

- (void)ss_addAction:(actionBlock)action;

@end

NS_ASSUME_NONNULL_END
