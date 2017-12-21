//
//  CYScrollViewControllerDataSource.h
//  Scroll
//
//  Created by y on 2017/12/20.
//  Copyright © 2017年 cy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYScrollConstant.h"

@class CYScrollViewController, CYScrollConfigurationItem;

@protocol CYScrollViewControllerDataSource <NSObject>

- (NSInteger)numberOfChildViewControllersInScrollViewController:(CYScrollViewController *)scrollViewController;

- (CGFloat)titleViewHeightForScrollViewController:(CYScrollViewController *)scrollViewController;

- (CYScrollConfigurationItem *)scrollViewController:(CYScrollViewController *)scrollViewController configurationItemAtIndex:(NSInteger)index;

@optional

- (CYScrollContentScrollDirection)scrollDirectionForScrollViewController:(CYScrollViewController *)scrollViewController;

- (CGFloat)titleContentMarginForScrollViewController:(CYScrollViewController *)scrollViewController;

@end
