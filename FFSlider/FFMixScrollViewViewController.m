//
//  FFMixScrollViewViewController.m
//  FFSlider
//
//  Created by ixiazer on 16/9/13.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "FFMixScrollViewViewController.h"
#import "FFHomeSliderNavView.h"
#import "FFMixSliderViewController.h"
#import "FFSliderModel.h"
#import "FFDetailViewController.h"

// 屏幕宽度
#define FFScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define FFScreenHeight [UIScreen mainScreen].bounds.size.height


@interface FFMixScrollViewViewController ()
@property (nonatomic, strong) FFHomeSliderNavView *sliderNavView;
@property (nonatomic, strong) FFMixSliderViewController *homeSliderView;
@property (nonatomic, strong) NSMutableArray *homeNavArr;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation FFMixScrollViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"Mix-UIScrollView";
    
    self.homeNavArr = [NSMutableArray new];
    for (NSInteger i = 0; i < 10; i++) {
        FFSliderModel *navMode = [[FFSliderModel alloc] init];
        navMode.sliderIndex = i;
        navMode.sliderTitle = [NSString stringWithFormat:@"menu%ld",(long)navMode.sliderIndex];
        navMode.classNameStr = @"FFDetailViewController";
        
        [self.homeNavArr addObject:navMode];
    }
    
    [self initSliderView];
}

- (void)initSliderView {
    [self.view addSubview:self.sliderNavView];
    
    [self configSliderNav];
    [self configSliderVC];
}

#pragma mark - SliderView Config
- (void)configSliderVC {
    if (![self.homeSliderView.view isDescendantOfView:self.view]) {
        [self.view addSubview:self.homeSliderView.view];
    }

    __weak typeof(self) this = self;
    [self.homeSliderView configSliderView:self.homeNavArr currentIndex:0 parentVC:self sliderBlock:^(id vcData, NSInteger currentIndex, id data) {
        [this currentVCReload:vcData currentIndex:currentIndex data:data];
        
        this.currentIndex = currentIndex;
        [this doPageVCChange:data currentIndex:currentIndex];
    }];
    
    self.currentIndex = 0;
}

- (void)currentVCReload:(id)vcData currentIndex:(NSInteger)currentIndex data:(id)data {
    FFDetailViewController *vc = (FFDetailViewController *)vcData;
    FFSliderModel *model = (FFSliderModel *)data;
    vc.detailTitle = [NSString stringWithFormat:@"index==>>%ld",model.sliderIndex];
}

#pragma mark -- method
- (void)configSliderNav {
    __weak typeof(self) this = self;
    [self.sliderNavView configSliderNav:self.homeNavArr currentIndex:0 actionBlock:^(id sliderData, NSInteger currentIndex) {
        if (currentIndex != this.currentIndex) {
            this.currentIndex = currentIndex;
            [this doPageVCChange:sliderData currentIndex:currentIndex];
            [this doSliderVCReset:currentIndex];
        }
    }];
}

- (void)doPageVCChange:(id)sliderData currentIndex:(NSInteger)currentIndex {
    if (self.homeNavArr.count == 0 || self.sliderNavView.sliderInfoArr.count == 0) {
        return;
    }
    
    if (currentIndex >= self.homeNavArr.count) {
        return;
    }
    self.currentIndex = currentIndex;
    
    [self.sliderNavView doNavMove:currentIndex withReset:YES];
}

- (void)doSliderVCReset:(NSInteger)index {
    self.currentIndex = index;
    
    __weak typeof(self) this = self;
    [self.homeSliderView configSliderView:self.homeNavArr currentIndex:index parentVC:self sliderBlock:^(id vcData, NSInteger currentIndex, id data) {
        [this currentVCReload:vcData currentIndex:currentIndex data:data];
    }];
}

#pragma mark -- get method
- (FFHomeSliderNavView *)sliderNavView {
    if (!_sliderNavView) {
        _sliderNavView = [[FFHomeSliderNavView alloc] initWithFrame:CGRectMake(0, 64, FFScreenWidth, 40)];
        _sliderNavView.navWidth = FFScreenWidth;
        _sliderNavView.backgroundColor = [UIColor whiteColor];
    }
    
    return _sliderNavView;
}

- (FFMixSliderViewController *)homeSliderView {
    if (!_homeSliderView) {
        _homeSliderView = [[FFMixSliderViewController alloc] init];
        _homeSliderView.view.frame = CGRectMake(0, 64+40, FFScreenWidth, FFScreenHeight-64-40);
    }
    
    return _homeSliderView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
