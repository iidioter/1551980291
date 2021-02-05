//
//  FanPionierHomeController.h
//  FanPionier
//
//  Created by 卫宫巨侠欧尼酱 on 2021/1/10.
//  Copyright © 2021 SK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface FanPionierHomeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *FanPionierCount;
@property (weak, nonatomic) IBOutlet UIView *FanPionierLeft;

- (void)FanPionierUpdate:(NSArray *)FanPionierInfo;

@end


@interface FanPionierHomeController : UITableViewController

@property (assign ,nonatomic) NSInteger FanPionierCollect;

@end

NS_ASSUME_NONNULL_END
