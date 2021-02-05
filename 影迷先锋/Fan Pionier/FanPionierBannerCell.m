//
//  FanPionierBannerCell.m
//  FanPionier
//
//  Created by 卫宫巨侠欧尼酱 on 2021/1/10.
//  Copyright © 2021 SK. All rights reserved.
//

#import "FanPionierBannerCell.h"

@implementation FanPionierBannerCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.FanPionierBannerImage = [UIImageView new];
        self.FanPionierBannerImage.contentMode = UIViewContentModeScaleAspectFill;
        self.FanPionierBannerImage.layer.masksToBounds = YES;
        [self.contentView addSubview:self.FanPionierBannerImage];
        
        [self.FanPionierBannerImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
        UIImageView *FanPionierShaw = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shaw"]];
        [self.FanPionierBannerImage addSubview:FanPionierShaw];
        
        [FanPionierShaw mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.FanPionierBannerImage);
        }];
        
        self.FanPionierBannerTitle = [UILabel new];
        self.FanPionierBannerTitle.alpha = 0.8;
        self.FanPionierBannerTitle.textColor = [UIColor whiteColor];
        self.FanPionierBannerTitle.numberOfLines = 2;
        self.FanPionierBannerTitle.font = SKTitleFont(20);
        self.FanPionierBannerTitle.textAlignment = NSTextAlignmentCenter;
        [self.FanPionierBannerImage addSubview:self.FanPionierBannerTitle];
        
        [self.FanPionierBannerTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(FanPionierShaw).offset(8);
            make.right.bottom.equalTo(FanPionierShaw).offset(-8);
        }];
        
        self.contentView.layer.masksToBounds = YES;
        self.contentView.layer.cornerRadius = 8;
        
    }
    return self;
}

@end
