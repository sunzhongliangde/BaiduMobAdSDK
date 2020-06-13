//
//  XScreenConfig.h
//  XAdSDKDevSample
//
//  Created by 吴晗 on 2017/12/17.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#ifndef XScreenConfig_h
#define XScreenConfig_h

#define kScreenWidth [[UIApplication sharedApplication]keyWindow].bounds.size.width
#define kScreenHeight [[UIApplication sharedApplication]keyWindow].bounds.size.height

#define IPHONEX_TABBAR_FIX_HEIGHT 34
#define IPHONEX_TOPBAR_FIX_HEIGHT 44
#define ISIPHONEX ([[UIApplication sharedApplication] statusBarFrame].size.height == 44) || ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896) || ([UIScreen mainScreen].bounds.size.width == 812 || [UIScreen mainScreen].bounds.size.width == 896)

#endif /* XScreenConfig_h */
