//
//  CYScrollTitleView.m
//  Scroll
//
//  Created by y on 2017/12/20.
//  Copyright © 2017年 cy. All rights reserved.
//

#import "CYScrollTitleView.h"
#import "CYScrollConfiguration.h"
#import "CYScrollReloadRule.h"

@interface CYScrollTitleItemLabel : UILabel

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) UIColor *fillColor;

@end

@implementation CYScrollTitleItemLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (!_fillColor) return;
    [_fillColor set];
    
    CGRect newRect = rect;
    newRect.size.width = rect.size.width * self.progress;
    UIRectFillUsingBlendMode(newRect, kCGBlendModeSourceIn);
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

@end

@interface CYScrollTitleItemView : UIView

@property (nonatomic, strong) CYScrollConfigurationItem *item;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) UIColor *fillColor;

@end

@interface CYScrollTitleItemView ()

@property (nonatomic, weak) CYScrollTitleItemLabel *titleL;

@end

@implementation CYScrollTitleItemView

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    if (self.item.commonItem.scrollFill) {
        self.titleL.progress = progress;
    }
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    self.titleL.fillColor = fillColor;
}

- (void)setItem:(CYScrollConfigurationItem *)item {
    _item = item;
    self.titleL.text = item.title;
    self.titleL.font = item.commonItem.titleTextFont;
    self.titleL.textColor = item.commonItem.titleTextColor;
    if (item.commonItem.titleItemLayerCornerRadius ||
        item.commonItem.titleItemLayerBorderColor ||
        item.commonItem.titleItemLayerBorderWidth) {
        self.titleL.layer.masksToBounds = true;
        self.titleL.layer.shouldRasterize = true;
        self.titleL.layer.borderColor = item.commonItem.titleItemLayerBorderColor.CGColor;
        self.titleL.layer.borderWidth = item.commonItem.titleItemLayerBorderWidth;
        self.titleL.layer.cornerRadius = item.commonItem.titleItemLayerCornerRadius;
    }
}

#pragma mark - Set

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.titleL.textColor = selected ? self.item.commonItem.selectedTitleTextColor : self.item.commonItem.titleTextColor;
    if (!self.item.commonItem.scrollFill) {
        self.titleL.backgroundColor = selected ? self.item.commonItem.selectedTitleItemBackgroundColor : self.item.commonItem.titleItemBackgroundColor;
    } else {
        self.titleL.backgroundColor = [UIColor clearColor];
    }
    CGFloat scale = selected ? self.item.commonItem.selectedTitleItemScale : 1.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.titleL.transform = CGAffineTransformMakeScale(scale, scale);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleL.frame = self.bounds;
}

#pragma mark - Lazy Load

- (CYScrollTitleItemLabel *)titleL {
    if (!_titleL) {
        CYScrollTitleItemLabel *titleL = [CYScrollTitleItemLabel new];
        [self addSubview:titleL];
        _titleL = titleL;
        titleL.textAlignment = NSTextAlignmentCenter;
    }
    return _titleL;
}

@end

@interface CYScrollTitleView ()

@property (nonatomic, strong) NSMutableArray *subviews;

@property (nonatomic, weak) UIView *lineV;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) CYScrollConfiguration *configuration;

@property (nonatomic, strong) CYScrollTitleItemView *selectedItemView;

@end

