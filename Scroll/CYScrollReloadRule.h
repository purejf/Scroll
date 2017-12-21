//
//  CYScrollReloadRule.h
//  Scroll
//
//  Created by y on 2017/12/21.
//  Copyright © 2017年 cy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CYScrollConfigurationItem;

@protocol CYScrollReloadRule <NSObject>

- (void)reloadByRemoveItemAtIndex:(NSInteger)index;

- (void)reloadByInsertItem:(CYScrollConfigurationItem *)item index:(NSInteger)index;

- (void)reloadByExchangeItemIndexFrom:(NSInteger)from to:(NSInteger)to;

@end
