#import "NativeVideoTableViewController.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeVideoView.h"
#import "BaiduMobAdSDK/BaiduMobAdNative.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeAdDelegate.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeAdObject.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeAdView.h"
#import "XScreenConfig.h"
#import "BaiduMobAdBlankView.h"

#define ADID_VIDEO  @"2362914" //信息流-视频
#define AD_TAG 0

/*
 信息流广告接入：
 信息流主要分元素、模板、视频三类，需要根据不同的广告返回创建对应的View。
 注意信息流需要开发者手动发生曝光和点击事件，涉及计费！
 */
@interface NativeVideoTableViewController ()<UITableViewDelegate, UITableViewDataSource,BaiduMobAdNativeAdDelegate>

@property (nonatomic, strong) BaiduMobAdNative *native;
@property (nonatomic, strong) NSMutableArray *adViewArray;
@property (nonatomic, strong) NSArray *adsArray;
@property (nonatomic, strong) BaiduMobAdBlankView *blankView;
@end

@implementation NativeVideoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化TabalView
    [self initView];
    //请求广告
    [self loadAd];

}

- (void)initView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.adViewArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
}

- (void)loadAd {
    if (!self.native) {
        self.native = [[BaiduMobAdNative alloc] init];
        self.native.delegate = self;
        self.native.publisherId = @"ccb60059";
        self.native.adId = ADID_VIDEO;
    }
    
    [self.native requestNativeAds];
}

#pragma mark - Data Srouce

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.adViewArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    if (self.adViewArray.count > indexPath.row) {
        BaiduMobAdNativeAdView *view = [self.adViewArray objectAtIndex:indexPath.row];
        view.tag = 0;
        [[cell viewWithTag:AD_TAG] removeFromSuperview];
        [cell addSubview: view];
        //尝试发送展现
        [self sendVisibleImpressionAtIndexPath:indexPath WithView:view];
    }
    return cell;
}

- (void)sendVisibleImpressionAtIndexPath:(NSIndexPath *)indexPath WithView:(UIView *)view {
    NSArray *visiblePath = [self.tableView indexPathsForVisibleRows];
    if ([visiblePath containsObject:indexPath]) {
        if ([self.adsArray count] > indexPath.row) {
            BaiduMobAdNativeAdObject *object = [self.adsArray objectAtIndex:indexPath.row];
            // 确定视图显示在window上之后再调用trackImpression，不要太早调用
            //在tableview或scrollview中使用时尤其要注意
            [object trackImpression:view];
        }
    }
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 350;
}

/**
 * Called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
 * 松手时已经静止, 只会调用scrollViewDidEndDragging
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        // scrollView已经完全静止
        [self handleScrollStop];
        [self handleScrollStopImpression];
    }
}

/**
 * Called on tableView is static after finger up if the user dragged and tableView is scrolling.
 * 松手时还在运动, 先调用scrollViewDidEndDragging, 再调用scrollViewDidEndDecelerating
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // scrollView已经完全静止
    [self handleScrollStop];
    [self handleScrollStopImpression];
}

#pragma mark - Setup

- (BaiduMobAdNativeAdView *)createNativeAdViewWithframe:(CGRect)frame object:(BaiduMobAdNativeAdObject *)object {
    CGFloat origin_x = 15;
    CGFloat main_width = kScreenWidth - (origin_x * 2);
    CGFloat main_height = main_width * 2 / 3;
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 20, main_width-85, 20)];
    titleLabel.font = [UIFont fontWithName:titleLabel.font.familyName size:12];
    
    //描述
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 50, main_width-85, 20)];
    textLabel.font = [UIFont fontWithName:textLabel.font.familyName size:12];
    if (!object.text || [object.text isEqualToString:@""]) {
        object.text = @"广告描述信息";
    }
    
    //Icon
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(origin_x, origin_x, 60, 60)];
    iconImageView.layer.cornerRadius = 3;
    iconImageView.layer.masksToBounds = YES;
    
    //播放器
    BaiduMobAdNativeVideoView *videoView = [[BaiduMobAdNativeVideoView alloc] initWithFrame:
                                            CGRectMake(origin_x, 80, main_width, main_height) andObject:object];
    
    //广告logo
    UIImageView *baiduLogoView = [[UIImageView alloc] initWithFrame:
                                  CGRectMake(CGRectGetMaxX(videoView.frame)-26-15,
                                             CGRectGetMaxY(videoView.frame)+10, 15, 14)];
    UIImageView *adLogoView = [[UIImageView alloc] initWithFrame:
                               CGRectMake(CGRectGetMaxX(baiduLogoView.frame),
                                          CGRectGetMinY(baiduLogoView.frame), 26, 14)];
    
    //app名字
    UILabel *brandLabel = [[UILabel alloc] initWithFrame:
                           CGRectMake(origin_x, CGRectGetMaxY(videoView.frame)+10, 200, 20)];
    brandLabel.font = [UIFont fontWithName:brandLabel.font.familyName size:13];
    brandLabel.textColor = [UIColor grayColor];
    
    
    BaiduMobAdNativeAdView *nativeAdView = [[BaiduMobAdNativeAdView alloc] initWithFrame:frame
                                                                               brandName:brandLabel
                                                                                   title:titleLabel
                                                                                    text:textLabel
                                                                                    icon:iconImageView
                                                                               videoView:videoView];
    
    nativeAdView.baiduLogoImageView = baiduLogoView;
    [nativeAdView addSubview:baiduLogoView];
    nativeAdView.adLogoImageView = adLogoView;
    [nativeAdView addSubview:adLogoView];
    
    nativeAdView.backgroundColor = [UIColor whiteColor];
    return nativeAdView;
}

- (UIImage *)imageResoureForName:(NSString *)name {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"baidumobadsdk" ofType:@"bundle"];
    NSBundle *b = [NSBundle bundleWithPath:bundlePath];
    return [UIImage imageWithContentsOfFile:[b pathForResource:name ofType:@"png"]];
}

/**
 *滑动停止后，通知当前可见区域的第一个videoview
 */
