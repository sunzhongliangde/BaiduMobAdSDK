//
//  BaiduMobAdFirstViewController.m
//  APIExampleApp
//
//  Created by jaygao on 11-10-26.
//  Copyright (c) 2011年 Baidu,Inc. All rights reserved.
//

#import "BaiduMobAdFirstViewController.h"
#import "BaiduMobAdSDK/BaiduMobAdView.h"
#import "BaiduMobAdSDK/BaiduMobAdSetting.h"
#import "XScreenConfig.h"
#import "BaiduMobAdSDK/BaiduMobAdDelegateProtocol.h"

#define kBannerAdUnit_20_3 @"3722589"
#define kBannerAdUnit_7_3 @"3722704"
#define kBannerAdUnit_3_2 @"3722694"
#define kBannerAdUnit_2_1 @"3722709"

#define kBannerStyle_20_3 @"20:3"
#define kBannerStyle_7_3 @"7:3"
#define kBannerStyle_3_2 @"3:2"
#define kBannerStyle_2_1 @"2:1"
#define kLabelHeight 60.0f
#define kImageLeft 15.0f
#define kImageSizeCut 30.0f
#define kTitleMoreHeight 0.0f
/*
 横幅广告接入：
 横幅分四种尺寸 推荐使用20：3尺寸接入，务必严格按照该宽高比例
 */
@interface BaiduMobAdFirstViewController() <BaiduMobAdViewDelegate>

@property (nonatomic, strong) UIScrollView *scollview;
@property (nonatomic, strong) NSMutableArray *bannerViewArray;
@property (nonatomic, strong) BaiduMobAdView *bannerView;

@end

@implementation BaiduMobAdFirstViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"横幅广告示例";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addBanners];
}

- (void)addBanners {
    
    NSArray *adUnitTags = @[kBannerStyle_20_3,kBannerStyle_7_3,kBannerStyle_3_2,kBannerStyle_2_1];
    CGFloat navH = [[UIApplication sharedApplication] statusBarFrame].size.height;
    navH += self.navigationController.navigationBar.frame.size.height;
    
    for (int i=0; i<adUnitTags.count; i++) {
        
        NSString *adUnit = [adUnitTags objectAtIndex:i];
        CGFloat origin_y = i*(kLabelHeight+1)+navH;
        
        [self addBannerHeaderViewWithFrame:CGRectMake(0, origin_y, kScreenWidth, kLabelHeight) andLabelText:adUnit index:i];

    }
    
    [self addBannerWithAdIndex:0];
}

- (void)addBannerHeaderViewWithFrame:(CGRect)frame andLabelText:(NSString *)text index:(int)index {
    
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.tag = index;
    [self.view addSubview:headerView];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(kImageLeft, kImageLeft + kTitleMoreHeight, kLabelHeight - kImageSizeCut, kLabelHeight - kImageSizeCut)];
    imageView.image = [UIImage imageNamed:@"banner"];
    [headerView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(kLabelHeight, kTitleMoreHeight, 200, kLabelHeight)];
    label.text = [NSString stringWithFormat:@"点击展示%@横幅广告",text];
    
    [headerView addSubview:label];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadBannerAdWithTap:)];
    [headerView addGestureRecognizer:tap];

    headerView.backgroundColor = [UIColor orangeColor];

}

- (void)loadBannerAdWithTap:(UITapGestureRecognizer *)tap {
    
    [self addBannerWithAdIndex:tap.view.tag];
}

