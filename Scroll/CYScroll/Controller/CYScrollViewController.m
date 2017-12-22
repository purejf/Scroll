//
//  CYScrollViewController.m
//  Scroll
//
//  Created by y on 2017/12/19.
//  Copyright © 2017年 cy. All rights reserved.
//

#import "CYScrollViewController.h"
#import "CYScrollViewControllerDelegate.h"
#import "CYScrollViewControllerDataSource.h"
#import "CYScrollConfiguration.h" 
#import "CYScrollTitleView.h"
#import "CYScrollContentView.h"
#import "CYScrollReloadRule.h"

@interface CYScrollViewController ()

@property (nonatomic, strong) CYScrollConfiguration *configuration;

@property (nonatomic, weak) CYScrollTitleView <CYScrollReloadRule>*titleView;

@property (nonatomic, weak) CYScrollContentView <CYScrollReloadRule>*contentView;

@end

@implementation CYScrollViewController {
   NSLayoutConstraint *_contentTopConstraint;
}

+ (instancetype)scrollViewControllerWithConfiguration:(CYScrollConfiguration *)configuration {
    CYScrollViewController *scrollViewController = [CYScrollViewController new];
    scrollViewController.configuration = configuration;
    return scrollViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"疼讯视频";
    [self setup];
    [self reloadData];
}

- (void)setup {
    self.view.backgroundColor = [UIColor whiteColor];
    if (!_configuration) _configuration = [CYScrollConfiguration new];
}

- (void)reloadData { 
    for (NSInteger index = 0; index < self.childViewControllers.count; index++) {
        UIViewController *childViewController = self.childViewControllers[index];
        [childViewController willMoveToParentViewController:nil];
        [childViewController.view removeFromSuperview];
        [childViewController removeFromParentViewController];
    }
    [self _setupTheDataSource];
    if (!_titleView || !_contentView) {
        [self _setupTheTitleView];
        [self _setupTheContentView];
        [self _setupTheConstraints];
    }
    [self _setupTheTitleContentMargin];
    [(CYScrollTitleView *)self.titleView setupConfiguration:_configuration];
    [(CYScrollContentView *)self.contentView setupConfiguration:_configuration parentViewController:self];
}

- (void)_setupTheDataSource {
    if ([_dataSource respondsToSelector:@selector(numberOfChildViewControllersInScrollViewController:)]) {
        NSInteger numberOfChildViewControllers = [_dataSource numberOfChildViewControllersInScrollViewController:self];
        _configuration.numberOfChildViewControllers = numberOfChildViewControllers;
    }
    if ([_dataSource respondsToSelector:@selector(scrollDirectionForScrollViewController:)]) {
        CYScrollContentScrollDirection scrollDirection = [_dataSource scrollDirectionForScrollViewController:self];
        _configuration.scrollDirection = scrollDirection;
    }
    if ([_dataSource respondsToSelector:@selector(titleContentMarginForScrollViewController:)]) {
        CGFloat titleContentMargin = [_dataSource titleContentMarginForScrollViewController:self];
        _configuration.titleContentMargin = titleContentMargin;
    }
    if ([_dataSource respondsToSelector:@selector(titleViewHeightForScrollViewController:)]) {
        CGFloat titleViewHeight = [_dataSource titleViewHeightForScrollViewController:self];
        _configuration.titleViewHeight = titleViewHeight;
    }
    for (NSInteger index = 0; index < _configuration.numberOfChildViewControllers; index++) {
        if ([_dataSource respondsToSelector:@selector(scrollViewController:configurationItemAtIndex:)]) {
            CYScrollConfigurationItem *item = [_dataSource scrollViewController:self configurationItemAtIndex:index];
            if (!item) {
                  NSCAssert(item != nil, @"item must != nil at index: %ld", index);
            }
            if (!item.childViewController) {
                  NSCAssert(item.childViewController != nil, @"item.childViewController must != nil at index: %ld", index);
            }
            if (!item.title) {
                NSCAssert(item.title != nil, @"item.title must != nil at index: %ld", index);
            }
            [_configuration initializeItem:item index:index];
        }
    }
}

- (void)_setupTheTitleView {
    __weak typeof(self) weakSelf = self;
    [(CYScrollTitleView *)self.titleView setupDidClickItemHandle:^(CYScrollTitleView *titleView, NSInteger selectedIndex) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf->_contentView scrollToSelectedIndex:selectedIndex];
        if ([strongSelf->_delegate respondsToSelector:@selector(scrollViewController:didSelectedTitleItemAtIndex:)]) {
            [strongSelf->_delegate scrollViewController:strongSelf didSelectedTitleItemAtIndex:selectedIndex];
        }
    }];
}

