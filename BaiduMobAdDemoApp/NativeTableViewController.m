//
//  ViewController.m
//  DemoNativeAd
//
//  Created by houshunwei on 15-6-9.
//  Copyright (c) 2015年 baidu. All rights reserved.
//

#import "NativeTableViewController.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeAdView.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeAdDelegate.h"
#import "BaiduMobAdSDK/BaiduMobAdNative.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeAdObject.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeWebView.h"
#import "BaiduMobAdSDK/BaiduMobAdSmartFeedView.h"
#import "XScreenConfig.h"
#import "MJRefresh.h"
#import "BaiduMobAdBlankView.h"

//type = normal
#define ADID_NORMAL @"2058621" //信息流
#define ADID_MOREPICS @"6443255" //信息流多图
#define ADID_SMARTFEED @"6481011" //智能优选 6481011

//type = html
#define ADID_TYPE1  @"4393166" //组图模板
#define ADID_TYPE2  @"4393179" //图文模板
#define ADID_TYPE3  @"2403627" //轮播图文模板
#define ADID_TYPE4  @"4394006" //轮播大图模板


/*
信息流接入指南：
信息流主要分元素、模板、视频三类，需要根据不同的广告返回创建对应的View。
1. 创建BaiduMobAdNative对象，初始化publisherId、adid
2. 监听delegate。
3. 在nativeAdObjectsSuccessLoad方法中获取广告元素，绘制信息流view,注意是Array，还有object类型。
4. 根据需求渲染信息流view
5. 注意信息流需要开发者手动发送曝光和点击事件，涉及计费！
*/

@interface NativeTableViewController ()<BaiduMobAdNativeAdDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BaiduMobAdNative *native;
@property (nonatomic, strong) NSMutableArray *adViewArray;
@property (nonatomic, strong) NSMutableArray *adsArray;
@property (nonatomic, strong) BaiduMobAdBlankView *blankView;

@end

@implementation NativeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.toBeChangedPublisherId = @"ccb60059";
    self.toBeChangedApid = ADID_NORMAL;
    
    //设置开发者自己处理View点击事件,只需要设置一次。默认为NO
    [BaiduMobAdNativeAdView dealTapGesture:NO];
    [self setupUI];

}

#pragma mark - setupUI

- (void)setupUI {

    self.adViewArray = [NSMutableArray array];
    self.adsArray = [NSMutableArray array];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"切换样式" style:UIBarButtonItemStylePlain target:self action:@selector(pressToShowAdTypes)];
    
    CGFloat navH = [[UIApplication sharedApplication] statusBarFrame].size.height;
    navH += self.navigationController.navigationBar.frame.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navH, kScreenWidth, kScreenHeight-navH)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
    [self.view addSubview:self.tableView];

    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
        
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
    }
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.adViewArray removeAllObjects];
        [self.adsArray removeAllObjects];
        [self pressToLoadAd:nil];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self pressToLoadAd:nil];
    }];
    
    [self pressToLoadAd:nil];
}

