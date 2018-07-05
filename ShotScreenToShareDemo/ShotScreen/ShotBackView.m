//
//  ShotBackView.m
//  ShotScreenToShareDemo
//
//  Created by yizhiton on 2018/6/22.
//  Copyright © 2018年 yizhiton. All rights reserved.
//

#import "ShotBackView.h"
#import "ShareButton.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define kBottonBtnHeight 76
#define kBottomDeleteBtnHeight 55

typedef enum {
    ShareTypeWechatSession,   //微信好友
    ShareTypeWechatTimeline,  //微信朋友圈
    ShareTypeQQSession,  // QQ好友
    ShareTypeQZone  // QQ朋友圈
} ShareType;

@interface ShotBackView()

@property (nonatomic, strong) UIView * imageBottomView;

@property (nonatomic, strong) UIView * imageBackView;

@property (nonatomic, strong) UILabel * remindLabel;

@end

@implementation ShotBackView

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (UILabel *)remindLabel {
    if (!_remindLabel) {
        _remindLabel = [[UILabel alloc] init];
        _remindLabel.text = @"将此截图分享到微信好友或QQ好友";
        _remindLabel.textAlignment = NSTextAlignmentCenter;
        _remindLabel.font = [UIFont systemFontOfSize:16];
        _remindLabel.textColor = [UIColor grayColor];
    }
    return _remindLabel;
}

- (UIView *)imageBackView {
    if (!_imageBackView) {
        _imageBackView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _imageBackView.backgroundColor = [UIColor lightGrayColor];
    }
    return _imageBackView;
}

- (UIView *)imageBottomView {
    if (!_imageBottomView) {
        _imageBottomView = [[UIView alloc] init];
    }
    return _imageBottomView;
}

