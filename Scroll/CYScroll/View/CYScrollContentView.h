//
//  CYScrollContentView.h
//  Scroll
//
//  Created by y on 2017/12/20.
//  Copyright © 2017年 cy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYScrollReloadRule.h"

@class CYScrollContentView, CYScrollConfiguration, CYScrollConfigurationItem, CYScrollViewController;

typedef void(^CYScrollContentScrollViewDidScrollHandle)(CYScrollContentView *scrollContentView, UIScrollView *scrollView, BOOL manualTrigger);

typedef void(^CYScrollContentScrollViewDidEndScrollingAnimationHandle)(CYScrollContentView *scrollContentView, UIScrollView *scrollView);

@interface CYScrollContentView : UIView <CYScrollReloadRule>

@property (nonatomic, assign, readonly) NSInteger selectedIndex;

@property (nonatomic, weak, readonly) UICollectionView *colView;

@property (nonatomic, strong, readonly) CYScrollConfiguration *configuration;

@property (nonatomic, weak, readonly) UIViewController *parentViewController;

- (void)scrollToSelectedIndex:(NSInteger)selectedIndex;

- (void)setupConfiguration:(CYScrollConfiguration *)configuration parentViewController:(UIViewController *)parentViewController;

- (void)setupScrollViewDidScrollHandle:(CYScrollContentScrollViewDidScrollHandle)scrollViewDidScrollHandle;

- (void)setupScrollViewDidEndScrollingAnimationHandle:(CYScrollContentScrollViewDidEndScrollingAnimationHandle)endScrollingAnimationHandle;

@end