- (void) pressToShowAdTypes {
    
    [self.adViewArray removeAllObjects];
    [self.adsArray removeAllObjects];
    UIAlertController *alc = [UIAlertController alertControllerWithTitle:@"选择要展示的样式" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIPopoverPresentationController *popover = alc.popoverPresentationController;
    if (popover) {
        popover.sourceView = self.view;
        popover.sourceRect = CGRectMake(0, 0, 1, 1);
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    __weak __typeof(self)weakSelf = self;
    UIAlertAction *actNormal = [UIAlertAction actionWithTitle:@"大图+ICON+描述" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.toBeChangedApid = ADID_NORMAL;
        [strongSelf pressToLoadAd:nil];
    }];
    UIAlertAction *actMorePics = [UIAlertAction actionWithTitle:@"信息流三图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.toBeChangedApid = ADID_MOREPICS;
        [strongSelf pressToLoadAd:nil];
    }];
    UIAlertAction *actType1 = [UIAlertAction actionWithTitle:@"三图模板" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.toBeChangedApid = ADID_TYPE1;
        [strongSelf pressToLoadAd:nil];
    }];
    UIAlertAction *actType2 = [UIAlertAction actionWithTitle:@"左图右文模板" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.toBeChangedApid = ADID_TYPE2;
        [strongSelf pressToLoadAd:nil];
    }];
    UIAlertAction *actType3 = [UIAlertAction actionWithTitle:@"轮播图+文字模板" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.toBeChangedApid = ADID_TYPE3;
        [strongSelf pressToLoadAd:nil];
    }];
    UIAlertAction *actType4 = [UIAlertAction actionWithTitle:@"轮播大图模板" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.toBeChangedApid = ADID_TYPE4;
        [strongSelf pressToLoadAd:nil];
    }];
    UIAlertAction *actSmartFeed = [UIAlertAction actionWithTitle:@"信息流智能优选" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.toBeChangedApid = ADID_SMARTFEED;
        [strongSelf pressToLoadAd:nil];
    }];
    UIAlertAction *actCancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
    [alc addAction:actNormal];
    [alc addAction:actMorePics];
    [alc addAction:actType1];
    [alc addAction:actType2];
    [alc addAction:actType3];
    [alc addAction:actType4];
    [alc addAction:actSmartFeed];
    [alc addAction:actCancel];
    
    [self presentViewController:alc animated:YES completion:nil];
}

#pragma mark - 广告相关设置
//请求广告
- (void)pressToLoadAd:(UIButton *)sender {
#warning  ATS默认开启状态, 可根据需要关闭App Transport Security Settings，设置关闭BaiduMobAdSetting的supportHttps，以请求http广告，多个产品只需要设置一次.    [BaiduMobAdSetting sharedInstance].supportHttps = NO;
    
    if (!self.native) {
        self.native = [[BaiduMobAdNative alloc]init];
        self.native.delegate = self;
    }
    self.native.publisherId = self.toBeChangedPublisherId;
    self.native.adId = self.toBeChangedApid;
    //传入用来展示广告详情页的viewcontroller 不传则使用SDK新建window展示落地页
    self.native.presentAdViewController = self;
    //请求原生广告
    [self.native requestNativeAds];
}

- (void)tapGesture:(UIGestureRecognizer *)sender {
    UIView *view = sender.view ;
    NSInteger index = [self.adViewArray indexOfObject:view];
    if (self.adsArray.count<=index) {
        return;
    }
    BaiduMobAdNativeAdObject *object = [self.adsArray objectAtIndex:index];
    if ([view isKindOfClass:[BaiduMobAdSmartFeedView class]]) {
        BaiduMobAdSmartFeedView *adView = (BaiduMobAdSmartFeedView *)view;
        [adView handleClick];
        return;
    }
    if([view isKindOfClass:[BaiduMobAdNativeAdView class]]) {
        [object handleClick:view];
    }
}

#pragma mark - 广告返回成功

