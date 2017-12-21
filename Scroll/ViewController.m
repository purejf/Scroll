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
    NSArray *_titles2;
}

+ (void)initialize { 
    [UINavigationBar appearance].translucent = false;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"疼讯视频";
    _titles1 = @[@"精选", @"爱看", @"电影", @"综艺", @"体育", @"NBA"];
    _titles2 = @[@"精选", @"爱看", @"电影", @"综艺", @"体育", @"NBA", @"新闻", @"网络电影", @"王者出击", @"吐槽大会", @"王者荣耀", @"电视剧",@"少儿", @"动漫", @"纪录片"];
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
        item.selectedTitleItemScale = 1.5;
        [configuration initializeItem:item index:index];
    }
    CYScrollViewController *scroll = [CYScrollViewController scrollViewControllerWithConfiguration:configuration];
    scroll.delegate = self;
    scroll.dataSource = self;
    scroll.view.backgroundColor = [UIColor lightGrayColor];
    [self.navigationController pushViewController:scroll animated:true];
}

- (NSInteger)numberOfChildViewControllersInScrollViewController:(CYScrollViewController *)scrollViewController {
    return _titles2.count;
}

- (CYScrollConfigurationItem *)scrollViewController:(CYScrollViewController *)scrollViewController configurationItemAtIndex:(NSInteger)index {
    NSString *title = _titles2[index];
    CYScrollConfigurationItem *item = [CYScrollConfigurationItem new];
    item.title = title;
    UIViewController *controller = [UIViewController new];
    controller.view.backgroundColor = [UIColor whiteColor];
    UILabel *titleL = [UILabel new];
    titleL.text = title;
    int R = (arc4random() % 256) ;
    int G = (arc4random() % 256) ;
    int B = (arc4random() % 256) ;
    controller.view.backgroundColor = [UIColor whiteColor];
    titleL.textAlignment = NSTextAlignmentCenter;
    titleL.font = [UIFont systemFontOfSize:30];
    [titleL setTextColor:[UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1]];
    [controller.view addSubview:titleL];
    titleL.frame = controller.view.bounds;
    
    item.selectedTitleItemScale = 1.5;
    item.childViewController = controller;
    return item;
}

- (CGFloat)titleViewHeightForScrollViewController:(CYScrollViewController *)scrollViewController {
    return 44;
}

@end
