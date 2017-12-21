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

@interface CYScrollTitleItemView : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIColor *titleTextColor;

@property (nonatomic, strong) UIColor *selectedTitleTextColor;

@property (nonatomic, strong) UIFont *titleTextFont;

@property (nonatomic, assign) CGFloat selectedTitleItemScale;

@property (nonatomic, assign, readonly) BOOL selected;

- (void)setupSelected:(BOOL)selected;

@end

@interface CYScrollTitleItemView ()

@property (nonatomic, weak) UILabel *titleL;

@property (nonatomic, assign) BOOL selected;

@end

@implementation CYScrollTitleItemView

#pragma mark - Set

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleL.text = title;
}

- (void)setupSelected:(BOOL)selected {
    _selected = selected;
    self.titleL.textColor = selected ? self.selectedTitleTextColor : self.titleTextColor;
    CGFloat selectedTitleItemScale = selected ? _selectedTitleItemScale : 1.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.titleL.transform = CGAffineTransformMakeScale(selectedTitleItemScale, selectedTitleItemScale);
    }];
}

- (void)setTitleTextFont:(UIFont *)titleTextFont {
    _titleTextFont = titleTextFont;
    self.titleL.font = titleTextFont;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleL.frame = self.bounds;
}

#pragma mark - Lazy Load

- (UILabel *)titleL {
    if (!_titleL) {
        UILabel *titleL = [UILabel new];
        [self addSubview:titleL];
        _titleL = titleL;
        titleL.textAlignment = NSTextAlignmentCenter;
    }
    return _titleL;
}

@end

@interface CYScrollTitleView ()

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) CYScrollConfiguration *configuration;

@property (nonatomic, strong) CYScrollTitleItemView *selectedItemView;

@end

@implementation CYScrollTitleView {
    CYScrollTitleDidClickItemHandle _didClickItemHandle;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _selectedIndex = -1;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - Set

- (void)changeSelectedIndexWithContentViewOffset:(CGPoint)contentViewOffset contentViewWidth:(CGFloat)contentViewWidth {
    if (!contentViewWidth) return;
    NSInteger selectedIndex = (contentViewOffset.x + self.scrollView.bounds.size.width / 2.0) / contentViewWidth;
    [self setupSelectedIndex:selectedIndex];
}

- (void)setupSelectedIndex:(NSInteger)selectedIndex {
    if (_selectedIndex == selectedIndex) return;
    if (selectedIndex >= _configuration.numberOfChildViewControllers || selectedIndex >= self.scrollView.subviews.count) return;
    _selectedIndex = selectedIndex;
    
    CYScrollTitleItemView *selectedItemView = self.scrollView.subviews[selectedIndex];
    [self.selectedItemView setupSelected:false];
    [selectedItemView setupSelected:true];
    self.selectedItemView = selectedItemView;
    
    CGFloat centerX = selectedItemView.center.x;
    CGFloat max = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
    CGFloat offsetX = 0;
    
    if (centerX > self.scrollView.bounds.size.width / 2.0) {
        offsetX = centerX - self.scrollView.bounds.size.width / 2.0;
    }
    if (offsetX > max) {
        offsetX = max;
    }
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:true];
}

- (void)setupConfiguration:(CYScrollConfiguration *)configuration {
    _configuration = configuration;
    [self _reloadWithSelectedIndex:0];
}

- (void)setupDidClickItemHandle:(CYScrollTitleDidClickItemHandle)didClickItemHandle {
    _didClickItemHandle = didClickItemHandle;
}

- (void)_reloadWithSelectedIndex:(NSInteger)selectedIndex {
    NSArray *subviews = self.scrollView.subviews;
    [self setNeedsLayout];
    NSInteger subviewsCount = subviews.count;
    NSInteger numberOfChildViewControllers = _configuration.numberOfChildViewControllers;
    if (subviewsCount < numberOfChildViewControllers) {
        for (NSInteger index = subviewsCount; index < numberOfChildViewControllers; index++) {
            CYScrollTitleItemView *titleItemView = [CYScrollTitleItemView new];
            [self.scrollView addSubview:titleItemView];
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
        CYScrollTitleItemView *titleItemView = self.scrollView.subviews[index];
        CYScrollConfigurationItem *item = [_configuration itemAtIndex:index];
        titleItemView.title = item.title; // [_configuration titleAtIndex:index];
        titleItemView.titleTextFont = item.titleTextFont; // [_configuration titleTextFontAtIndex:index];
        titleItemView.selectedTitleItemScale = item.selectedTitleItemScale; // [_configuration selectedTitleItemScaleAtIndex:index];
        titleItemView.titleTextColor = item.titleTextColor; // [_configuration titleTextColorAtIndex:index];
        titleItemView.selectedTitleTextColor = item.selectedTitleTextColor; // [_configuration selectedTitleTextColorAtIndex:index];
        [titleItemView setupSelected:false];
    }
    [self setNeedsLayout];
    if (selectedIndex >= 0) {
        [self setupSelectedIndex:selectedIndex];
    }
}

- (void)tapGestHandle:(UITapGestureRecognizer *)tapGest {
    UIView *view = tapGest.view;
    if ([view isKindOfClass:[CYScrollTitleItemView class]]) {
        CYScrollTitleItemView *titleItemView = (CYScrollTitleItemView *)view;
        if ([self.scrollView.subviews containsObject:titleItemView]) {
            NSInteger index = [self.scrollView.subviews indexOfObject:titleItemView];
            [self setupSelectedIndex:index];
            !_didClickItemHandle ?: _didClickItemHandle(self, index);
        }
    }
}

#pragma mark - CYScrollReloadRule

- (void)reloadByRemoveItemAtIndex:(NSInteger)index; {
    if (index >= self.scrollView.subviews.count) return;
    if (_selectedIndex == index) {
        [self setupSelectedIndex:0];
    }
    UIView *subview = self.scrollView.subviews[index];
    [subview removeFromSuperview];
    [self setNeedsLayout];
}

- (void)reloadByInsertItem:(CYScrollConfigurationItem *)item index:(NSInteger)index {
    if (!item) return;
    if (index >= self.scrollView.subviews.count) return;
    if (index <= _selectedIndex) {
        _selectedIndex += 1;
        [self _reloadWithSelectedIndex:_selectedIndex];
    }
}

- (void)reloadByExchangeItemIndexFrom:(NSInteger)from to:(NSInteger)to {
    if (from >= self.scrollView.subviews.count) return;
    if (to >= self.scrollView.subviews.count) return;
    [self _reloadWithSelectedIndex:_selectedIndex];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    CGFloat titleItemViewX = 0;
    for (NSInteger index = 0; index < self.scrollView.subviews.count; index++) {
        UIView *subview = self.scrollView.subviews[index];
        if ([subview isKindOfClass:[CYScrollTitleItemView class]]) {
            CYScrollTitleItemView *titleItemView = (CYScrollTitleItemView *)subview;
            CYScrollConfigurationItem *item = [_configuration itemAtIndex:index];
            CGFloat titleItemViewW = item.titleItemWidth; // [_configuration titleItemWidthAtIndex:index];
            titleItemView.frame = CGRectMake(titleItemViewX, 0, titleItemViewW, self.frame.size.height);
            titleItemViewX += titleItemViewW;
        }
    }
    self.scrollView.contentSize = CGSizeMake(titleItemViewX, self.scrollView.superview.bounds.size.height);
}

#pragma mark - Lazy Load

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