- (void)nativeAdObjectsSuccessLoad:(NSArray*)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd {
    
    NSLog(@"信息流广告加载成功");
    [self.tableView.mj_footer endRefreshing];
    [self.tableView.mj_header endRefreshing];
    
    [self.adsArray addObjectsFromArray:nativeAds];
    if ([self.native.adId isEqualToString:ADID_SMARTFEED]) {
        for(int i = 0; i < [nativeAds count]; i++){
            BaiduMobAdNativeAdObject *object = [nativeAds objectAtIndex:i];
            // 展现前检查是否过期，30分钟广告将过期，如果广告过期，请放弃展示并重新请求
            if ([object isExpired]) {
                continue;
            }
            BaiduMobAdSmartFeedView *view = [[BaiduMobAdSmartFeedView alloc]initWithObject:object frame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 351)];
            
            [view reSize];
            //非智能优选信息流无法使用BaiduMobAdSmartFeedView 推荐对init的view判空
            if (view) {
                [self.adViewArray addObject:view];
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
                [view addGestureRecognizer:tapGesture];
                [view setVideoMute:NO];
            } else {
                NSLog(@"创建智能优选视图失败");
            }
            
            [self.blankView removeFromSuperview];
            self.blankView = nil;
            [self.tableView reloadData];
        }
        return;
    }
    
    for (int i = 0; i < [nativeAds count]; i++) {
        CGFloat height = (kScreenWidth-30)*2/3+130;
        BaiduMobAdNativeAdObject *object = [nativeAds objectAtIndex:i];
        BaiduMobAdNativeAdView *view = [self createNativeAdViewWithframe:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height) object:object];
        
        //自己添加点击事件时，必须提前设置[BaiduMobAdNativeAdView dealTapGesture:true];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [view addGestureRecognizer:tapGesture];
        if (view) {
            [self.adViewArray addObject:view];
        } else {
            NSLog(@"创建信息流视图失败");
        }
        
        //展现前检查是否过期，通常广告过期时间为30分钟。如果过期，请放弃展示并重新请求
        if ([object isExpired]) {
            continue;
        }
        
        // 加载和显示广告内容
        __weak NativeTableViewController *weakSelf = self;
        [view loadAndDisplayNativeAdWithObject:object completion:^(NSArray *errors) {
            if (!errors) {
                [self.blankView removeFromSuperview];
                self.blankView = nil;
                [weakSelf.tableView reloadData];
            }
        }];
    }
}

//广告返回失败
- (void)nativeAdsFailLoad:(BaiduMobFailReason)reason {
    NSLog(@"信息流加载失败:reason = %d",reason);
    [self.tableView.mj_footer endRefreshing];
    [self.tableView.mj_header endRefreshing];
    
    if (self.adViewArray.count <= 0) {
        self.adViewArray = [NSMutableArray array];
        [self.tableView reloadData];
        
        if (!self.blankView) {
            self.blankView = [[BaiduMobAdBlankView alloc] initWithFrame:(self.view.frame)];
        }
        [self.view addSubview:self.blankView];
    }
    
}

//广告被点击，打开后续详情页面，如果为视频广告，可选择暂停视频
- (void)nativeAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    NSLog(@"信息流被点击:%@ - %@", nativeAdView, object);
}

//广告详情页被关闭，如果为视频广告，可选择继续播放视频
- (void)didDismissLandingPage:(UIView *)nativeAdView {
    NSLog(@"信息流落地页被关闭");
}

//广告曝光回调
- (void)nativeAdExposure:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    NSLog(@"信息流广告曝光回调:%@ - %@", nativeAdView, object);
}

#pragma mark - 创建广告视图