- (void)_setupTheContentView {
    __weak typeof(self) weakSelf = self;
    [(CYScrollContentView *)self.contentView setupScrollViewDidScrollHandle:^(CYScrollContentView *scrollContentView, UIScrollView *scrollView, BOOL manualTrigger) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (manualTrigger) { // 如果是手动滑动的content，那么触发此事件
            [(CYScrollTitleView *)strongSelf->_titleView scrollToContentViewOffset:scrollView.contentOffset contentViewWidth:scrollView.bounds.size.width];
        }
        if ([strongSelf->_delegate respondsToSelector:@selector(scrollViewController:scrollViewDidScroll:)]) {
            [strongSelf->_delegate scrollViewController:strongSelf scrollViewDidScroll:scrollView];
        }
    }];
}

- (void)_setupTheConstraints {
    self.titleView.translatesAutoresizingMaskIntoConstraints = false;
    for (NSNumber *attribute in @[@(NSLayoutAttributeTop), @(NSLayoutAttributeLeft), @(NSLayoutAttributeRight)]) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.view attribute:attribute.integerValue relatedBy:NSLayoutRelationEqual toItem:self.titleView attribute:attribute.integerValue multiplier:1.0 constant:0.0];
        [self.view addConstraint:constraint];
    }
    CGFloat titleViewHeight = _configuration.titleViewHeight;
    NSLayoutConstraint *titleViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:titleViewHeight];
    [self.titleView addConstraint:titleViewHeightConstraint];
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = false;
    NSLayoutConstraint *contentTopConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:-1.0 constant:titleViewHeight];
    [self.view addConstraint:contentTopConstraint];
    _contentTopConstraint = contentTopConstraint;
    
    for (NSNumber *attribute in @[@(NSLayoutAttributeBottom), @(NSLayoutAttributeLeft), @(NSLayoutAttributeRight)]) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.view attribute:attribute.integerValue relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:attribute.integerValue multiplier:1.0 constant:0.0];
        [self.view addConstraint:constraint];
    }
}

- (void)_setupTheTitleContentMargin {
    if (_contentTopConstraint) {
        _contentTopConstraint.constant = _configuration.titleViewHeight + _configuration.titleContentMargin;
    }
}

- (void)addChildViewController:(UIViewController *)childController {
    if (![childController isKindOfClass:[UIViewController class]]) return;
    if ([self.childViewControllers containsObject:childController]) return;
    [super addChildViewController:childController];
}

- (CYScrollTitleView *)titleView {
    if (!_titleView) {
        CYScrollTitleView *titleView = [CYScrollTitleView new];
        [self.view addSubview:titleView];
        _titleView = titleView;
        titleView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
    }
    return _titleView;
}

- (CYScrollContentView *)contentView {
    if (!_contentView) {
        CYScrollContentView *contentView = [CYScrollContentView new];
        [self.view addSubview:contentView];
        _contentView = contentView;
    }
    return _contentView;
}

#pragma mark - reloadData

- (void)reloadDataWithConfiguration:(CYScrollConfiguration *)configuration {
    if (!configuration) return;
    _configuration = configuration;
    [self reloadData];
}

- (void)reloadDataByInsertItem:(CYScrollConfigurationItem *)item index:(NSInteger)index {
    if (!item || index > _configuration.numberOfChildViewControllers) return;
    [self.configuration reloadByInsertItem:item index:index];
    if ([(CYScrollTitleView *)self.titleView respondsToSelector:@selector(reloadByInsertItem:index:)]) {
        [(CYScrollTitleView *)self.titleView reloadByInsertItem:item index:index];
    }
    if ([(CYScrollContentView *)self.contentView respondsToSelector:@selector(reloadByInsertItem:index:)]) {
        [(CYScrollContentView *)self.contentView reloadByInsertItem:item index:index];
    }
}

- (void)reloadDataByRemoveItemAtIndex:(NSInteger)index {
    if (index >= _configuration.numberOfChildViewControllers) return;
    [_configuration reloadByRemoveItemAtIndex:index];
    if ([(CYScrollTitleView *)self.titleView respondsToSelector:@selector(reloadByRemoveItemAtIndex:)]) {
        [(CYScrollTitleView *)self.titleView reloadByRemoveItemAtIndex:index];
    }
    if ([(CYScrollContentView *)self.contentView respondsToSelector:@selector(reloadByRemoveItemAtIndex:)]) {
        [(CYScrollContentView *)self.contentView reloadByRemoveItemAtIndex:index];
    }
}

- (void)reloadDataByExchangeItemIndexFrom:(NSInteger)from to:(NSInteger)to {
    if (from >= _configuration.numberOfChildViewControllers || to >= _configuration.numberOfChildViewControllers) return;
    [_configuration reloadByExchangeItemIndexFrom:from to:to];
    if ([(CYScrollTitleView *)self.titleView respondsToSelector:@selector(reloadByExchangeItemIndexFrom:to:)]) {
        [(CYScrollTitleView *)self.titleView reloadByExchangeItemIndexFrom:from to:to];
    }
    if ([(CYScrollContentView *)self.contentView respondsToSelector:@selector(reloadByExchangeItemIndexFrom:to:)]) {
        [(CYScrollContentView *)self.contentView reloadByExchangeItemIndexFrom:from to:to];
    }
}

@end
