//
//  BaiduMobAdNormalInterstitialViewController.m
//  XAdSDKDevSample
//
//  Created by LiYan on 16/4/13.
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import "BaiduMobAdNormalInterstitialViewController.h"
#import "XScreenConfig.h"

#define kCustomIntWidth 300
#define kCustomIntHeight 300

/*
 插屏广告接入：
 插屏分三种形式：全屏、半屏无倒计时、半屏有倒计时
 推荐使用后两种1：1尺寸接入
 */
@interface BaiduMobAdNormalInterstitialViewController () <UITextFieldDelegate>
@property (nonatomic, assign) int curType;
@property (nonatomic, strong) UIView *customAdView;

@property (nonatomic, strong) UIButton *loadButton;
@property (nonatomic, strong) UIButton *showButton;
@property (nonatomic, strong) UIButton *loadCustomButtonWithCount;
@property (nonatomic, strong) UIButton *loadCustomButtonWithNoCount;

@property (nonatomic, strong) UITextField *widthTextField;
@property (nonatomic, strong) UITextField *heightTextField;
@property (nonatomic, strong) UITextField *unitTextField;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@end

@implementation BaiduMobAdNormalInterstitialViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.curType = 0;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setupUI];
}

- (void)setupUI {
    
    
    UILabel *unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 50, 50, 20)];
    unitLabel.text = @"代码位ID:";
    [unitLabel sizeToFit];
    [self.view addSubview:unitLabel];
    
    self.unitTextField = [[UITextField alloc] initWithFrame:(CGRectMake(CGRectGetMaxX(unitLabel.frame)+10, 40, 180, 30))];
    self.unitTextField.placeholder = @"2058554";
    self.unitTextField.delegate = self;
    self.unitTextField.borderStyle = UITextBorderStyleBezel;
    [self.view addSubview:self.unitTextField];
    
    UILabel *widthLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 100, 50, 20)];
    widthLabel.text = @"width:";
    [widthLabel sizeToFit];
    [self.view addSubview:widthLabel];

    self.widthTextField = [[UITextField alloc] initWithFrame:(CGRectMake(CGRectGetMaxX(widthLabel.frame)+10, 90, 100, 30))];
    self.widthTextField.placeholder = @"300";
    self.widthTextField.delegate = self;
    self.widthTextField.borderStyle = UITextBorderStyleBezel;
    [self.view addSubview:self.widthTextField];
    
    UILabel *heightLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.widthTextField.frame)+10, 100, 50, 20)];
    heightLabel.text = @"height:";
    [heightLabel sizeToFit];
    [self.view addSubview:heightLabel];
    
    self.heightTextField = [[UITextField alloc] initWithFrame:(CGRectMake(CGRectGetMaxX(heightLabel.frame)+10, 90, 100, 30))];
    self.heightTextField.placeholder = @"300";
    self.heightTextField.delegate = self;
    self.heightTextField.borderStyle = UITextBorderStyleBezel;
    [self.view addSubview:self.heightTextField];
    
    
    UIButton *loadBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loadBtn.frame = CGRectMake(20, 150, 200, 50);
    [loadBtn setTitle:@"请求全屏插屏" forState:UIControlStateNormal];
    loadBtn.tag = 101;
    [loadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loadBtn.backgroundColor = [UIColor grayColor];
    [loadBtn addTarget:self action:@selector(pressToLoadAd:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loadBtn];
    self.loadButton = loadBtn;
    
    UIButton *loadCustomButtonWithCount = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loadCustomButtonWithCount.frame = CGRectMake(20, CGRectGetMaxY(loadBtn.frame)+50, 200, 50);
    [loadCustomButtonWithCount setTitle:@"请求前贴插屏" forState:UIControlStateNormal];
    loadCustomButtonWithCount.tag = 102;
    [loadCustomButtonWithCount setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    loadCustomButtonWithCount.backgroundColor = [UIColor cyanColor];
    [loadCustomButtonWithCount addTarget:self action:@selector(pressToLoadAd:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loadCustomButtonWithCount];
    self.loadCustomButtonWithCount = loadCustomButtonWithCount;
    
    UIButton *loadCustomButtonWithNoCount = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loadCustomButtonWithNoCount.frame = CGRectMake(20, CGRectGetMaxY(loadCustomButtonWithCount.frame)+50, 200, 50);
    [loadCustomButtonWithNoCount setTitle:@"请求暂停插屏" forState:UIControlStateNormal];
    [loadCustomButtonWithNoCount setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    loadCustomButtonWithNoCount.tag = 103;
    loadCustomButtonWithNoCount.backgroundColor = [UIColor yellowColor];
    [loadCustomButtonWithNoCount addTarget:self action:@selector(pressToLoadAd:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loadCustomButtonWithNoCount];
    self.loadCustomButtonWithNoCount = loadCustomButtonWithNoCount;
}

- (void)pressToLoadAd:(UIButton *)btn {
///TODO: ATS默认开启状态, 可根据需要关闭App Transport Security Settings，设置关闭BaiduMobAdSetting的supportHttps，以请求http广告，多个产品只需要设置一次.    [BaiduMobAdSetting sharedInstance].supportHttps = NO;
    
    [self.unitTextField resignFirstResponder];
    [self.widthTextField resignFirstResponder];
    [self.heightTextField resignFirstResponder];
    
    self.interstitialAdView = [[BaiduMobAdInterstitial alloc]init];
    self.interstitialAdView.AdUnitTag = @"2058554";
    if (self.unitTextField.text && ![self.unitTextField.text isEqualToString:@""]) {
        self.interstitialAdView.AdUnitTag = self.unitTextField.text;
    }

    self.interstitialAdView.delegate = self;
    
    self.width = [self.widthTextField.text intValue] ? : kCustomIntWidth;
    self.height = [self.heightTextField.text intValue] ? : kCustomIntHeight;
    
    switch (btn.tag) {
        case 101:
            self.interstitialAdView.interstitialType = BaiduMobAdViewTypeInterstitialOther;
            [self.interstitialAdView load];
            _curType = 1;
            break;
        case 102:
            self.interstitialAdView.interstitialType = BaiduMobAdViewTypeInterstitialBeforeVideo;
            [self.interstitialAdView loadUsingSize:CGRectMake(0, 0, self.width, self.height)];
            _curType = 2;
            break;
        case 103:
            self.interstitialAdView.interstitialType = BaiduMobAdViewTypeInterstitialPauseVideo;
            [self.interstitialAdView loadUsingSize:CGRectMake(0, 0, self.width, self.height)];
            _curType = 3;
            break;
        default:
            break;
    }
}

- (void)pressToShowAd:(UIButton *)btn {
    if (self.interstitialAdView.isReady) {
        if (_curType == 1) {
            [self.interstitialAdView presentFromRootViewController:self];
        } else {
            
            CGFloat origin_x = (kScreenWidth-self.width)/2;
            CGFloat origin_y = (kScreenHeight-self.height)/3;
            
            UIView *customAdView = [[UIView alloc]initWithFrame:CGRectMake(origin_x, origin_y, self.width, self.height)];
            customAdView.backgroundColor = [UIColor clearColor];
            [self.view addSubview:customAdView];
            [self.interstitialAdView presentFromView:customAdView];
            self.customAdView = customAdView;
        }
    } else {
        NSLog(@"not ready yet");
    }
}

- (NSString *)publisherId {
    return @"ccb60059";
}

- (BOOL) enableLocation {
    return NO;
}

- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    NSLog(@"load ready!");
    if (_curType != 4) {
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"加载成功"
                                                     message:@"点击显示广告"
                                                    delegate:self
                                           cancelButtonTitle:@"ok"
                                           otherButtonTitles: nil];
        [alv show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self pressToShowAd:nil];
    
}/**
  *  广告预加载失败
  */
- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"加载失败"
                                                 message:@""
                                                delegate:self
                                       cancelButtonTitle:@"ok"
                                       otherButtonTitles: nil];
    [alv show];
    self.interstitialAdView.delegate = nil;
    self.interstitialAdView = nil;
}

/**
 *  广告即将展示
 */
- (void)interstitialWillPresentScreen:(BaiduMobAdInterstitial *)interstitial {
    NSLog(@"will show");
}

/**
 *  广告展示成功
 */
- (void)interstitialSuccessPresentScreen:(BaiduMobAdInterstitial *)interstitial {
    NSLog(@"succ show");
}

/**
 *  广告展示失败
 */
- (void)interstitialFailPresentScreen:(BaiduMobAdInterstitial *)interstitial withError:(BaiduMobFailReason) reason {
    NSLog(@"fail rea %d", reason);
}

/**
 *  广告展示被用户点击时的回调
 */
- (void)interstitialDidAdClicked:(BaiduMobAdInterstitial *)interstitial {
    NSLog(@"did click");
}

/**
 *  广告展示结束
 *  调用展示的时候, 如果与请求时的横竖屏方向不同的话, 不会展示广告并直接调用该方法.
 *  展示出来以后屏幕旋转, 广告会自动关闭并直接调用该方法.
 */
- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)interstitial{
    NSLog(@"succ dismiss");
    if (_curType == 2 || _curType == 3) {
        [self.customAdView removeFromSuperview];
    }
    self.interstitialAdView = nil;
}

/**
 *  广告详情页被关闭
 */
- (void)interstitialDidDismissLandingPage:(BaiduMobAdInterstitial *)interstitial {
    NSLog(@"succ close lp");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

@end
