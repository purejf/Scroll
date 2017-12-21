//
//  CYScrollViewControllerDelegate.h
//  Scroll
//
//  Created by y on 2017/12/20.
//  Copyright © 2017年 cy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYScrollViewController;

@protocol CYScrollViewControllerDelegate <NSObject>

- (void)scrollViewController:(CYScrollViewController *)scrollViewController didSelectedTitleItemAtIndex:(NSInteger)index;

- (void)scrollViewController:(CYScrollViewController *)scrollViewController scrollViewDidScroll:(UIScrollView *)scrollView;

@end