@implementation CYScrollTitleView {
    CYScrollTitleDidClickItemHandle _didClickItemHandle;
    BOOL _reloadLine;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _subviews = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Set

- (void)lineStrectingAnimationWithContentViewOffset:(CGPoint)contentViewOffset contentViewWidth:(CGFloat)contentViewWidth {
    if (!_configuration.commonItem.lineStretchingAnimation) return;
    NSInteger selectedIndex = contentViewOffset.x / contentViewWidth;
    if (selectedIndex < 0 || selectedIndex >= _subviews.count - 1) return;
    CYScrollTitleItemView *selectedItemView = _subviews[selectedIndex];
    CGFloat delta = contentViewOffset.x - contentViewWidth * selectedIndex;
    CGFloat division = delta / contentViewWidth;
    CYScrollConfigurationItem *currentItem = [_configuration itemAtIndex:selectedIndex];
    CYScrollTitleItemView *currentView = selectedItemView;
    CYScrollConfigurationItem *nextItem = [_configuration itemAtIndex:selectedIndex + 1];
    CYScrollTitleItemView *nextView = _subviews[selectedIndex + 1];
    CGFloat maxLineW = (nextView.frame.origin.x + nextView.frame.size.width) - (currentView.frame.origin.x);
    if (_configuration.commonItem.titleItemWidthAccordingToContentSize) {
        maxLineW -= (_configuration.commonItem.titleItemPadding.left + _configuration.commonItem.titleItemPadding.right);
    }
    CGFloat lineW;
    CGFloat lineX;
    if (division <= 0.5) {
        lineW = maxLineW * (division / 0.5);
        lineX = currentView.frame.origin.x;
        if (_configuration.commonItem.titleItemWidthAccordingToContentSize) {
            if (lineW < currentItem.titleItemWidth) {
                lineW = currentItem.titleItemWidth;
            }
            lineX += _configuration.commonItem.titleItemPadding.left;
        } else {
            if (lineW < currentView.frame.size.width) {
                lineW = currentView.frame.size.width;
            }
        }
    } else {
        lineW = maxLineW * ((1 - division) / 0.5);
        if (_configuration.commonItem.titleItemWidthAccordingToContentSize) {
            if (lineW < nextItem.titleItemWidth) {
                lineW = nextItem.titleItemWidth;
            }
        } else {
            if (lineW < nextView.frame.size.width) {
                lineW = nextView.frame.size.width;
            }
        }
        lineX = (nextView.frame.origin.x + nextView.frame.size.width) - lineW;
        if (_configuration.commonItem.titleItemWidthAccordingToContentSize) {
            lineX -= _configuration.commonItem.titleItemPadding.right;
        }
    }
    CGRect lineFrame = self.lineV.frame;
    lineFrame.size.width = lineW;
    lineFrame.origin.x = lineX;
    self.lineV.frame = lineFrame;
}

- (void)scrollToContentViewOffset:(CGPoint)contentViewOffset contentViewWidth:(CGFloat)contentViewWidth {
    _reloadLine = false;
    [self lineStrectingAnimationWithContentViewOffset:contentViewOffset contentViewWidth:contentViewWidth];
    [self scrollFillWithContentViewOffset:contentViewOffset contentViewWidth:contentViewWidth];
    NSInteger selectedIndex = contentViewOffset.x / contentViewWidth;
    [self toSelectedIndex:selectedIndex click:false];
}

- (void)scrollFillWithContentViewOffset:(CGPoint)contentViewOffset contentViewWidth:(CGFloat)contentViewWidth {
    if (!_configuration.commonItem.scrollFill) return;
    NSInteger selectedIndex = contentViewOffset.x / contentViewWidth;
    if (selectedIndex < 0 || selectedIndex >= _subviews.count - 1) return;
    CYScrollTitleItemView *selectedItemView = _subviews[selectedIndex];
    CGFloat delta = contentViewOffset.x - contentViewWidth * selectedIndex;
    CGFloat division = delta / contentViewWidth;
    CYScrollTitleItemView *currentView = selectedItemView;
    CYScrollTitleItemView *nextView = _subviews[selectedIndex + 1];
    currentView.fillColor = _configuration.commonItem.titleTextColor;
    nextView.fillColor = _configuration.commonItem.selectedTitleTextColor;
    currentView.progress = division;
    nextView.progress = division;
}

- (void)toSelectedIndex:(NSInteger)selectedIndex click:(BOOL)click {
    if (_selectedIndex == selectedIndex) return;
    if (selectedIndex >= _configuration.numberOfChildViewControllers || selectedIndex >= _subviews.count) return;
    _selectedIndex = selectedIndex;
    CYScrollTitleItemView *selectedItemView = _subviews[selectedIndex];
    self.selectedItemView.selected = false;
    selectedItemView.selected = true;
    self.selectedItemView = selectedItemView;
    CGFloat centerX = selectedItemView.center.x;
    CGFloat max = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
    CGFloat min = 0;
    CGFloat offsetX = 0;
    if (centerX > self.scrollView.bounds.size.width / 2.0) {
        offsetX = centerX - self.scrollView.bounds.size.width / 2.0;
    }
    if (offsetX > max) {
        offsetX = max;
    }
    if (offsetX < min) {
        offsetX = min;
    }
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:true];
    if (click) {
        void(^block)() = ^() {
            CGRect lineFrame = self.lineV.frame;
            CYScrollConfigurationItem *item = [_configuration itemAtIndex:selectedIndex];
            if (_configuration.commonItem.titleItemWidthAccordingToContentSize) {
                lineFrame.size.width = item.titleItemWidth;
            } else {
                lineFrame.size.width = selectedItemView.frame.size.width;
            }
            self.lineV.frame = lineFrame;
            CGPoint lineCenter = self.lineV.center;
            lineCenter.x = selectedItemView.center.x;
            self.lineV.center = lineCenter;
        };
        
        if (_configuration.commonItem.lineMoveWithAnimation && _configuration.commonItem.lineMoveAnimationInterval) {
            [UIView animateWithDuration:_configuration.commonItem.lineMoveAnimationInterval animations:block];
        } else {
            block();
        }
    }
}

