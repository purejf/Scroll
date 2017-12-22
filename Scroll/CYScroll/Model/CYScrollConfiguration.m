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

- (CYScrollConfigurationCommonItem *)commonItem {
    if (!_commonItem) {
        _commonItem = [CYScrollConfigurationCommonItem new];
    }
    return _commonItem;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _scrollDirection = CYScrollContentScrollDirectionHorizontal;
        _titleViewHeight = 40.0;
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

@implementation CYScrollConfigurationCommonItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _titleTextColor = [UIColor blackColor];
        _titleTextFont = [UIFont systemFontOfSize:12];
        _selectedTitleItemScale = 1.0;
        _selectedTitleTextColor = [UIColor redColor];
        _titleItemPadding = UIEdgeInsetsMake(5, 5, 5, 5);
        _titleItemLeftMargin = 5.0;
        _titleItemRightMargin = 5.0;
        _titleItemBackgroundColor = [UIColor whiteColor];
        _selectedTitleItemBackgroundColor = [UIColor whiteColor];
        _titleItemLayerCornerRadius = 10.0;
        _showLine = true;
        _lineColor = [UIColor orangeColor];
        _lineHeight = 4.0;
        _lineBottomMargin = 2.0;
        _lineMoveWithAnimation = true;
        _lineMoveAnimationInterval = 0.3;
        _lineStretchingAnimation = true;
        _titleItemWidthAccordingToContentSize = true;
        _gradient = true;
    }
    return self;
}

@end

@interface CYScrollConfigurationItem ()

@property (nonatomic, strong) CYScrollConfigurationCommonItem *commonItem;

@end

@implementation CYScrollConfigurationItem

+ (instancetype)itemWithCommonItem:(CYScrollConfigurationCommonItem *)commonItem {
    CYScrollConfigurationItem *item = [CYScrollConfigurationItem new];
    item.commonItem = commonItem;
    return item;
}

- (CYScrollConfigurationCommonItem *)commonItem {
    if (!_commonItem) {
        _commonItem = [CYScrollConfigurationCommonItem new];
    }
    return _commonItem;
}

#pragma mark - Get

- (CGFloat)titleItemWidth {
    if (!_titleItemWidth) {
        NSString *title = self.title;
        UIFont *titleTextFont = self.commonItem.titleTextFont;
        if (title && titleTextFont) {
            NSDictionary *attributes = @{NSFontAttributeName: titleTextFont};
            _titleItemWidth = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width;
        }
    }
    return _titleItemWidth;
}

- (CGFloat)titleItemHeight {
    if (!_titleItemHeight) {
        NSString *title = self.title;
        UIFont *titleTextFont = self.commonItem.titleTextFont;
        if (title && titleTextFont) {
            NSDictionary *attributes = @{NSFontAttributeName: titleTextFont};
            _titleItemHeight = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.height;
        }
    }
    return _titleItemHeight;
}

@end
