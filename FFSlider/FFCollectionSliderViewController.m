//
//  FFCollectionSliderViewController.m
//  FFSlider
//
//  Created by ixiazer on 16/8/26.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "FFCollectionSliderViewController.h"
#import "FFHomeSliderNavView.h"
#import "FFHomeCollectionView.h"
#import "FFSliderModel.h"

// 屏幕宽度
#define FFScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define FFScreenHeight [UIScreen mainScreen].bounds.size.height

@interface FFCollectionSliderViewController ()
@property (nonatomic, strong) FFHomeSliderNavView *sliderNavView;
@property (nonatomic, strong) FFHomeCollectionView *homeSliderView;
@property (nonatomic, strong) NSMutableArray *homeNavArr;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation FFCollectionSliderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Collection slider";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.homeNavArr = [NSMutableArray new];
    for (NSInteger i = 0; i < 10; i++) {
        FFSliderModel *navMode = [[FFSliderModel alloc] init];
        navMode.sliderIndex = i;
        navMode.sliderTitle = [NSString stringWithFormat:@"menu%ld",(long)navMode.sliderIndex];
        navMode.classNameStr = @"FFDetailViewController";
        
        [self.homeNavArr addObject:navMode];
    }
    
    [self.view addSubview:self.sliderNavView];
    [self addChildViewController:self.homeSliderView];

    [self configSliderNav];
    [self configSliderVC];
}

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
- (void)configSliderVC {
    if (![self.homeSliderView.view isDescendantOfView:self.view]) {
        [self.view addSubview:self.homeSliderView.view];
    }
    
    __weak typeof(self) this = self;
    [self.homeSliderView initHomeSlider:self.homeNavArr homeCollectionBlock:^(id vcData, NSInteger currentIndex, id data) {
        [this sliderHandle:vcData currentIndex:currentIndex];
    }];

    self.currentIndex = 0;
}

- (void)sliderHandle:(id)vcData currentIndex:(NSInteger)currentIndex {
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

- (FFHomeCollectionView *)homeSliderView {
    if (!_homeSliderView) {
        _homeSliderView = [[FFHomeCollectionView alloc] init];
        _homeSliderView.view.frame = CGRectMake(0, 64+40, FFScreenWidth, FFScreenHeight-64-40);
    }
    return _homeSliderView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