- (void)toSelectedIndex:(NSInteger)selectedIndex {
    [self toSelectedIndex:selectedIndex click:true];
}

- (void)setupConfiguration:(CYScrollConfiguration *)configuration {
    _configuration = configuration;
    NSArray *subviews = _subviews;
    NSInteger subviewsCount = subviews.count;
    NSInteger numberOfChildViewControllers = _configuration.numberOfChildViewControllers;
    if (subviewsCount < numberOfChildViewControllers) {
        for (NSInteger index = subviewsCount; index < numberOfChildViewControllers; index++) {
            CYScrollTitleItemView *titleItemView = [CYScrollTitleItemView new];
            [self.scrollView addSubview:titleItemView];
            [_subviews addObject:titleItemView];
            titleItemView.userInteractionEnabled = true;
            UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestHandle:)];
            [titleItemView addGestureRecognizer:tapGest];
        }
    } else if (subviewsCount > numberOfChildViewControllers) {
        for (NSInteger index = numberOfChildViewControllers; index < subviewsCount; index++) {
            UIView *subview = subviews[index];
            [subview removeFromSuperview];
        }
    }
    for (NSInteger index = 0; index < numberOfChildViewControllers; index++) {
        CYScrollTitleItemView *titleItemView = _subviews[index];
        CYScrollConfigurationItem *item = [_configuration itemAtIndex:index];
        titleItemView.item = item;
        if (index == _selectedIndex) {
            titleItemView.selected = true;
            self.selectedItemView = titleItemView;
        } else {
            titleItemView.selected = false;
        }
    }
    if (_configuration.commonItem.showLine) {
        self.lineV.hidden = false;
        self.lineV.backgroundColor = _configuration.commonItem.lineColor;
    } else {
        self.lineV.hidden = true;
    }
    _reloadLine = true;
    [self toSelectedIndex:_selectedIndex];
    [self setNeedsLayout];
}

- (void)setupDidClickItemHandle:(CYScrollTitleDidClickItemHandle)didClickItemHandle {
    _didClickItemHandle = didClickItemHandle;
}

- (void)tapGestHandle:(UITapGestureRecognizer *)tapGest {
    UIView *view = tapGest.view;
    if ([view isKindOfClass:[CYScrollTitleItemView class]]) {
        CYScrollTitleItemView *titleItemView = (CYScrollTitleItemView *)view;
        if ([_subviews containsObject:titleItemView]) {
            NSInteger index = [_subviews indexOfObject:titleItemView];
            [self toSelectedIndex:index];
            !_didClickItemHandle ?: _didClickItemHandle(self, index);
        }
    }
}

