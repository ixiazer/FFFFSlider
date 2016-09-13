//
//  FFPageViewController.m
//  FFSlider
//
//  Created by ixiazer on 16/9/12.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "FFPageViewController.h"

//定义屏幕高度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
//定义屏幕宽度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define navHeight 44.0

@interface FFPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger navCount;
@property (nonatomic, assign) float navWidth;
@property (nonatomic, assign) BOOL isRecycle;
@property (nonatomic, assign) BOOL isPageChangeWithAnimation;
@end

@implementation FFPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self loadPageViewController];
    [self switchToViewControllerAtIndex:0];
}

#pragma mark - method
- (void)initData {
    self.currentVCIndex = 0;
    self.viewControllerArr = [NSMutableArray array];
    self.navCount = self.navTitlesArr.count;
    self.navWidth = [self.dataSource witdhOfNav];
    self.isRecycle = [self.dataSource canPageViewControllerRecycle];
    self.isPageChangeWithAnimation = [self.dataSource canPageViewControllerAnimation];
}

- (void)loadPageViewController {
    for (NSInteger i = 0; i < self.navCount; i++) {
        UIViewController *vc = [self.dataSource viewPageController:self contentViewControllerForNavAtIndex:i];
        [self.viewControllerArr addObject:vc];
    }
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [self addChildViewController:self.pageViewController];
    
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    self.contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.contentView = self.pageViewController.view;
    [self.view addSubview:self.contentView];
}

- (void)switchToViewControllerAtIndex:(NSInteger)index {
    [self transitionToViewControllerAtIndex:index];
}

- (void)transitionToViewControllerAtIndex:(NSInteger)index {
    UIViewController *viewController = [self viewControllerAtIndex:index];
    
    if (!viewController) {
        viewController = [[UIViewController alloc] init];
        viewController.view = [[UIView alloc] init];
        viewController.view.backgroundColor = [UIColor clearColor];
    }
    
    if (index == self.currentVCIndex) {
        [self.pageViewController setViewControllers:@[viewController]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:^(BOOL finished) {
                                         }];
    } else {
        NSInteger direction = 0;
        if (index == self.viewControllerArr.count - 1 && self.currentVCIndex == 0) {
            direction = UIPageViewControllerNavigationDirectionReverse;
        } else if (index == 0 && self.currentVCIndex == self.viewControllerArr.count - 1) {
            direction = UIPageViewControllerNavigationDirectionForward;
        } else if (index < self.currentVCIndex) {
            direction = UIPageViewControllerNavigationDirectionReverse;
        } else {
            direction = UIPageViewControllerNavigationDirectionForward;
        }
        
        [self.pageViewController setViewControllers:@[viewController]
                                          direction:direction
                                           animated:self.isPageChangeWithAnimation
                                         completion:^(BOOL completed){// none
                                         }];
    }
    
    self.currentVCIndex = index;
}

- (void)getCurentIndex:(NSInteger)index{
    NSLog(@"当前是===>>第%ld页",index+1);
}

- (NSInteger)indexOfViewController:(UIViewController *)viewController {
    NSInteger index = [self.viewControllerArr indexOfObject:viewController];
    if (!index) {
        return 0;
    }
    return index;
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index {
    if (self.viewControllerArr.count == 0) {
        return nil;
    }
    UIViewController *vc = [self.viewControllerArr objectAtIndex:index];
    
    return vc;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    CGPoint point = scrollView.contentOffset;
    
    float displace = point.x+self.navWidth/2-1.0;
    NSInteger navIndex = displace / self.navWidth;
    NSLog(@"displace--->%f/%ld",displace, (long)navIndex);
    
    [self switchToViewControllerAtIndex:navIndex];
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self indexOfViewController:viewController];
    if (index == 0) {
        if (self.isRecycle) {
            index = self.navCount - 1;
        } else {
            return nil;
        }
    } else {
        index--;
    }
    
    return [self viewControllerAtIndex:index];
}

// 是否循环
- (BOOL)canPageViewControllerRecycle{
    return YES;
}
// 是否动画切换
- (BOOL)canPageViewControllerAnimation{
    return YES;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [self indexOfViewController:viewController];
    if (!index) {
        index = 0;
    }
    if (index == self.navCount - 1) {
        if (self.isRecycle) {
            index = 0;
        } else {
            return nil;
        }
    } else {
        index++;
    }
    return [self viewControllerAtIndex:index];
}


#pragma mark - UIPageViewControllerDelegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    UIViewController *viewController = self.pageViewController.viewControllers[0];
    
    NSUInteger index = [self indexOfViewController:viewController];
    
    self.currentVCIndex = index;
    [self getCurentIndex:index];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