- (void)addBannerWithAdIndex:(NSInteger)index{
    
///TODO: ATS默认开启状态, 可根据需要关闭App Transport Security Settings，设置关闭BaiduMobAdSetting的supportHttps，以请求http广告，多个产品只需要设置一次.    [BaiduMobAdSetting sharedInstance].supportHttps = NO;

    //load横幅
    [self.bannerView removeFromSuperview];
    self.bannerView = [[BaiduMobAdView alloc] init];
    self.bannerView.AdType = BaiduMobAdViewTypeBanner;
    self.bannerView.delegate = self;
    [self.view addSubview:self.bannerView];
    switch (index) {
        case 0:
            self.bannerView.AdUnitTag = kBannerAdUnit_20_3;
            self.bannerView.frame = CGRectMake(0, kScreenHeight-(kScreenWidth * 3.0/20.0)-50, kScreenWidth, kScreenWidth * 3.0/20.0);
            break;
        case 1:
            self.bannerView.AdUnitTag = kBannerAdUnit_7_3;
            self.bannerView.frame = CGRectMake(0, kScreenHeight-(kScreenWidth * 3.0/7.0)-50, kScreenWidth, kScreenWidth * 3.0/7.0);
            break;
        case 2:
            self.bannerView.AdUnitTag = kBannerAdUnit_3_2;
            self.bannerView.frame = CGRectMake(0, kScreenHeight-(kScreenWidth * 2.0/3.0)-50, kScreenWidth, kScreenWidth * 2.0/3.0);
            break;
        case 3:
            self.bannerView.AdUnitTag = kBannerAdUnit_2_1;
            self.bannerView.frame = CGRectMake(0, kScreenHeight-(kScreenWidth/2)-50, kScreenWidth, kScreenWidth/2);
            break;
            
        default:
            break;
    }
    [self.bannerView start];
}

- (void)addBackgroundViewWithFrame:(CGRect)frame {
    UIView *backgroundView = [[UIView alloc]initWithFrame:frame];
    backgroundView.backgroundColor = [UIColor grayColor];
    [self.scollview addSubview:backgroundView];
}

- (NSString *)publisherId {
    return  @"ccb60059"; //@"your_own_app_id";注意，iOS和android的app请使用不同的app ID
}

- (BOOL)enableLocation {
    //启用location会有一次alert提示
    return YES;
}

- (void)willDisplayAd:(BaiduMobAdView *)adview {
    [self.scollview addSubview:adview];
    NSLog(@"横幅广告: will display ad");
}

- (void)failedDisplayAd:(BaiduMobFailReason)reason {
    [[[UIAlertView alloc]initWithTitle:@"该广告位暂无广告返回" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
    [self.bannerView removeFromSuperview];
    NSLog(@"横幅广告: failedDisplayAd %d", reason);
}

- (void)didAdImpressed {
    NSLog(@"横幅广告: didAdImpressed");
}

- (void)didAdClicked {
    NSLog(@"横幅广告: didAdClicked");
}

//点击关闭的时候移除广告
- (void)didAdClose {
//    [sharedAdView removeFromSuperview];
    NSLog(@"横幅广告: didAdClose");
}
//人群属性接口
/**
 *  - 关键词数组
 */
- (NSArray*)keywords {
    NSArray* keywords = [NSArray arrayWithObjects:@"测试",@"关键词", nil];
    return keywords;
}

/**
 *  - 用户性别
 */
- (BaiduMobAdUserGender) userGender {
    return BaiduMobAdMale; 
}

/**
 *  - 用户生日
 */
- (NSDate*) userBirthday {
    NSDate* birthday = [NSDate dateWithTimeIntervalSince1970:0];
    return birthday;
}

/**
 *  - 用户城市
 */
- (NSString*)userCity {
    return @"上海";
}


/**
 *  - 用户邮编
 */
- (NSString*)userPostalCode {
    return @"435200";
}


/**
 *  - 用户职业
 */
- (NSString*)userWork {
    return @"程序员";
}

/**
 *  - 用户最高教育学历
 *  - 学历输入数字，范围为0-6
 *  - 0表示小学，1表示初中，2表示中专/高中，3表示专科
 *  - 4表示本科，5表示硕士，6表示博士
 */
- (NSInteger)userEducation {
    return  5;
}

/**
 *  - 用户收入
 *  - 收入输入数字,以元为单位
 */
- (NSInteger)userSalary {
    return 10000;
}

/**
 *  - 用户爱好
 */
- (NSArray*)userHobbies {
    NSArray* hobbies = [NSArray arrayWithObjects:@"测试",@"爱好", nil];
    return hobbies;
}

/**
 *  - 其他自定义字段
 */
- (NSDictionary *)userOtherAttributes {
    NSMutableDictionary* other = [[NSMutableDictionary alloc] init];
    [other setValue:@"测试" forKey:@"测试"];
    return other;
}

/**
 需要在页面销毁的地方remove广告视图
 */
- (void)dealloc {
    
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[BaiduMobAdView class]]) {
            [subView removeFromSuperview];
        }
    }
}

@end