- (void) setupUI {
    
    ShareButton * WXSessionBtn = [ShareButton shareButtonWithFrame:CGRectMake(0, 10, SCREEN_WIDTH * 0.5, kBottonBtnHeight) title:@"微信好友" image:[UIImage imageNamed:@"blogo_weixin"]];
    [WXSessionBtn addTarget:self action:@selector(wxSessionClick:) forControlEvents:UIControlEventTouchUpInside];
    
    ShareButton * WXTimelineBtn = [ShareButton shareButtonWithFrame:CGRectMake(SCREEN_WIDTH * 0.5, 10, SCREEN_WIDTH * 0.5, kBottonBtnHeight) title:@"微信朋友圈" image:[UIImage imageNamed:@"blogo_pyq"]];
    [WXTimelineBtn addTarget:self action:@selector(wxTimelineClick:) forControlEvents:UIControlEventTouchUpInside];
    
    ShareButton * QQBtn = [ShareButton shareButtonWithFrame:CGRectMake(0, kBottonBtnHeight + 20, SCREEN_WIDTH * 0.5, kBottonBtnHeight) title:@"QQ好友" image:[UIImage imageNamed:@"blogo_qq"]];
    [QQBtn addTarget:self action:@selector(qqClick:) forControlEvents:UIControlEventTouchUpInside];
    
    ShareButton * QZoneBtn = [ShareButton shareButtonWithFrame:CGRectMake(SCREEN_WIDTH * 0.5, kBottonBtnHeight + 20, SCREEN_WIDTH * 0.5, kBottonBtnHeight) title:@"QQ空间" image:[UIImage imageNamed:@"blogo_qzone"]];
    [QZoneBtn addTarget:self action:@selector(qZoneClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * closeBtn = [self buttonWithTitle:@"" andRect:CGRectMake(SCREEN_WIDTH/5,SCREEN_HEIGHT ,SCREEN_WIDTH*3/5,kBottomDeleteBtnHeight) andSel:@selector(closeBtn:)];
    
    [self addSubview:self.imageBackView];
    [self.imageBackView addSubview:self.remindLabel];
    [self.imageBackView addSubview:self.imageBottomView];
    
    CGFloat bottomViewHeight = kBottonBtnHeight * 2 + 10;
    self.imageBottomView.frame = CGRectMake(0, SCREEN_HEIGHT - bottomViewHeight - 18, SCREEN_WIDTH, bottomViewHeight);
    [self.imageBottomView addSubview:WXSessionBtn];
    [self.imageBottomView addSubview:WXTimelineBtn];
    [self.imageBottomView addSubview:QQBtn];
    [self.imageBottomView addSubview:QZoneBtn];
    [self addSubview:closeBtn];

    [UIView animateWithDuration:1.0 animations:^{
        self.imageBackView.transform = CGAffineTransformMakeScale(0.6, 0.6);
        closeBtn.transform = CGAffineTransformMakeTranslation(0, -kBottomDeleteBtnHeight - 20);
    }];
}

- (UIButton *) buttonWithTitle: (NSString *)title andRect: (CGRect)frame andSel: (SEL)selector{
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    shareBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    shareBtn.frame = frame;
    [shareBtn setImage:[UIImage imageNamed:@"cm2_clock_icn_delete"] forState:UIControlStateNormal];
    [shareBtn.layer setMasksToBounds:YES];

    [shareBtn setTitle:title forState:UIControlStateNormal];
    [shareBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return shareBtn;
}

- (void)setShotImageData:(NSData *)shotImageData {
    _shotImageData = shotImageData;
    
    UIImage *image = [UIImage imageWithData:self.shotImageData];
    
    //显示图片
    UIImageView *imgV = [[UIImageView alloc]initWithImage:image];
    CGFloat imageViewW = SCREEN_WIDTH * 0.6;
    CGFloat imageViewH = SCREEN_HEIGHT * 0.6;
    imgV.frame = CGRectMake((SCREEN_WIDTH - imageViewW) * 0.5, ( SCREEN_HEIGHT - imageViewH)* 0.15, imageViewW, imageViewH);
    
    self.remindLabel.frame = CGRectMake(0, CGRectGetMaxY(imgV.frame) + 8, SCREEN_WIDTH, 30);
    
    [self.imageBackView addSubview:imgV];
}

/**
 微信好友分享
 */
- (void) wxSessionClick:(UIButton *)btn {
    [self wxShareWithType:ShareTypeWechatSession];
}
/**
 微信朋友圈
 */
- (void) wxTimelineClick:(UIButton *)btn {
    [self wxShareWithType:ShareTypeWechatTimeline];
}
/**
 QQ好友
 */
- (void) qqClick:(UIButton *)btn {
    [self qqShareWithType:ShareTypeQQSession];
}
/**
 QQ空间
 */
- (void) qZoneClick:(UIButton *)btn {
    [self qqShareWithType:ShareTypeQZone];
}

/**
 微信分享
 */
- (void) wxShareWithType: (ShareType) type{
    if ([WXApi isWXAppInstalled]) {
        WXMediaMessage * message = [WXMediaMessage message];
        [message setThumbImage:[UIImage imageWithData:self.shotImageData]];
        
        //创建多媒体对象(一定得创建, 不然跳转不了微信)
        WXImageObject *webObj = [WXImageObject object];
        webObj.imageData = self.shotImageData;
        message.mediaObject = webObj;
        
        SendMessageToWXReq * req = [SendMessageToWXReq new];
        req.bText = NO;
        req.scene = type == ShareTypeWechatSession ? WXSceneSession : WXSceneTimeline;
        req.message = message;
    
        [WXApi sendReq:req];
    } else {
        [self noInstallToRemind:@"您尚未安装微信" urlStr:@"itms-apps://itunes.apple.com/cn/app/%E5%BE%AE%E4%BF%A1/id414478124?mt=8"];
    }
}
/**
 QQ分享
 */
- (void) qqShareWithType: (ShareType) type {
    if ([TencentOAuth iphoneQQInstalled]) {
        if (type == ShareTypeQQSession) {   // 分享给好友
            QQApiImageObject *imgObj = [QQApiImageObject objectWithData:self.shotImageData previewImageData:self.shotImageData title:@"新家装通" description:@"QQ分享"];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
            //将内容分享到qq
            [QQApiInterface sendReq:req];
        } else if (type == ShareTypeQZone) {   // 分享到QQ空间
            QQApiImageArrayForQZoneObject *img = [QQApiImageArrayForQZoneObject objectWithimageDataArray:@[self.shotImageData] title:@"新家装通" extMap:nil];
            img.shareDestType = ShareDestTypeQQ;
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
            [QQApiInterface SendReqToQZone:req];
        }
    } else {
        [self noInstallToRemind:@"您尚未安装微信" urlStr:@"itms-apps://itunes.apple.com/cn/app/qq/id444934666?mt=8"];
    }
    
}

/**
 未安装时的提醒
 */
- (void) noInstallToRemind: (NSString *)message urlStr: (NSString *)urlStr {
    [self removeFromSuperview];

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction * confirmAction = [UIAlertAction actionWithTitle:@"前去安装" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL * url = [NSURL URLWithString:urlStr];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }];
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void) closeBtn:(UIButton *)btn {
    [self removeFromSuperview];
}

@end
