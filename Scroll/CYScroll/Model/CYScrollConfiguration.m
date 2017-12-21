//
//  CYScrollViewControllerConfiguration.m
//  Scroll
//
//  Created by y on 2017/12/20.
//  Copyright © 2017年 cy. All rights reserved.
//

#import "CYScrollConfiguration.h" 

@implementation CYScrollConfiguration {
    NSMutableArray *_items;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _scrollDirection = CYScrollContentScrollDirectionHorizontal;
        _titleViewHeight = 44.0;
        _numberOfChildViewControllers = 0;
        _items = [NSMutableArray new];
    }
    return self;
}

- (void)initializeItem:(CYScrollConfigurationItem *)item index:(NSInteger)index {
    if (!item || index > _items.count) return;
    [_items insertObject:item atIndex:index];
}

- (CYScrollConfigurationItem *)itemAtIndex:(NSInteger)index {
    if (index >= _items.count) return nil;
    return _items[index];
}

#pragma mark - CYScrollReloadRule

- (void)reloadByRemoveItemAtIndex:(NSInteger)index {
    if (index >= _items.count) return;
    [_items removeObjectAtIndex:index];
    _numberOfChildViewControllers -= 1;
}

- (void)reloadByInsertItem:(CYScrollConfigurationItem *)item index:(NSInteger)index {
    if (!item || index > _items.count) return;
    _numberOfChildViewControllers += 1;
    [_items insertObject:item atIndex:index];
}

- (void)reloadByExchangeItemIndexFrom:(NSInteger)from to:(NSInteger)to {
    if (from >= _items.count || to >= _items.count) return;
    CYScrollConfigurationItem *fromItem = _items[from];
    CYScrollConfigurationItem *toItem = _items[to];
    _items[from] = toItem;
    _items[to] = fromItem;
}

@end

@implementation CYScrollConfigurationItem

#pragma mark - Get

- (CGFloat)titleItemWidth {
    if (!_titleItemWidth) {
        NSString *title = self.title;
        CGFloat titleItemScale = self.selectedTitleItemScale;
        UIFont *titleTextFont = self.titleTextFont;
        if (title && titleTextFont) {
            NSDictionary *attributes = @{NSFontAttributeName: titleTextFont};
            _titleItemWidth = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width * titleItemScale + 10;
        }
    }
    return _titleItemWidth;
}

- (UIColor *)titleTextColor {
    if (!_titleTextColor) {
        _titleTextColor = [UIColor blackColor];
    }
    return _titleTextColor;
}

- (UIFont *)titleTextFont {
    if (!_titleTextFont) {
        _titleTextFont = [UIFont systemFontOfSize:12];
    }
    return _titleTextFont;
}

- (UIColor *)selectedTitleTextColor {
    if (!_selectedTitleTextColor) {
        _selectedTitleTextColor = [UIColor redColor];
    }
    return _selectedTitleTextColor;
}

- (CGFloat)selectedTitleItemScale {
    if (!_selectedTitleItemScale) {
        _selectedTitleItemScale = 1.2;
    }
    return _selectedTitleItemScale;
}

@end
