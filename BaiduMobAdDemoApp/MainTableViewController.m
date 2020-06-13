//
//  MainTableViewController.m
//  APIExampleApp
//
//  Created by lishan04 on 15-5-14.
//
//

#import "MainTableViewController.h"
#import "BaiduMobAdFirstViewController.h"
#import "BaiduMobAdNormalInterstitialViewController.h"
#import "BaiduMobAdPrerollViewController.h"
#import "NativeTableViewController.h"
#import "CpuChannelViewController.h"
#import "NativeVideoTableViewController.h"
#import "HybridViewController.h"
#import "CustomVideoViewController.h"
#import "RewardVideoViewController.h"
#import "BaiduMobAdSDK/BaiduMobAdSplash.h"
#import "BaiduMobAdSDK/BaiduMobAdSetting.h"
#import <AdSupport/ASIdentifierManager.h>
#import "XScreenConfig.h"
#import "MainTableViewCell.h"

@interface MainTableViewController ()<BaiduMobAdSplashDelegate>
@property (nonatomic, strong) BaiduMobAdSplash *splash;
@property (nonatomic, strong) UIView *splashView;
@property (nonatomic, strong) NSMutableArray *cellTitleArray;
@property (nonatomic, strong) NSMutableArray *cellIconArray;

@end

@implementation MainTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"百度网盟 Demo";

    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    NSString *idfa = [self getIDFA];
    self.cellTitleArray = [[NSMutableArray alloc] initWithObjects:@"横幅", @"开屏", @"插屏", @"信息流",@" ", @"信息流视频", @"小视频", @"激励视频", @"视频贴片", @"", @"JSSDK", @"内容联盟", @" ", idfa,  nil];
    
    self.cellIconArray = [[NSMutableArray alloc] initWithObjects:@"banner", @"splash", @"int", @"feed",@" ", @"feedVideo", @"customVideo", @"rewardVideo", @"preroll",@" ", @"JSSDK", @"union", @" ", @"rewardVideo",  nil];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 4 || indexPath.row == 9 || indexPath.row == 12) {
        return 30;
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MainTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"MainTableViewCell" owner:self options:nil] firstObject];
    
    if (indexPath.row == 4 || indexPath.row == 9 || indexPath.row == 12 || indexPath.row == 14) {
        cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (self.cellTitleArray.count > indexPath.row) {
        cell.titleLabel.text = [self.cellTitleArray objectAtIndex:indexPath.row];
    }
    
    if (self.cellIconArray.count > indexPath.row) {
        cell.iconImageView.image = [UIImage imageNamed:[self.cellIconArray objectAtIndex:indexPath.row]];
    }
    
    if (indexPath.row == 14) {
        [cell addSubview:[self sdkVersionView]];
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, [UIScreen mainScreen].bounds.size.width);

    }
    
    return cell;
}

- (UIView *)sdkVersionView {
    
    UIView *view = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, kScreenWidth, 60))];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRectMake((kScreenWidth-100)/2, 15, 40, 20))];
    imageView.image = [UIImage imageNamed:@"Group"];
    [view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+5, 17, 60, 20)];
    label.text = [NSString stringWithFormat:@"V %@",SDK_VERSION_IN_MSSP];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIViewController *detailViewController = nil;
    switch (indexPath.row) {
        case 0:
            detailViewController = [[BaiduMobAdFirstViewController alloc]init];
            break;
        case 1:
            [self showSplash];
            break;
        case 2:
            detailViewController = [[BaiduMobAdNormalInterstitialViewController alloc]init];
            break;
        case 3:
            detailViewController = [[NativeTableViewController alloc]init];
            break;
        case 5:
            detailViewController = [[NativeVideoTableViewController alloc]init];
            break;
        case 6:
            detailViewController =  [[CustomVideoViewController alloc] init];
            break;
        case 7:
            detailViewController = [[RewardVideoViewController alloc]init];
            break;
        case 8:
            detailViewController = [[BaiduMobAdPrerollViewController alloc]init];
            break;
        case 10:
            detailViewController = [[HybridViewController alloc]init];
            break;
        case 11:
            detailViewController = [[CpuChannelViewController alloc]init];
            break;
        case 13:
        {
            NSString *idfa = [self getIDFA];
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = idfa;
            
            NSString *title = @"IDFA已复制";
            NSString *message = idfa;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
            
            break;
        }
        default:
            break;
    }

    if (detailViewController) {
        [self.navigationController pushViewController:detailViewController animated:NO];
    }
}

- (void)showSplash {
    
    self.splash = [[BaiduMobAdSplash alloc] init];
    self.splash.delegate = self;
    self.splash.AdUnitTag = @"2058492";
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.splashView = [[UIView alloc] initWithFrame:window.frame];

    [window addSubview:self.splashView];
    
    [self.splash loadAndDisplayUsingContainerView:self.splashView];
}

- (NSString *)publisherId {
    return @"ccb60059";
}

- (void)splashDidDismissLp:(BaiduMobAdSplash *)splash {
    NSLog(@"splashDidDismissLp");
    [self removeSplash];
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

- (void)removeSplash {
    
    if (self.splash) {
        self.splash.delegate = nil;
        self.splash = nil;
        [self.splashView removeFromSuperview];
    }
}

#pragma mark - IDFA

- (NSString *)getIDFA{
    
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    return idfa;
}

@end

