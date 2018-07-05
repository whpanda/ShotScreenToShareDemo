//
//  AppDelegate.m
//  ShotScreenToShareDemo
//
//  Created by yizhiton on 2018/6/22.
//  Copyright © 2018年 yizhiton. All rights reserved.
//

#import "AppDelegate.h"
#import "ShotBackView.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface AppDelegate ()<WXApiDelegate, QQApiInterfaceDelegate>

@property (nonatomic, strong) ShotBackView * backView;

@property (nonatomic, strong) TencentOAuth * tencent;

@end

static NSString * const WXAppId = @"wx4aa00f4dd49fd1c6";
static NSString * const TecentAppId = @"tencent1107012360";

@implementation AppDelegate

- (ShotBackView *)backView {
    if (!_backView) {
        _backView = [[ShotBackView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    }
    return _backView;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [WXApi registerApp:@"wx4aa00f4dd49fd1c6"];
    _tencent = [[TencentOAuth alloc] initWithAppId:@"1107012360" andDelegate:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenShotMethod) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([url.scheme isEqualToString:WXAppId]) {  // 微信
        return [WXApi handleOpenURL:url delegate:self];
    } else if ([url.scheme isEqualToString:TecentAppId]) {
        [QQApiInterface handleOpenURL:url delegate:self];
        return [TencentOAuth HandleOpenURL:url];
    } else {
        return YES;
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([url.scheme isEqualToString:WXAppId]) {  // 微信
        return [WXApi handleOpenURL:url delegate:self];
    } else if ([url.scheme isEqualToString:TecentAppId]) {
        [QQApiInterface handleOpenURL:url delegate:self];
        return [TencentOAuth HandleOpenURL:url];
   } else {
        return YES;
    }
}

- (void) screenShotMethod {
    
    //获取截屏图片
    self.backView.shotImageData = [self imageDataScreenShot];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.backView];

}

- (NSData *)imageDataScreenShot{
    CGSize imageSize = [UIScreen mainScreen].bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
}

// QQ和微信的回调
- (void)onResp:(id)resp {
    [self.backView removeFromSuperview];
}

@end
