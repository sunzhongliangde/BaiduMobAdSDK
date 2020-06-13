//
//  BaiduMobAdPrerollViewController.m
//  XAdSDKDevSample
//
//  Created by lishan04 on 16/5/5.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#define TimeCountSize 25
#define SkipButtonSize 30

#import "BaiduMobAdPrerollViewController.h"
#import "BaiduMobAdSDK/BaiduMobAdPrerollDelegate.h"
#import "BaiduMobAdSDK/BaiduMobAdPreroll.h"
#import "BaiduMobAdBlankView.h"
#import "XScreenConfig.h"
/*
 视频贴片广告接入：
 可以监听广告返回，根据自身需求绘制对应UI
 */
@interface BaiduMobAdPrerollViewController () <BaiduMobAdPrerollDelegate>
@property (nonatomic, strong) BaiduMobAdPreroll *prerollAd;
@property (nonatomic, strong) UIView *baseview;
@property (nonatomic, strong) UILabel *timecountLabel;
@property (nonatomic, strong) UIButton *skipButton;

@property (nonatomic, assign) NSInteger remainTimeValue;
@property (nonatomic, assign) CGFloat timeInterval;

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) NSTimer *countTimer;
@property (nonatomic, copy)   NSString *adType;
@property (nonatomic, strong) BaiduMobAdBlankView *blankView;

@end

@interface BaiduMobAdPrerollViewController (prerollNative)
@end

@implementation BaiduMobAdPrerollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *loadBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loadBtn.frame = CGRectMake((kScreenWidth-200)/2, 350, 200, 50);
    
    [loadBtn setTitle:@"请求视频贴片" forState:UIControlStateNormal];
    [loadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loadBtn.backgroundColor = [UIColor grayColor];
    [loadBtn addTarget:self action:@selector(load) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loadBtn];
    
    [self load];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //页面退出，手动关闭广告
    [self skipClick];
}

- (void)load {
    [self.blankView removeFromSuperview];
    //1. 创建贴片视图
    if (!self.baseview) {
        CGFloat origin_x = (self.view.bounds.size.width-320)/2;
        self.baseview = [[UIView alloc]initWithFrame:CGRectMake(origin_x, 100, 320, 180)];
        [self.view addSubview:self.baseview];
    }
    
    //2. 创建贴片广告对象
    if (!self.prerollAd) {
        self.prerollAd = [[BaiduMobAdPreroll alloc] init];
        self.prerollAd.publisherId = @"ccb60059";
        self.prerollAd.adId = @"2058633";
        self.prerollAd.enableLocation = YES;
        self.prerollAd.renderBaseView = self.baseview;
        self.prerollAd.delegate = self;
    }
    [self.prerollAd load];
}

#pragma BaiduMobAdPrerollDelegate

- (void)prerollAdloadSuccess:(BaiduMobAdPreroll *)preroll withAdMaterialType:(NSString *)adMaterialType {
    NSLog(@"贴片广告：广告请求成功");
    self.adType = adMaterialType;
}

- (void)prerollAdDidStart:(BaiduMobAdPreroll *)preroll {
    
    NSLog(@"贴片广告：广告展现成功");
    //区分不同广告类型，根据自身需求绘制对应UI
    if (![self.adType isEqualToString:@"video"]) {
        self.remainTimeValue = 6;
    }
    [self setRemainTime];//添加倒计时样式（可自定义）
    [self setSkip];//添加跳过按钮样式（可自定义）
}

- (void)prerollAdDidFailed:(BaiduMobAdPreroll *)preroll withError:(BaiduMobFailReason)reason {
    NSLog(@"贴片广告：广告请求失败:%d",reason);
    
    if (!self.blankView) {
        self.blankView = [[BaiduMobAdBlankView alloc] initWithFrame:(self.baseview.frame)];
    }
    [self.view addSubview:self.blankView];
}

- (void)prerollAdDidFinish:(BaiduMobAdPreroll *)preroll {
    NSLog(@"贴片广告：didAdFinish");
}

- (void)prerollAdDidClicked:(BaiduMobAdPreroll *)preroll {
    NSLog(@"贴片广告：didAdClicked");
}

#pragma mark - 自定义UI视觉

- (void)setRemainTime {
    
    if (!self.timecountLabel) {
        CGFloat origin_x = self.baseview.frame.size.width-TimeCountSize-15;
        self.timecountLabel = [[UILabel alloc]initWithFrame:CGRectMake(origin_x, 15, TimeCountSize, TimeCountSize)];
        self.timecountLabel.textAlignment = NSTextAlignmentCenter;
        self.timecountLabel.font = [UIFont boldSystemFontOfSize:13];
        self.timecountLabel.textColor = [UIColor whiteColor];
        self.timecountLabel.backgroundColor = [UIColor grayColor];
        self.timecountLabel.layer.cornerRadius = TimeCountSize/2;
        self.timecountLabel.layer.borderWidth = 1;
        self.timecountLabel.layer.masksToBounds = YES;
        
        [self.baseview addSubview:self.timecountLabel];
    }
    
    //视频类型的倒计时建议跟随视频播放时长走，0.1timeInterval保证倒计时不卡顿
    if ([self.adType isEqualToString:@"video"]) {
        self.timeInterval = 0.1;
    }else {
        self.timeInterval = 1;
    }
    
    if (!self.countTimer) {
        self.countTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(setRemainTime) userInfo:nil repeats:YES];
        [self.countTimer fire];
    }
    
    self.timecountLabel.text = [NSString stringWithFormat:@"%ld",self.remainTimeValue];
    
    if ([self.adType isEqualToString:@"video"]) {
        self.remainTimeValue =  (NSInteger)([self.prerollAd duration]- [self.prerollAd currentTime]);
    }else {
        self.remainTimeValue -= 1;
    }
    
    if (self.remainTimeValue == 0) {
        [self hiddenTimeCountLabel];
    }
}

- (void)hiddenTimeCountLabel {
    
    [self.countTimer invalidate];
    self.countTimer = nil;
    self.timecountLabel.hidden = YES;
}


- (void)setSkip {
    
    if (!self.skipButton) {
        
        self.skipButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 15, SkipButtonSize, SkipButtonSize)];
        [self.skipButton setBackgroundColor:[UIColor grayColor]];
        self.skipButton.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [self.skipButton setTitle:@"跳过" forState:UIControlStateNormal];
        [self.skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.skipButton addTarget:self action:@selector(skipClick) forControlEvents:UIControlEventTouchUpInside];
        self.skipButton.layer.cornerRadius = SkipButtonSize/2;
        self.skipButton.layer.borderWidth = 1;
        self.skipButton.layer.masksToBounds = YES;
        
        [self.baseview addSubview:self.skipButton];
    }
}

//退出广告时，需要手动关闭广告
- (void)skipClick {
    
    [self.prerollAd close];
    [self.prerollAd.renderBaseView removeFromSuperview];
}

@end
