//
//  ViewController.m
//  Scroll
//
//  Created by y on 2017/12/19.
//  Copyright © 2017年 cy. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController {
    NSArray *_titles1;
//    NSArray *_titles2;
}

+ (void)initialize { 
    [UINavigationBar appearance].translucent = false;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"疼讯视频";
    _titles1 = @[@"精选", @"爱看", @"电影", @"综艺", @"体育", @"NBA", @"新闻", @"网络电影", @"王者出击", @"吐槽大会", @"王者荣耀", @"电视剧",@"少儿", @"动漫", @"纪录片"];
}

- (IBAction)jump:(id)sender {
    CYScrollConfiguration *configuration = [CYScrollConfiguration new];
    configuration.titleViewHeight = 44;
    [configuration setNumberOfChildViewControllers:_titles1.count];
    for (int index = 0; index < _titles1.count; index++) {
        NSString *title = _titles1[index];
        CYScrollConfigurationItem *item = [CYScrollConfigurationItem new];
        item.title = title;
        UIViewController *controller = [UIViewController new];
        if (index % 2 == 0) {
            controller.view.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        } else {
            controller.view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        }
        item.childViewController = controller;
        [configuration initializeItem:item index:index];
    }
    CYScrollViewController *scroll = [CYScrollViewController scrollViewControllerWithConfiguration:configuration];
    scroll.delegate = self;
    scroll.view.backgroundColor = [UIColor lightGrayColor];
    [self.navigationController pushViewController:scroll animated:true];
}

- (void)scrollViewController:(CYScrollViewController *)scrollViewController scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView index:(NSInteger)index {
}

@end


//- (void)setupComponentsWithColor:(UIColor *)color begin:(BOOL)begin {
//    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//    unsigned char resultingPixel[4];
//    CGContextRef context = CGBitmapContextCreate(&resultingPixel, 1, 1, 8, 4, rgbColorSpace, 1);
//    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
//    CGContextRelease(context);
//    CGColorSpaceRelease(rgbColorSpace);
//    for (int component = 0; component < 3; component++) {
////        if (begin) {
////            _colorComponents[component] = @(resultingPixel[component] / 255.0f);
////        } else {
////            _colorComponents[component + 3] = @(resultingPixel[component] / 255.0f);
////        }
//    }
//}


//
//- (void)itemAnimationWithContentViewOffset:(CGPoint)contentViewOffset contentViewWidth:(CGFloat)contentViewWidth {
//    if (!_configuration.commonItem.gradient) return;
//    NSInteger selectedIndex = contentViewOffset.x / contentViewWidth;
//    if (selectedIndex < 0 || selectedIndex >= self.scrollView.subviews.count - 1) return;
//    if (_configuration.commonItem.gradient) {
//        if (!_colorComponents) {
//            _colorComponents = [NSMutableArray new];
//            [self setupComponentsWithColor:_configuration.commonItem.titleTextColor begin:true];
//            [self setupComponentsWithColor:_configuration.commonItem.selectedTitleTextColor begin:false];
//        }
//    }
//
//    BOOL isScrollToRight = contentViewOffset.x - selectedIndex * contentViewWidth;
//
//    CYScrollTitleItemView *selectedItemView = self.scrollView.subviews[selectedIndex];
//    CGFloat delta = contentViewOffset.x - contentViewWidth * selectedIndex;
//    if (delta > 0) {
//        CGFloat division = delta / contentViewWidth;
//        //    CYScrollConfigurationItem *currentItem = [_configuration itemAtIndex:selectedIndex];
//        CYScrollTitleItemView *currentView = selectedItemView;
//        //    CYScrollConfigurationItem *nextItem = [_configuration itemAtIndex:selectedIndex + 1];
//        CYScrollTitleItemView *nextView = self.scrollView.subviews[selectedIndex + 1];
//        if (_colorComponents.count == 6) {
//            //        CGFloat startR = [_colorComponents[0] floatValue];
//            //        CGFloat startG = [_colorComponents[1] floatValue];
//            //        CGFloat startB = [_colorComponents[2] floatValue];
//            //        CGFloat endR = [_colorComponents[3] floatValue];
//            //        CGFloat endG = [_colorComponents[4] floatValue];
//            //        CGFloat endB = [_colorComponents[5] floatValue];
//            //        CGFloat r = endR - startR;
//            //        CGFloat g = endG - startG;
//            //        CGFloat b = endB - startB;
//            //        CGFloat left = division;
//            //        CGFloat right = 1 - left;
//            //        UIColor *rightColor = [UIColor colorWithRed:startR + r * right green:startG + g * right blue:startB + b * right alpha:1];
//            //        UIColor *leftColor = [UIColor colorWithRed:startR + r * left green:startG + g * left  blue:startB + b * left alpha:1];
//            if (isScrollToRight) {
//                currentView.gradientColor = [UIColor blackColor];
//                nextView.gradientColor = [UIColor redColor];
//            } else {
//                if (selectedIndex >= 1) {
//                    CYScrollTitleItemView *preView = self.scrollView.subviews[selectedIndex + 1];
//                    preView.gradientColor = [UIColor blackColor];
//                    currentView.gradientColor = [UIColor redColor];
//                }
//            }
//        }
//    }
//}