- (BaiduMobAdNativeAdView *)createNativeAdViewWithframe:(CGRect)frame object:(BaiduMobAdNativeAdObject *)object {
    
    CGFloat origin_x = 15;
    CGFloat main_width = kScreenWidth - (origin_x*2);
    CGFloat main_height = main_width*2/3;
    
    //标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(85, 20, main_width-85, 20)];
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    
    //描述
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(85, 50, main_width-85, 20)];
    textLabel.font = [UIFont fontWithName:textLabel.font.familyName size:12];
    if (!object.text || [object.text isEqualToString:@""]) {
        object.text = @"广告描述信息";
    }
    
    //Icon
    UIImageView *iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(origin_x, origin_x, 60, 60)];
    iconImageView.layer.cornerRadius = 3;
    iconImageView.layer.masksToBounds = YES;
    
    //大图
    UIImageView *mainImageView = [[UIImageView alloc]initWithFrame:CGRectMake(origin_x, 85, main_width, main_height)];
    mainImageView.layer.cornerRadius = 5;
    mainImageView.layer.masksToBounds = YES;
    
    //广告logo
    UIImageView *baiduLogoView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(mainImageView.frame)-26-15, CGRectGetMaxY(mainImageView.frame)+10, 15, 14)];
    UIImageView *adLogoView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(baiduLogoView.frame), CGRectGetMinY(baiduLogoView.frame), 26, 14)];
    
    //app名字
    UILabel *brandLabel = [[UILabel alloc]initWithFrame:CGRectMake(origin_x, CGRectGetMaxY(mainImageView.frame)+10, 200, 20)];
    brandLabel.font = [UIFont fontWithName:brandLabel.font.familyName size:13];
    brandLabel.textColor = [UIColor grayColor];
    
    //多图 Demo  单图和多图按需展示
    NSMutableArray *imageViewArray = [NSMutableArray array];
    if ([object.morepics count] > 0) {
        //多图
        CGFloat margin = 5;//图片间隙
        CGFloat imageWidth = (kScreenWidth-2*origin_x-margin*(object.morepics.count-1))/object.morepics.count;
        CGFloat imageHeight = imageWidth*2/3;
        
        //适配logo位置
        baiduLogoView.frame = ({
            CGRect frame = baiduLogoView.frame;
            frame.origin.x = kScreenWidth-origin_x-26-15;
            frame.origin.y = imageHeight+10+85;
            frame;
        });
        
        adLogoView.frame = ({
            CGRect frame = adLogoView.frame;
            frame.origin.y = CGRectGetMinY(baiduLogoView.frame);
            frame;
        });
        
        brandLabel.frame = ({
            CGRect frame = brandLabel.frame;
            frame.origin.y = CGRectGetMinY(baiduLogoView.frame);
            frame;
        });
        
        
        for (int i = 0; i<object.morepics.count; i++) {
            UIImageView *mainImageView = [[UIImageView alloc]initWithFrame:CGRectMake(origin_x, 85, imageWidth, imageHeight)];
            [imageViewArray addObject:mainImageView];
            origin_x+=imageWidth+margin;
        }
    }
    
    BaiduMobAdNativeAdView *nativeAdView;
    nativeAdView.backgroundColor = [UIColor whiteColor];
    
    if (object.materialType == HTML) {
        ///信息流模版广告 模板广告内部已添加百度广告logo和熊掌，开发者无需添加
        BaiduMobAdNativeWebView *webview = [[BaiduMobAdNativeWebView alloc]initWithFrame:frame andObject:object];
        nativeAdView = [[BaiduMobAdNativeAdView alloc]initWithFrame:frame
                                                            webview:webview];
    } else if (object.materialType == NORMAL) {
        
        //多图 Demo  单图和多图按需展示
        nativeAdView = [[BaiduMobAdNativeAdView alloc] initWithFrame:frame
                                                           brandName:brandLabel
                                                               title:titleLabel
                                                                text:textLabel
                                                                icon:iconImageView
                                                           mainImage:mainImageView
                                                            morepics:imageViewArray];
        
        nativeAdView.baiduLogoImageView = baiduLogoView;
        [nativeAdView addSubview:baiduLogoView];
        nativeAdView.adLogoImageView = adLogoView;
        [nativeAdView addSubview:adLogoView];
        
    }
    
    return nativeAdView;
}

- (UIImage *)imageResoureForName:(NSString *)name {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"baidumobadsdk" ofType:@"bundle"];
    NSBundle *b = [NSBundle bundleWithPath:bundlePath];
    return [UIImage imageWithContentsOfFile: [b pathForResource:name ofType:@"png"]];
}