- (void)handleScrollStop {
    
    [self.tableView visibleCells];
    NSArray *visiblePath = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *visible in visiblePath) {
        if ([self.adViewArray count] > visible.row) {
            BaiduMobAdNativeAdView *view = [self.adViewArray objectAtIndex:visible.row];
            if ([view.videoView handleScrollStop]) {
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


#pragma mark - BaiduMobAdNativeAdDelegate
//成功返回广告字段，BaiduMobAdNativeAdObject array
- (void)nativeAdObjectsSuccessLoad:(NSArray *)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd {
    
    self.adViewArray = [NSMutableArray array];
    self.adsArray = [nativeAds copy];
    
    for (int i = 0; i < [nativeAds count]; i++) {
        BaiduMobAdNativeAdObject *object = [nativeAds objectAtIndex:i];
        BaiduMobAdNativeAdView *view = [self createNativeAdViewWithframe:CGRectMake(0, 0, kScreenWidth, 280) object:object];
        
        [BaiduMobAdNativeAdView dealTapGesture:true];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(tapGesture:)];
        [view addGestureRecognizer:tapGesture];
        
        
        //传入用来展示广告详情页的viewcontroller (也可以不传)
        view.presentAdViewController = self;
        if (view) {
            [self.adViewArray addObject:view];
        }
        
        // 展现前检查是否过期，30分钟广告将过期，如果广告过期，请放弃展示并重新请求
        if ([object isExpired]) {
            continue;
        }
        
        __block NativeVideoTableViewController *weakSelf = self;
        // 加载和显示广告内容
        [view loadAndDisplayNativeAdWithObject:object completion:^(NSArray *errors) {
            if (!errors) {
                // 确定视图显示在window上之后再调用trackImpression，不要太早调用
                //在tableview或scrollview中使用时尤其要注意
                [self.blankView removeFromSuperview];
                self.blankView = nil;
                [weakSelf.tableView reloadData];
            }
        }];
    }
}

- (void)tapGesture:(UIGestureRecognizer *)sender {
    UIView *view = sender.view ;
    NSInteger index = [self.adViewArray indexOfObject:view];
    BaiduMobAdNativeAdObject *object = [self.adsArray objectAtIndex:index];
    [object handleClick:view];
}


//广告返回失败
- (void)nativeAdsFailLoad:(BaiduMobFailReason)reason {
    NSLog(@"信息流视频:load ads failed,reason = %d", reason);
    self.adViewArray = [NSMutableArray array];
    [self.tableView reloadData];
    
    if (!self.blankView) {
        self.blankView = [[BaiduMobAdBlankView alloc] initWithFrame:(self.view.frame)];
    }
    [self.view addSubview:self.blankView];
}

//广告被点击，打开后续详情页面，如果为视频广告，可选择暂停视频
- (void)nativeAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    NSLog(@"信息流视频:点击回调");
}

//广告详情页被关闭，如果为视频广告，可选择继续播放视频
- (void)didDismissLandingPage:(UIView *)nativeAdView {
    NSLog(@"信息流视频:LP页面关闭回调");
}

@end
