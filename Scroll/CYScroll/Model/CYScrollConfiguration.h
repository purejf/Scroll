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

@class CYScrollConfigurationItem;

@interface CYScrollConfiguration : NSObject <CYScrollReloadRule>

@property (nonatomic, assign) CYScrollContentScrollDirection scrollDirection;

@property (nonatomic, assign) CGFloat titleViewHeight;

@property (nonatomic, assign) NSInteger numberOfChildViewControllers;

@property (nonatomic, assign) CGFloat titleContentMargin;

- (void)initializeItem:(CYScrollConfigurationItem *)item index:(NSInteger)index;

- (CYScrollConfigurationItem *)itemAtIndex:(NSInteger)index;

@end

@interface CYScrollConfigurationItem : NSObject

@property (nonatomic, assign) CGFloat titleItemWidth;

@property (nonatomic, strong) UIColor *titleTextColor;

@property (nonatomic, strong) UIColor *selectedTitleTextColor;

@property (nonatomic, strong) UIFont *titleTextFont;

@property (nonatomic, assign) CGFloat selectedTitleItemScale;

@property (nonatomic, strong) UIViewController *childViewController;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) UIEdgeInsets contentInsets;

@end
