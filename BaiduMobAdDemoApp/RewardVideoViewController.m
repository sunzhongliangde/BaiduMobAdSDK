//
//  RewardVideoViewController.m
//  XAdSDKDevSample
//
//  Created by Yang,Dingjia on 2018/7/10.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "RewardVideoViewController.h"
#import "BaiduMobAdSDK/BaiduMobAdRewardVideo.h"
#import "BaiduMobAdSDK/BaiduMobAdSetting.h"

@interface RewardVideoViewController ()<BaiduMobAdRewardVideoDelegate,UITextFieldDelegate>
@property (nonatomic, strong) BaiduMobAdRewardVideo *reward;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation RewardVideoViewController

#pragma mark - 重要！接入须知：
///激励视频接入流程：
/*
 Init->load->show->load-show->……
 
 Init激励视频对象，必传参数：publisherId、AdUnitTag、delegate。
 */
///注意事项：
/*
 1.   激励视频广告分在线播放和本地播放两种形式。
 1.1   如果采用本地播放则需提前预加载load处理，预加载耗时因广告而异，1秒~5秒之间。
 1.2   如果采用在线播放，无需做任何操作，直接show即可。有播放卡顿风险。
 2.   单次请求的广告不支持多次展现。下次展现前需要重新预加载视频，不做预加载直接show则在线请求并播放。可以在点击关闭操作后重新预加载新广告。
 3. 广告存在有效期，需要一定时间（2小时、非固定值）内展现。如果广告超时未展现，调用show的时候会重新请求广告并在线播放。可以通过isReady判断是否过期。
 4.   监听展现失败rewardedVideoAdShowFailed做异常流程处理。
 5.   检查API是否发生更改。
 */

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *preload = [[UIButton alloc] initWithFrame:(CGRectMake(50, 170, 150, 50))];
    [preload setBackgroundColor:[UIColor grayColor]];
    [preload setTitle:@"预加载视频" forState:UIControlStateNormal];
    [preload addTarget:self action:@selector(preload) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:preload];
    
    UIButton *showVideo = [[UIButton alloc] initWithFrame:(CGRectMake(50, 240, 150, 50))];
    [showVideo setBackgroundColor:[UIColor grayColor]];
    [showVideo setTitle:@"观看激励视频" forState:UIControlStateNormal];
    [showVideo addTarget:self action:@selector(showClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showVideo];
    
    UIButton *isExpire = [[UIButton alloc] initWithFrame:(CGRectMake(50, 310, 150, 50))];
    [isExpire setBackgroundColor:[UIColor grayColor]];
    [isExpire setTitle:@"本地广告是否有效" forState:UIControlStateNormal];
    [isExpire addTarget:self action:@selector(isExpire) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:isExpire];
    
    
    self.textField = [[UITextField alloc] initWithFrame:(CGRectMake(50, 100, 150, 50))];
    self.textField.placeholder = @"更换广告位id";
    self.textField.backgroundColor = [UIColor lightGrayColor];
    self.textField.delegate = self;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.textField];
    
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:(CGRectMake(210, 100, 80, 50))];
    [confirmBtn setBackgroundColor:[UIColor blackColor]];
    [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:(CGRectMake(50, 370, 260, 80))];
    tipsLabel.numberOfLines = 0;
    tipsLabel.text = @"默认无需更换广告位ID，直接点击观看即可";
    [self.view addSubview:tipsLabel];
    
    //****环境集成****//
    [self initParameter];

    // Do any additional setup after loading the view.
}

- (void)initParameter {
    
/// 默认https, 可根据需要关闭App Transport Security Settings，设置关闭BaiduMobAdSetting的supportHttps，以请求http广告，多个产品只需要设置一次.    [BaiduMobAdSetting sharedInstance].supportHttps = NO;
    
    self.reward = [[BaiduMobAdRewardVideo alloc] init];
    
    self.reward.delegate = self;
    self.reward.AdUnitTag = @"5889473";
    self.reward.publisherId = @"ccb60059";
}

- (void)preload {
    [self.reward load];
}

- (void)isExpire {
    BOOL ready = [self.reward isReady];
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"完整观看视频才可获得奖励"
                              message:nil
                              delegate:self
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil];
    if (ready) {
        alertView.title = @"视频广告可用";
        NSLog(@"视频广告可用");
    }else{
        alertView.title = @"视频广告不可用";
        NSLog(@"视频广告不可用");
    }
    
    [alertView show];

}

- (void)showClick {
    
    [self.reward showFromViewController:self];

//    if (self.reward.isReady) {
//        如果要求只能使用本地化播放，可以通过isReady判断是否缓存成功和过期。
//    }
}

- (void)confirmAction {
    self.reward.AdUnitTag = self.textField.text;
    [self.textField resignFirstResponder];
    [self preload];
}

- (void)rewardedVideoAdLoaded:(BaiduMobAdRewardVideo *)video {
    
    [[[UIAlertView alloc]initWithTitle:@"激励视频缓存成功" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
    
    NSLog(@"激励视频缓存成功");
}

- (void)rewardedVideoAdLoadFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    
    [[[UIAlertView alloc]initWithTitle:@"激励视频缓存失败" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
    NSLog(@"激励视频缓存失败，failReason：%d",reason);
}

- (void)rewardedVideoAdShowFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    NSLog(@"激励视频展现失败，failReason：%d",reason);
    //异常情况处理
    [[[UIAlertView alloc]initWithTitle:@"激励视频展现失败" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
}

- (void)rewardedVideoAdDidStarted:(BaiduMobAdRewardVideo *)video {
    NSLog(@"激励视频开始播放");
}

- (void)rewardedVideoAdDidPlayFinish:(BaiduMobAdRewardVideo *)video {
    
    NSLog(@"激励视频完成播放");
}

- (void)rewardedVideoAdDidClick:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    NSLog(@"激励视频LP被点击，progress:%f",progress);
}

- (void)rewardedVideoAdDidClose:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    NSLog(@"激励视频点击关闭,progress:%f",progress);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    self.reward.AdUnitTag = textField.text;
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.reward.AdUnitTag = textField.text;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
