//
//  CYScrollContentView.m
//  Scroll
//
//  Created by y on 2017/12/20.
//  Copyright © 2017年 cy. All rights reserved.
//

#import "CYScrollContentView.h"
#import "CYScrollConfiguration.h" 
#import "CYScrollReloadRule.h"

@interface CYScrollViewCell : UICollectionViewCell

- (void)setupTheView:(UIView *)theView insets:(UIEdgeInsets)insets;

@end

@interface CYScrollViewCell ()

@property (nonatomic, weak) UIView *theView;

@property (nonatomic, assign) UIEdgeInsets insets;

@end

@implementation CYScrollViewCell

- (void)setupTheView:(UIView *)theView insets:(UIEdgeInsets)insets {
    if (theView) {
        [_theView removeFromSuperview];
        _theView = theView;
        if ([theView isKindOfClass:[UIView class]]) {
            [self.contentView addSubview:theView];
        }
    }
    _insets = insets;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat theViewX = self.insets.left;
    CGFloat theViewY = self.insets.top;
    CGFloat theViewW = self.contentView.bounds.size.width - self.insets.left - self.insets.right;
    CGFloat theViewH = self.contentView.bounds.size.height - self.insets.top - self.insets.bottom;
    self.theView.frame = CGRectMake(theViewX, theViewY, theViewW, theViewH);
}

@end

static NSString *const kCellId = @"kCYScrollContentViewCellId";

@interface CYScrollContentView () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, weak) UICollectionView *colView;

@property (nonatomic, strong) CYScrollConfiguration *configuration;

@property (nonatomic, weak) UIViewController *parentViewController;

@end

@implementation CYScrollContentView {
    CYScrollContentScrollViewDidScrollHandle _scrollViewDidScrollHandle;
    // 手动触发
    BOOL _manualTrigger;
}

- (void)scrollToSelectedIndex:(NSInteger)selectedIndex {
    _manualTrigger = false;
    if (selectedIndex >= _configuration.numberOfChildViewControllers) return;
    _selectedIndex = selectedIndex;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
    [self.colView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setupConfiguration:(CYScrollConfiguration *)configuration parentViewController:(UIViewController *)parentViewController {
    _configuration = configuration;
    _parentViewController = parentViewController;
    
    UICollectionViewLayout *layout = self.colView.collectionViewLayout;
    if ([layout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)layout;
        if (flowLayout.scrollDirection != (UICollectionViewScrollDirection)_configuration.scrollDirection) {
            flowLayout.scrollDirection = (UICollectionViewScrollDirection)_configuration.scrollDirection;
            [self.colView setCollectionViewLayout:flowLayout];
        }
    }
    [self.colView reloadData];
}

- (void)setupScrollViewDidScrollHandle:(CYScrollContentScrollViewDidScrollHandle)scrollViewDidScrollHandle {    
    _scrollViewDidScrollHandle = scrollViewDidScrollHandle;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.colView.frame = self.bounds;
}

#pragma mark - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _manualTrigger = true;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !_scrollViewDidScrollHandle ?: _scrollViewDidScrollHandle(self, scrollView, _manualTrigger);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
     _manualTrigger = true;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _configuration.numberOfChildViewControllers;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CYScrollViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    CYScrollConfigurationItem *item = [_configuration itemAtIndex:indexPath.row];
    UIViewController *childViewController = item.childViewController; //  [_configuration childViewControllerAtIndex:indexPath.row];
    UIEdgeInsets insets = item.contentInsets; //  [_configuration contentInsetsAtIndex:indexPath.row];
    if (childViewController && _parentViewController) {
        if ([_parentViewController.childViewControllers containsObject:childViewController]) [_parentViewController addChildViewController:childViewController];
        if (childViewController.view) [cell setupTheView:childViewController.view insets:insets];
        [childViewController didMoveToParentViewController:_parentViewController];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

#pragma mark - Lazy Load

- (UICollectionView *)colView {
    if (!_colView) {
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = (UICollectionViewScrollDirection)_configuration.scrollDirection;
        UICollectionView *colView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [self addSubview:colView];
        _colView = colView;
        colView.delegate = self;
        colView.dataSource = self;
        colView.pagingEnabled = true;
        colView.showsVerticalScrollIndicator = false;
        colView.showsHorizontalScrollIndicator = false;
        colView.backgroundColor = [UIColor whiteColor];
        [colView registerClass:[CYScrollViewCell class] forCellWithReuseIdentifier:kCellId];
    }
    return _colView;
}

#pragma mark - CYScrollReloadRule

- (void)reloadByRemoveItemAtIndex:(NSInteger)index {
    if (index >= [self.colView numberOfItemsInSection:0]) return;
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:index inSection:0]];
    [self.colView deleteItemsAtIndexPaths:indexPaths];
}

- (void)reloadByInsertItem:(CYScrollConfigurationItem *)item index:(NSInteger)index {
    if (!item) return;
    if (index >= [self.colView numberOfItemsInSection:0]) return;
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:index inSection:0]];
    [self.colView insertItemsAtIndexPaths:indexPaths];
}

- (void)reloadByExchangeItemIndexFrom:(NSInteger)from to:(NSInteger)to {
    if (from >= [self.colView numberOfItemsInSection:0]) return;
    if (to >= [self.colView numberOfItemsInSection:0]) return;
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:from inSection:0], [NSIndexPath indexPathForRow:to inSection:0]];
    [self.colView reloadItemsAtIndexPaths:indexPaths];
}

@end

