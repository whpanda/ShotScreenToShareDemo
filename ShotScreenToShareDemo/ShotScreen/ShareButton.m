//
//  ShareButton.m
//  ShotScreenToShareDemo
//
//  Created by yizhiton on 2018/7/4.
//  Copyright © 2018年 yizhiton. All rights reserved.
//

#import "ShareButton.h"

@implementation ShareButton

+ (instancetype)shareButtonWithFrame:(CGRect)frame title:(NSString *)title image:(UIImage *)image {
    ShareButton * shareBtn = [ShareButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = frame;
    [shareBtn setTitle:title forState:UIControlStateNormal];
    [shareBtn setImage:image forState:UIControlStateNormal];
    [shareBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    return shareBtn;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView sizeToFit];
    CGSize imageSize = self.imageView.image.size;
    self.imageView.frame = CGRectMake((self.bounds.size.width - imageSize.width) / 2, 0, imageSize.width, imageSize.height);
    self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame) + 8, self.bounds.size.width, 18);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

@end
