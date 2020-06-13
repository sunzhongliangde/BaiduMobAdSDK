//
//  HybridViewController.m
//  XAdSDKDevSample
//
//  Created by lishan04 on 17/04/2018.
//  Copyright © 2018 Baidu. All rights reserved.
//

#import "HybridViewController.h"
#import <WebKit/WebKit.h>
#import "BaiduMobAdSDK/BaiduMobAdHybridAdManager.h"

@interface HybridViewController ()<WKNavigationDelegate, BaiduMobAdHybridAdManagerDelegate>
@property (nonatomic, strong) BaiduMobAdHybridAdManager *manager;
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, copy) NSString *url;

@end

@implementation HybridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"BaiduMobAdDemosupportHttps"]boolValue]) {
        self.url = [NSString stringWithFormat:@"%@",@"https://mobads.baidu.com/ads/indexlpios.html"];
    }else{
        self.url = [NSString stringWithFormat:@"%@",@"http://mobads.baidu.com/ads/indexlpios.html"];
    }
    [self load];
}

- (void)load {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
    self.manager = [[BaiduMobAdHybridAdManager alloc]init];
    self.manager.publisherId = @"ccb60059";
    self.manager.delegate = self;
    WKWebView *webView = [[WKWebView alloc]initWithFrame:self.view.bounds];
    webView.navigationDelegate = self;
    [webView loadRequest:request];
    [self.manager injectJavaScriptBridgeForWKWebView:webView];
    [self.view addSubview:webView];
    self.wkWebView = webView;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    BOOL shouldLoad  = [self.manager webView:webView shouldStartLoadForNavigationAction:navigationAction];
    if (!shouldLoad) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    self.manager.delegate = nil;
    self.manager = nil;
    if ([self.wkWebView isKindOfClass:[WKWebView class]]) {
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        }];
    }
    if (self.wkWebView) {
        self.wkWebView.navigationDelegate = nil;
        self.wkWebView = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didAdClicked {
    NSLog(@"didadclicked");
}

- (void)didAdImpressed {
    NSLog(@"didAdImpressed");
    
}

- (void)failedDisplayAd {
    
}


@end
