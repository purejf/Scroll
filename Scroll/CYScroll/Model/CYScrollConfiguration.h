//
//  CYScrollViewControllerConfiguration.h
//  Scroll
//
//  Created by y on 2017/12/20.
//  Copyright © 2017年 cy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYScrollConstant.h"
#import "CYScrollReloadRule.h"

@class CYScrollConfigurationItem, CYScrollConfigurationCommonItem;

@interface CYScrollConfiguration : NSObject <CYScrollReloadRule>

@property (nonatomic, assign) CYScrollContentScrollDirection scrollDirection;

@property (nonatomic, assign) CGFloat titleViewHeight;

@property (nonatomic, assign) NSInteger numberOfChildViewControllers;

@property (nonatomic, assign) CGFloat titleContentMargin;

@property (nonatomic, strong) CYScrollConfigurationCommonItem *commonItem;

- (void)initializeItem:(CYScrollConfigurationItem *)item index:(NSInteger)index;

- (CYScrollConfigurationItem *)itemAtIndex:(NSInteger)index;

@end

@interface CYScrollConfigurationCommonItem : NSObject

@property (nonatomic, assign) BOOL scrollFill;

@property (nonatomic, assign) BOOL gradient;

@property (nonatomic, assign) bool showLine;

@property (nonatomic, assign) bool lineStretchingAnimation;

@property (nonatomic, assign) bool lineMoveWithAnimation;

@property (nonatomic, assign) CGFloat lineMoveAnimationInterval;

@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, assign) CGFloat lineHeight;

@property (nonatomic, assign) CGFloat lineBottomMargin;

@property (nonatomic, assign) CGFloat titleItemLayerCornerRadius;

@property (nonatomic, strong) UIColor *titleItemLayerBorderColor;

@property (nonatomic, assign) CGFloat titleItemLayerBorderWidth;

@property (nonatomic, assign) UIEdgeInsets titleItemPadding;

@property (nonatomic, assign) CGFloat titleItemLeftMargin;

@property (nonatomic, assign) CGFloat titleItemRightMargin;

@property (nonatomic, strong) UIColor *titleTextColor;

@property (nonatomic, strong) UIColor *selectedTitleTextColor;

@property (nonatomic, strong) UIFont *titleTextFont;

@property (nonatomic, assign) CGFloat selectedTitleItemScale;

@property (nonatomic, strong) UIColor *titleItemBackgroundColor;

@property (nonatomic, strong) UIColor *selectedTitleItemBackgroundColor;

@property (nonatomic, assign) BOOL titleItemWidthAccordingToContentSize;

@end

@interface CYScrollConfigurationItem : NSObject

@property (nonatomic, strong, readonly) CYScrollConfigurationCommonItem *commonItem;

@property (nonatomic, assign) CGFloat titleItemWidth;

@property (nonatomic, assign) CGFloat titleItemHeight;

@property (nonatomic, strong) UIViewController *childViewController;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) UIEdgeInsets contentInsets;

+ (instancetype)itemWithCommonItem:(CYScrollConfigurationCommonItem *)commonItem;

@end
