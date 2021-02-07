//
//  UIView+action.m
//  Demo
//
//  Created by SunSatan on 2020/11/30.
//

#import "UIView+action.h"
#import <objc/runtime.h>

@interface UIView ()

@property (nonatomic, copy) actionBlock actionBlock;

@end

@implementation UIView (action)

#pragma mark - 点击事件

- (void)ss_addAction:(actionBlock)actionBlock
{
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(action)]];
    self.actionBlock = actionBlock;
}

- (void)action
{
    !self.actionBlock?:self.actionBlock();
}

- (void)setActionBlock:(actionBlock)actionBlock
{
    objc_setAssociatedObject(self, @selector(actionBlock), actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (actionBlock)actionBlock
{
    return objc_getAssociatedObject(self, @selector(actionBlock));
}

@end
