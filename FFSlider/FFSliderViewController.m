//
//  FFSliderViewController.m
//  FFSlider
//
//  Created by ixiazer on 16/9/12.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "FFSliderViewController.h"
#import "FFSliderModel.h"
#import "FFHomeSilderViewController.h"
#import "FFHomeSliderNavView.h"
#import "FFDetailViewController.h"

// 屏幕宽度
#define FFScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define FFScreenHeight [UIScreen mainScreen].bounds.size.height

@interface FFSliderViewController ()
@property (nonatomic, strong) FFHomeSliderNavView *sliderNavView;
@property (nonatomic, strong) FFHomeSilderViewController *homeSliderView;
@property (nonatomic, strong) NSMutableArray *homeNavArr;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation FFSliderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

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
    [self.homeSliderView initHomeSlider:self.homeNavArr homeSliderBlock:^(id vcData, NSInteger currentIndex, id data) {
        [this sliderHandle:vcData currentIndex:currentIndex];
    }];
    
    [self.homeSliderView configSlider:self.homeNavArr[0]];
    self.currentIndex = 0;
}

#pragma mark -- method
- (void)configSliderNav {
    __weak typeof(self) this = self;
    [self.sliderNavView configSliderNav:self.homeNavArr currentIndex:0 actionBlock:^(id sliderData, NSInteger currentIndex) {
        if (currentIndex != this.currentIndex) {
            this.currentIndex = currentIndex;
            [this doPageVCChange:sliderData currentIndex:currentIndex];
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

    self.homeSliderView.sliderInfoArr = self.homeNavArr;
    [self.homeSliderView configSlider:self.homeNavArr[currentIndex]];
}

#pragma mark - SliderView Config
- (void)sliderHandle:(id)vcData currentIndex:(NSInteger)currentIndex {
    FFSliderModel *navModel = (FFSliderModel *)self.homeNavArr[currentIndex];
    
    FFDetailViewController *VC = (FFDetailViewController *)vcData;
    VC.detailTitle = [NSString stringWithFormat:@"index==>>%ld",navModel.sliderIndex];
    if (currentIndex != self.currentIndex) {
        __weak typeof(self) this = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [this.sliderNavView doNavMove:currentIndex withReset:YES];
        });
    }
    self.currentIndex = currentIndex;
    
    NSLog(@"currentVCInfo---->>%@/%ld",vcData,(long)currentIndex);
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

- (FFHomeSilderViewController *)homeSliderView {
    if (!_homeSliderView) {
        _homeSliderView = [[FFHomeSilderViewController alloc] init];
        _homeSliderView.view.frame = CGRectMake(0, 64+40, FFScreenWidth, FFScreenHeight-64-40);
    }
    
    return _homeSliderView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