#pragma mark - UITableView Delegte

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.adViewArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.adViewArray.count > indexPath.row) {
        UIView *adView = [self.adViewArray objectAtIndex:indexPath.row];
        if ([adView isKindOfClass:[BaiduMobAdSmartFeedView class]]) {
            return [(BaiduMobAdSmartFeedView *)adView viewHeight];
        }
    }
    return (kScreenWidth-30)*2/3+130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (self.adViewArray.count > indexPath.row)
    {
        for (UIView *view in cell.subviews) {
            [view removeFromSuperview];
        }
        
        BaiduMobAdNativeAdView *view = [self.adViewArray objectAtIndex:indexPath.row];
        [cell addSubview:view];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //发送曝光计费 必传！
    //确定视图显示在window上之后再调用trackImpression，不要太早调用 在tableview或scrollview中使用时尤其要注意
    [self sendVisibleImpressionAtIndexPath:indexPath];
}

- (void)sendVisibleImpressionAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *visiblePath = [self.tableView indexPathsForVisibleRows];
    if ([visiblePath containsObject:indexPath]) {
        if ([self.adViewArray count]> indexPath.row) {
            
            //若[object trackImpression:cell],用cell trackImpression，则需要在
            //- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath中进行trackImpression,否则数据会错误
            UIView *adView = [self.adViewArray objectAtIndex:indexPath.row];
            if ([adView isKindOfClass:[BaiduMobAdSmartFeedView class]]) {
                [(BaiduMobAdSmartFeedView *)adView trackImpression];
                return;
            }
            BaiduMobAdNativeAdView *view = [self.adViewArray objectAtIndex:indexPath.row];
            [view trackImpression];
        }
    }
}

//点击区域是否处在视频区域
- (BOOL)locationInVideo:(UIGestureRecognizer*)sender withView:(UIView*)view {
    BOOL inVideoView =  NO;
    if ([view isKindOfClass:[BaiduMobAdNativeAdView class]]) {
        BaiduMobAdNativeAdView *adView = (BaiduMobAdNativeAdView*)view;
        CGPoint point = [sender locationInView:adView.mainImageView];
        if (point.x >= 0 &&
            point.x <= adView.mainImageView.frame.size.width &&
            point.y >= 0 &&
            point.y <= adView.mainImageView.frame.size.height) {
            inVideoView = YES;
        }
    }
    return inVideoView;
}

/**
 * Called on finger up if the user dragged. decelerate is true if it will continue moving afterwards

 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        // scrollView已经完全静止
        [self handleScrollStop];
        [self handleScrollStopImpression];
    }
}

/**
 *滑动停止后，通知当前可见区域的第一个videoview
 */
- (void)handleScrollStop {
    
    [self.tableView visibleCells];
    NSArray *visiblePath = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *visible in visiblePath) {
        if ([self.adViewArray count] > visible.row) {
            BaiduMobAdSmartFeedView *view = [self.adViewArray objectAtIndex:visible.row];
            if ([view render]) {
                break;
            };
        }
    }
}

/**
 *滑动停止后，检查当前可见区域内的cell来发送展现
 */
- (void)handleScrollStopImpression {
    NSArray *visiblePath = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *visible in visiblePath) {
        if ([self.adViewArray count]> visible.row) {
            BaiduMobAdNativeAdObject *object = [self.adsArray objectAtIndex:visible.row];
            BaiduMobAdNativeAdView *view = [self.adViewArray objectAtIndex:visible.row];
            // 确定视图显示在window上之后再调用trackImpression，不要太早调用
            // 在tableview或scrollview中使用时尤其要注意
            [object trackImpression:view];
        }
    }
}

#pragma mark - 广告配置

/**
 * 大图高度，仅用于信息流模版广告
 */
- (NSNumber*)baiduMobAdsHeight {
    return [NSNumber numberWithFloat:180];
}

/**
 * 大图宽度，仅用于信息流模版广告
 */
- (NSNumber*)baiduMobAdsWidth {
    return [NSNumber numberWithFloat:320];
}

- (BOOL)enableLocation {
    return YES;
}

- (void)dealloc {
    
    for (UIView *adview in _adViewArray) {
        [adview removeFromSuperview];
    }
}

@end