#pragma mark - CYScrollReloadRule

- (void)reloadByRemoveItemAtIndex:(NSInteger)index; {
    if (index >= _subviews.count) return;
    if (_selectedIndex == index) {
        [self toSelectedIndex:0];
    }
    UIView *subview = _subviews[index];
    [subview removeFromSuperview];
    [self setNeedsLayout];
}

- (void)reloadByInsertItem:(CYScrollConfigurationItem *)item index:(NSInteger)index {
    if (!item) return;
    if (index >= _subviews.count) return;
    if (index <= _selectedIndex) {
        _selectedIndex += 1;
        //        [self reloadWithSelectedIndex:_selectedIndex];
    }
}

- (void)reloadByExchangeItemIndexFrom:(NSInteger)from to:(NSInteger)to {
    if (from >= _subviews.count) return;
    if (to >= _subviews.count) return;
    //    [self reloadWithSelectedIndex:_selectedIndex];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CYScrollConfigurationCommonItem *common = _configuration.commonItem;
    CGFloat lineH = 0;
    CGFloat lineY = self.bounds.size.height;
    CGFloat lineX = 0;
    CGFloat lineW = 0;
    if (common.showLine) {
        lineH = common.lineHeight;
        lineY = self.bounds.size.height - lineH - common.lineBottomMargin;
    }
    self.scrollView.frame = self.bounds;
    CGFloat titleItemViewX = 0;
    CGFloat titleItemViewY = 0;
    CGFloat titleItemViewW = 0;
    CGFloat titleItemViewH = 0;
    for (NSInteger index = 0; index < _subviews.count; index++) {
        UIView *subview = _subviews[index];
        if ([subview isKindOfClass:[CYScrollTitleItemView class]]) {
            CYScrollTitleItemView *titleItemView = (CYScrollTitleItemView *)subview;
            CYScrollConfigurationItem *item = [_configuration itemAtIndex:index];
            titleItemViewW = item.titleItemWidth;
            titleItemViewW += (common.titleItemPadding.left + common.titleItemPadding.right);
            titleItemViewX += _configuration.commonItem.titleItemLeftMargin;
            lineX = titleItemViewX;
            titleItemViewH = item.titleItemHeight;
            titleItemViewH += (common.titleItemPadding.top + common.titleItemPadding.bottom);
            titleItemViewY = (lineY - titleItemViewH) / 2.0;
            titleItemView.frame = CGRectMake(titleItemViewX, titleItemViewY, titleItemViewW, titleItemViewH);
            titleItemViewX += (titleItemViewW + _configuration.commonItem.titleItemRightMargin);
            if (index == _selectedIndex && _reloadLine) {
                if (common.titleItemWidthAccordingToContentSize) {
                    lineW = item.titleItemWidth;
                } else {
                    lineW = titleItemViewW;
                }
                self.lineV.frame = CGRectMake(lineX, lineY, lineW, lineH);
                CGPoint lineCenter = self.lineV.center;
                lineCenter.x = titleItemView.center.x;
                self.lineV.center = lineCenter;
            }
        }
    }
    self.scrollView.contentSize = CGSizeMake(titleItemViewX, self.scrollView.bounds.size.height);
}

#pragma mark - Lazy Load

- (UIView *)lineV {
    if (!_lineV) {
        UIView *lineV = [UIView new];
        [self.scrollView addSubview:lineV];
        _lineV = lineV;
    }
    return _lineV;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [UIScrollView new];
        [self addSubview:scrollView];
        _scrollView = scrollView;
        scrollView.showsVerticalScrollIndicator = false;
        scrollView.showsHorizontalScrollIndicator = false;
        _Pragma("clang diagnostic push")
        _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
        if ([UIScrollView instancesRespondToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]) {
            [scrollView performSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:") withObject:@(2)];
        }
        _Pragma("clang diagnostic pop")
    }
    return _scrollView;
}

@end
