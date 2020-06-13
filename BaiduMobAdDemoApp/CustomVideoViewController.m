//
//  CustomVideoViewController.m
//  XAdSDKDevSample
//
//  Created by Yang,Dingjia on 2018/11/14.
//  Copyright © 2018 Baidu. All rights reserved.
//

#import "CustomVideoViewController.h"
#import "XScreenConfig.h"

#import "BaiduMobAdSDK/BaiduMobAdNative.h"
#import "BaiduMobAdSDK/BaiduMobAdVideoView.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeAdObject.h"

///TODO:  重要！接入须知：
/*
小视频接入指南：
 1. init nativeId
 2. loadAd
 3. 监听success回调，自行渲染处理object数据，可以直接把UI渲染在播放器之上。SDK仅提供播放器组件。
 4. 如果渲染有点击事件，需要手动调用SDK handleClick方法发送点击计费。
 5. 播放器处理了尾帧渲染，无需重复渲染。
 6. 检查API是否发生更改。
 */

@interface CustomVideoViewController () <BaiduMobAdNativeAdDelegate,UICollectionViewDelegate,UICollectionViewDataSource,BaiduMobAdVideoViewDelegate,BaiduMobAdNativeCacheDelegate>

#define ADID_VIDEO  @"5992850" //信息流-沉浸式视频

@property (nonatomic, strong) BaiduMobAdNative *native;
@property (nonatomic, strong) NSMutableArray *adViewArray;
@property (nonatomic, strong) NSMutableArray *adsArray;
@property (retain, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end

@implementation CustomVideoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.adViewArray = [NSMutableArray new];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.backBtn.layer.cornerRadius = 30;
    self.backBtn.layer.masksToBounds = YES;
    
    //监听前后台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    
    //请求广告
    [self loadAd];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didEnterBackground{
    
    for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
        NSIndexPath *index = [self.collectionView indexPathForCell:cell];
        
        BaiduMobAdVideoView *view = [self.adViewArray objectAtIndex:index.row];
        [view pause];
    }
        
}

- (void)willEnterForeground{
    
    for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
        NSIndexPath *index = [self.collectionView indexPathForCell:cell];
        
        BaiduMobAdVideoView *view = [self.adViewArray objectAtIndex:index.row];
        [view play];
    }
}

