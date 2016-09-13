//
//  FFPageHomeViewController.m
//  FFSlider
//
//  Created by ixiazer on 16/9/12.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "FFPageHomeViewController.h"
#import "FFDetailViewController.h"

@interface FFPageHomeViewController () <XZPageViewControllerDelegate,XZPageViewControllerDataSource>
@end

@implementation FFPageHomeViewController

-(instancetype)init{
    if (self = [super init]) {
        self.delegate = self;
        self.dataSource = self;
        self.navTitlesArr = [NSMutableArray arrayWithArray:@[@"page1",@"page2",@"page3",@"page4"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.view.backgroundColor = [UIColor whiteColor];
    [self switchToViewControllerAtIndex:0];
}

- (BOOL)canPageViewControllerRecycle {
    return NO;
}

- (BOOL)canPageViewControllerAnimation {
    return NO;
}

- (float)witdhOfNav {
    return 60.0;
}

- (NSString *)titleOfNavAtIndex:(NSInteger)index {
    return @"sucess";
}

-(NSInteger)numOfPages{
    return self.navTitlesArr.count;
}

- (UIViewController *)viewPageController:(FFPageViewController *)pageViewController contentViewControllerForNavAtIndex:(NSInteger)index {
    FFDetailViewController *detailVC = [[FFDetailViewController alloc] init];
    detailVC.detailTitle = [NSString stringWithFormat:@"page==>>%ld",index+1];
    
    return detailVC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
