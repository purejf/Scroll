//
//  CYScrollTitleView.h
//  Scroll
//
//  Created by y on 2017/12/20.
//  Copyright © 2017年 cy. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import "CYScrollReloadRule.h"

@class CYScrollTitleView, CYScrollConfiguration, CYScrollConfigurationItem;

typedef void(^CYScrollTitleDidClickItemHandle)(CYScrollTitleView *titleView, NSInteger selectedIndex);

@interface CYScrollTitleView : UIView <CYScrollReloadRule>

@property (nonatomic, assign, readonly) NSInteger selectedIndex;

@property (nonatomic, strong, readonly) CYScrollConfiguration *configuration;

@property (nonatomic, weak, readonly) UIScrollView *scrollView;

- (void)changeSelectedIndexWithContentViewOffset:(CGPoint)contentViewOffset contentViewWidth:(CGFloat)contentViewWidth;

- (void)setupConfiguration:(CYScrollConfiguration *)configuration;

- (void)setupDidClickItemHandle:(CYScrollTitleDidClickItemHandle)didClickItemHandle;

@end