- (IBAction)goBack:(id)sender {
    
    for (int i=0; i<self.adViewArray.count; i++) {

        BaiduMobAdVideoView *view = [self.adViewArray objectAtIndex:i];
        //stop会销毁播放器，下次play需要重新初始化
        [view stop];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

//请求广告
- (void)loadAd
{
    if (!self.native)
    {
        self.native = [[BaiduMobAdNative alloc]init];
        self.native.delegate = self;
        self.native.cacheDelegate = self;
        self.native.publisherId = @"ccb60059";
    }
    self.native.adId = ADID_VIDEO;
    [self.native requestNativeAds];
}

#pragma mark - 广告请求成功Delegate
- (void)nativeAdObjectsSuccessLoad:(NSArray*)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd {
    
    NSLog(@"小视频广告请求成功");
    
    [self.adViewArray removeAllObjects];
    self.adsArray = [nativeAds mutableCopy];

    for(int i = 0; i < [self.adsArray count]; i++){
        
        BaiduMobAdNativeAdObject *object = [self.adsArray objectAtIndex:i];
        // 展现前检查是否过期，30分钟广告将过期，如果广告过期，请放弃展示并重新请求
        if ([object isExpired]) {
            continue;
        }
        BaiduMobAdVideoView *view = [self createNativeAdViewWithObject:object];
        view.delegate = self;
        if (view) {
            [self.adViewArray addObject:view];
        }
    }
    [self.collectionView reloadData];
    
}

- (void)nativeVideoAdCacheSuccess:(BaiduMobAdNative *)nativeAd {
    NSLog(@"小视频缓存成功");
}

- (void)nativeVideoAdCacheFail:(BaiduMobAdNative *)nativeAd withError:(BaiduMobFailReason)reason {
    NSLog(@"小视频缓存失败");
}

//广告详情页被关闭，如果为视频广告，可选择继续播放视频
-(void)didDismissLandingPage:(UIView *)nativeAdView
{
    if ([nativeAdView isKindOfClass:[BaiduMobAdVideoView class]]) {
        [(BaiduMobAdVideoView *)nativeAdView play];
    }
    NSLog(@"baidu:LP页面关闭回调");
}

- (BaiduMobAdVideoView *)createNativeAdViewWithObject:(BaiduMobAdNativeAdObject *)object{
    
    BaiduMobAdVideoView *videoView = [[BaiduMobAdVideoView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, self.view.frame.size.height) andObject:object];
    
    UIImageView *iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, kScreenHeight-150, 60, 60)];
    iconImageView.layer.cornerRadius = 30;
    iconImageView.layer.masksToBounds = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData
                        dataWithContentsOfURL:[NSURL URLWithString:object.iconImageURLString]];
        
        if (data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [iconImageView setImage:[UIImage imageWithData:data]];
            });
        }
    });
    [videoView addSubview:iconImageView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, kScreenHeight-140, 200, 40)];
    titleLabel.text = object.title;
    titleLabel.numberOfLines = 2;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:titleLabel.font.familyName size:12];
    [videoView addSubview:titleLabel];
    
    UILabel *brandLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, kScreenHeight-80, 200, 40)];
    brandLabel.text = [NSString stringWithFormat:@"#%@#",object.brandName];
    brandLabel.numberOfLines = 2;
    brandLabel.textColor = [UIColor cyanColor];
    brandLabel.font = [UIFont fontWithName:brandLabel.font.familyName size:14];
    [videoView addSubview:brandLabel];
    
    UIImageView *baiduLogoView = [[UIImageView alloc]initWithFrame:CGRectMake(10, kScreenHeight-120, 18, 18)];
    UIImageView *adLogoView = [[UIImageView alloc]initWithFrame:CGRectMake(28, kScreenHeight-120, 36, 18)];
    [videoView addSubview:baiduLogoView];
    [videoView addSubview:adLogoView];
    
    NSInteger index = [self.adsArray indexOfObject:object];
    UITapGestureRecognizer *titleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adClickWithGesture:)];
    titleLabel.userInteractionEnabled = YES;
    titleLabel.tag = index;
    [titleLabel addGestureRecognizer:titleTap];
    
    UITapGestureRecognizer *brandTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adClickWithGesture:)];
    brandLabel.userInteractionEnabled = YES;
    brandLabel.tag = index;
    [brandLabel addGestureRecognizer:brandTap];
    
    UITapGestureRecognizer *iconTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adClickWithGesture:)];
    iconImageView.userInteractionEnabled = YES;
    iconImageView.tag = index;
    [iconImageView addGestureRecognizer:iconTap];
    
    UIButton *muteBtn = [[UIButton alloc] initWithFrame:(CGRectMake(kScreenWidth-50, 70, 30, 30))];
    muteBtn.tag = index;
    [muteBtn addTarget:self action:@selector(muteChange:) forControlEvents:UIControlEventTouchUpInside];
    [videoView addSubview:muteBtn];
    
    [muteBtn setBackgroundColor:[UIColor clearColor]];
    [muteBtn addTarget:self action:@selector(muteChange:) forControlEvents:UIControlEventTouchUpInside];
    [muteBtn setImage:[self imageResoureFromBundle:@"volume_open"] forState:UIControlStateNormal];
    [muteBtn setImage:[self imageResoureFromBundle:@"volume_close"] forState:UIControlStateSelected];
    
    return videoView;
}

- (void)muteChange:(UIButton *)btn {
    
    btn.selected = !btn.selected;
    BaiduMobAdVideoView *view = [self.adViewArray objectAtIndex:btn.tag];
    [view setVideoMute:btn.selected];
    
}

- (UIImage *)imageResoureFromBundle:(NSString*)name
{
    NSString* bundlePath = [[NSBundle mainBundle] pathForResource:@"baidumobadsdk" ofType:@"bundle"];
    NSBundle* b=  [NSBundle bundleWithPath:bundlePath];
    return [UIImage imageWithContentsOfFile: [b pathForResource:name ofType:@"png"]];
}


- (void)adClickWithGesture:(UITapGestureRecognizer *)gesture{
    
    BaiduMobAdVideoView *view = [self.adViewArray objectAtIndex:gesture.view.tag];
    [view pause];
    
    ///必传！！打点计费日志
    [view handleClick];
}

#pragma mark - UICollectionViewDelegate
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    BaiduMobAdVideoView *view = [self.adViewArray objectAtIndex:indexPath.row];
    [cell addSubview:view];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BaiduMobAdVideoView *view = [self.adViewArray objectAtIndex:indexPath.row];
    [view play];
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BaiduMobAdVideoView *view = [self.adViewArray objectAtIndex:indexPath.row];
    [view pause];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.adViewArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth, self.view.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - 播放器delegate

- (void)fullscreenVideoAdDidFailed:(BaiduMobAdVideoView *)videoView {
    NSLog(@"小视频播放失败");
}

- (void)fullscreenVideoAdDidComplete:(BaiduMobAdVideoView *)videoView {
    NSLog(@"小视频播放完成");
}

- (void)fullscreenVideoAdDidStartPlaying:(BaiduMobAdVideoView *)videoView {
    NSLog(@"小视频开始播放");
}

- (void)fullscreenVideoAdDidClick:(BaiduMobAdVideoView *)videoView {
    NSLog(@"小视频被点击");
}

@end
