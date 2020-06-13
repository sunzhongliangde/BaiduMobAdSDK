//
//  BaiduMobAdBlankView.m
//  BaiduMobAdDemoApp
//
//  Created by Yang,Dingjia on 2019/8/6.
//  Copyright © 2019 Baidu. All rights reserved.
//

#import "BaiduMobAdBlankView.h"

@implementation BaiduMobAdBlankView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI {
    
    UIImageView *toastImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noData_icon"]];
    toastImageView.frame = CGRectMake((self.frame.size.width-80)/2, (self.frame.size.height-80)/3, 80, 80);
    [self addSubview:toastImageView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-200)/2, CGRectGetMaxY(toastImageView.frame)+20, 200, 30)];
    label.text = @"呃噢...暂无填充";
    label.font = [UIFont systemFontOfSize:22];
    label.textColor = [UIColor darkGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:label];
}

@end
