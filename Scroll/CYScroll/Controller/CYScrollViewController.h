//
//  CYScrollViewController.h
//  Scroll
//
//  Created by y on 2017/12/19.
//  Copyright © 2017年 cy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CYScrollViewControllerDelegate, CYScrollViewControllerDataSource, CYScrollReloadRule;

@class CYScrollViewController, CYScrollConfiguration, CYScrollConfigurationItem, CYScrollTitleView, CYScrollContentView, CYScrollConfigurationCommonItem;

@interface CYScrollViewController : UIViewController

+ (instancetype)scrollViewControllerWithConfiguration:(CYScrollConfiguration *)configuration;

@property (nonatomic, strong, readonly) CYScrollConfiguration *configuration;

@property (nonatomic, weak, readonly) UIView *titleView;

@property (nonatomic, weak, readonly) UIView *contentView;

@property (nonatomic, weak) id <CYScrollViewControllerDelegate> delegate;

@property (nonatomic, weak) id <CYScrollViewControllerDataSource> dataSource;

@property (nonatomic, assign) NSInteger selectedIndex;

- (void)reloadData;

- (void)reloadDataWithConfiguration:(CYScrollConfiguration *)configuration;

- (void)reloadDataByInsertItem:(CYScrollConfigurationItem *)item index:(NSInteger)index;

- (void)reloadDataByRemoveItemAtIndex:(NSInteger)index;

- (void)reloadDataByExchangeItemIndexFrom:(NSInteger)from to:(NSInteger)to;

@end

