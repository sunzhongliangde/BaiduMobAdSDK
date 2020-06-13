//
//  AppDelegate.m
//  BaiduMobAdDemoApp
//
//  Created by lishan04 on 16/3/23.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTableViewController.h"
#import "BaiduMobAdSDK/BaiduMobAdSplash.h"
#import "BaiduMobAdSDK/BaiduMobAdSetting.h"
#import "XScreenConfig.h"

@interface AppDelegate ()<BaiduMobAdSplashDelegate>
@property (nonatomic, strong) BaiduMobAdSplash *splash;
@property (nonatomic, strong) UIView *customSplashView;
@property (nonatomic, strong) UIImageView *logoImage;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    MainTableViewController *mainController  = [[MainTableViewController alloc]init];
    UINavigationController *naviController = [[UINavigationController alloc]initWithRootViewController:mainController];
    self.window.rootViewController = naviController;
    [self.window makeKeyAndVisible];
    
#pragma mark - 广告配置
    
    /*
     开屏广告需要通过DataSource的形式配置APPSID，支持自定义半屏和全屏
     注意开屏尺寸必须大于200*200。
     baiduSplashContainer需要全部在window内
     开机画面不建议旋转
     */
    
///TODO: ATS默认开启状态, 可根据需要关闭App Transport Security Settings，设置关闭BaiduMobAdSetting的supportHttps，以请求http广告，多个产品只需要设置一次.
//    [BaiduMobAdSetting sharedInstance].supportHttps = NO;
    //设置缓存阀值，单位M, 取值范围15M-100M,默认30M
//    [BaiduMobAdSetting setMaxVideoCacheCapacityMb:30];
    
    //全屏开屏广告
//    [self loadFullScreenSplash];
    //自定义半屏开屏广告
    [self loadCustomSplash];
    
    return YES;
}

/**
 *  加载全屏开屏
 */
- (void) loadFullScreenSplash {
    BaiduMobAdSplash *splash = [[BaiduMobAdSplash alloc] init];
    splash.delegate = self;
    splash.AdUnitTag = @"2058492";
    splash.canSplashClick = YES;
    [splash loadAndDisplayUsingKeyWindow:self.window];
    self.splash = splash;
}

/**
 *  加载自定义开屏
 */
- (void) loadCustomSplash {
    
    //可以在customSplashView上显示包含icon的自定义开屏
    BaiduMobAdSplash *splash = [[BaiduMobAdSplash alloc] init];
    splash.delegate = self;
    splash.AdUnitTag = @"2058492";
    splash.canSplashClick = YES;
    self.splash = splash;
    
    CGRect spRect = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 120);
    if (ISIPHONEX) {
        spRect = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 120 -IPHONEX_TABBAR_FIX_HEIGHT);
    }
    UIView *baiduSplashContainer = [[UIView alloc]initWithFrame:spRect];
    
    self.customSplashView = [[UIView alloc]initWithFrame:self.window.frame];
    self.customSplashView.backgroundColor = [UIColor whiteColor];
    [self.window addSubview:self.customSplashView];
    [self.customSplashView addSubview:baiduSplashContainer];
    
    //在的baiduSplashContainer里展现百度广告
    [splash loadAndDisplayUsingContainerView:baiduSplashContainer];

    //logo区域
    self.logoImage = [[UIImageView alloc] init];
    CGFloat lW = kScreenWidth - 60;
    CGFloat lH = lW * 81 / 349;
    CGFloat lX = 30.0f;
    CGFloat lY =kScreenHeight - 120;
    if (ISIPHONEX) {
        lY = kScreenHeight - 120 - IPHONEX_TABBAR_FIX_HEIGHT;
    }
    self.logoImage.frame = CGRectMake(lX, lY, lW, lH);
    self.logoImage.backgroundColor = [UIColor redColor];
    [self.logoImage setImage:[UIImage imageNamed:@"logo.png"]];
    [[[UIApplication sharedApplication].delegate window] addSubview:self.logoImage];
}

/**
 *  展示结束or展示失败后, 手动移除splash和delegate
 */
- (void) removeSplash {
    if (self.splash) {
        self.splash.delegate = nil;
        self.splash = nil;
        [self.logoImage removeFromSuperview];
        [self.customSplashView removeFromSuperview];
    }
}

- (NSString *)publisherId {
    return @"ccb60059";
}

- (void)splashDidClicked:(BaiduMobAdSplash *)splash {
    NSLog(@"splashDidClicked");
}

- (void)splashDidDismissLp:(BaiduMobAdSplash *)splash {
    NSLog(@"splashDidDismissLp");
    //可以在落地页的关闭回调中关闭开屏广告
//    [self removeSplash];
}

- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash {
    NSLog(@"splashDidDismissScreen");
    [self removeSplash];
}

- (void)splashSuccessPresentScreen:(BaiduMobAdSplash *)splash {
    NSLog(@"splashSuccessPresentScreen");
}

- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason)reason {
    NSLog(@"splashlFailPresentScreen withError %d", reason);
    [self removeSplash];
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

@end
