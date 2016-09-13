//
//  FFSliderViewController.m
//  FFSlider
//
//  Created by ixiazer on 15/12/22.
//  Copyright © 2015年 ixiazer. All rights reserved.
//

#import "FFMixSliderViewController.h"
#import "FFSliderModel.h"

// 屏幕宽度
#define FFScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define FFScreenHeight [UIScreen mainScreen].bounds.size.height


@interface FFMixSliderViewController () <UIScrollViewDelegate>
// sliderView容器
@property (nonatomic, strong) UIScrollView *sliderScrollView; // UIScrollView容器
@property (nonatomic, strong) NSMutableArray *scrollviewSliderInfoArr; // UIScrollView容器中视图的数据对象
@property (nonatomic, strong) FFSliderModel *currentSliderModel; // 当前UIViewController model
// 缓存池数据
@property (nonatomic, strong) NSCache *sliderCache; // 缓存池
// 收到内存警告的次数
@property (nonatomic, assign) NSInteger memoryWarningCount;

// sliderView 相关数据
@property (nonatomic, strong) NSArray *sliderInfoArr; // 所有导航数据，只显示其中3条数据
@property (nonatomic, strong) NSMutableArray *currentVCArr; // UIScrollView 视图数据
@property (nonatomic, assign) NSInteger currentVCIndex; // UIScrollView 视图index

// 回掉block
@property (nonatomic, copy) void(^sliderBlock)(id vcData, NSInteger currentIndex, id data); // 当UIScrollView滚动后，通知父视图
// 滚动viewcontroller class name
@property (nonatomic, assign) CGRect selfFrame;

// 父viewcontroller
@property (nonatomic, strong) UIViewController *mixSliderParentVC;


@end

@implementation FFMixSliderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self initData];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)dealloc {
    NSLog(@"FFSliderViewController---dealloc");
}

//- (void)wakeFromBackGround:(NSNotificationCenter *)notify {
//}

- (void)initData {
    self.memoryWarningCount = 0;
    self.cachePolicy = FFMixSliderCachePolicyNoLimit;
    self.sliderCache = [[NSCache alloc] init];
    self.sliderCache.countLimit = 1;
    self.scrollviewSliderInfoArr = [[NSMutableArray alloc] init];
}

- (void)configSliderView:(NSArray *)sliderInfoArr currentIndex:(NSInteger)currentIndex parentVC:(UIViewController *)parentVC sliderBlock:(void(^)(id vcData, NSInteger currentIndex, id data))sliderBlock {
    self.sliderBlock = sliderBlock;
    self.selfFrame = self.view.frame;
    self.mixSliderParentVC = parentVC;
    
    self.sliderInfoArr = [NSArray arrayWithArray:sliderInfoArr];
    self.currentSingleVC = nil;
    self.currentIndex = currentIndex;
    
    [self initUI];
}

- (void)initUI {
    __weak typeof(self) this = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![this.sliderScrollView isDescendantOfView:this.view]) {
            [this.view addSubview:this.sliderScrollView];
        }
    });

    if (self.sliderInfoArr.count > 0) {
        [self resetScrollViewCon:FFMixSliderUIInitTypeForNormal];
    }
}

- (id)getSingleVC:(NSInteger)index {
    FFSliderModel *model = (FFSliderModel *)[self.sliderInfoArr objectAtIndex:index];
    
    id singleVC;
    if (index == 0) {
        NSString *keyStr = [NSString stringWithFormat:@"mixIndex%@",@(model.sliderIndex)];
        id tempVC = [self.sliderCache objectForKey:keyStr];
        if (tempVC) {
            singleVC = tempVC;
        } else {
            Class someClass = NSClassFromString(model.classNameStr);
            singleVC = [[someClass alloc] init];
            
            NSString *elseKeyStr = [NSString stringWithFormat:@"mixIndex%@",@(model.sliderIndex)];
            [self.sliderCache setObject:singleVC forKey:elseKeyStr];
        }
    } else {
        Class someClass = NSClassFromString(model.classNameStr);
        singleVC = [[someClass alloc] init];
    }
    
    return singleVC;
}

- (void)growCachePolicyAfterMemoryWarning {
    self.cachePolicy = FFMixSliderCachePolicyBalanced;
    [self performSelector:@selector(growCachePolicyToHigh) withObject:nil afterDelay:2.0 inModes:@[NSRunLoopCommonModes]];
}

- (void)growCachePolicyToHigh {
    self.cachePolicy = FFMixSliderCachePolicyHighMemory;
}

#pragma mark - 绘制UIScrollView 的子视图
- (void)resetScrollViewCon:(FFMixSliderUIInitType)type {
    // 初始化首页滑动结构，优先主线程处理
    
    __weak typeof(self) this = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [this readyForSliderViewData:type];
    });
}

#pragma mark - 准备绘制UIScrollView 的数据
- (void)readyForSliderViewData:(FFMixSliderUIInitType)type {
    NSInteger scrollViewCurrentIndex;
    // 先删除废弃的VC
    if (type == FFMixSliderUIInitTypeForForward) {
        // 移除不显示视图
        FFSliderModel *model = (FFSliderModel *)[self.scrollviewSliderInfoArr lastObject];
        UIViewController *singleVC = (UIViewController *)[self getSingleVC:model.sliderIndex];
        [singleVC.view removeFromSuperview];
        [singleVC removeFromParentViewController];
        singleVC = nil;
        
        // 组织新的数据对象
        if (self.currentIndex <= 1) {
            // 前2页
            NSMutableArray *temArr = [NSMutableArray arrayWithArray:[self.scrollviewSliderInfoArr subarrayWithRange:NSMakeRange(0, 3)]];
            self.scrollviewSliderInfoArr = [NSMutableArray arrayWithArray:temArr];
        } else {
            // 其他
            [self.scrollviewSliderInfoArr removeLastObject];
            UIViewController *firstModel = (UIViewController *)[self.sliderInfoArr objectAtIndex:self.currentIndex-2];
            NSMutableArray *mutTemVC = [[NSMutableArray alloc] init];
            // 新的视图对象第一位
            [mutTemVC addObject:firstModel];
            // 原视图对象第二、三位
            [mutTemVC addObjectsFromArray:self.scrollviewSliderInfoArr];
            
            self.scrollviewSliderInfoArr = [NSMutableArray arrayWithArray:mutTemVC];
        }
        
        // 当前视图在所有数组中定位
        scrollViewCurrentIndex = 1;
    } else if (type == FFMixSliderUIInitTypeForBackward) {
        FFSliderModel *model = (FFSliderModel *)[self.scrollviewSliderInfoArr firstObject];
        UIViewController *singleVC = (UIViewController *)[self getSingleVC:model.sliderIndex];
        [singleVC.view removeFromSuperview];
        [singleVC removeFromParentViewController];
        singleVC = nil;
        
        // 最后2页
        if (self.currentIndex >= self.sliderInfoArr.count-2) {
            NSMutableArray *temArr = [NSMutableArray arrayWithArray:[self.sliderInfoArr subarrayWithRange:NSMakeRange(self.sliderInfoArr.count-3, 3)]];
            self.scrollviewSliderInfoArr = [NSMutableArray arrayWithArray:temArr];
        } else {
            // 其他
            NSMutableArray *temArr = [NSMutableArray arrayWithArray:[self.scrollviewSliderInfoArr subarrayWithRange:NSMakeRange(1, 2)]];
            NSMutableArray *mutTemVC = [[NSMutableArray alloc] init];
            // 新的视图对象第一、二位
            [mutTemVC addObjectsFromArray:temArr];
            // 原视图对象第三位
            FFSliderModel *lastModel = (FFSliderModel *)[self.sliderInfoArr objectAtIndex:self.currentIndex+2];
            [mutTemVC addObject:lastModel];
            self.scrollviewSliderInfoArr = [NSMutableArray arrayWithArray:mutTemVC];
        }
        
        // 当前视图在所有数组中定位
        scrollViewCurrentIndex = 1;
    } else {
        self.currentSingleVC = nil;
        if (self.sliderInfoArr.count <= 3) {
            self.scrollviewSliderInfoArr = [[NSMutableArray alloc] initWithArray:self.sliderInfoArr];
            scrollViewCurrentIndex = self.currentIndex;
            self.sliderScrollView.contentSize = CGSizeMake(FFScreenWidth*self.sliderInfoArr.count, self.view.frame.size.height);
        } else {
            self.sliderScrollView.contentSize = CGSizeMake(FFScreenWidth*3, self.view.frame.size.height);

            if (self.currentIndex <= 1) {
                self.scrollviewSliderInfoArr = [[NSMutableArray alloc] initWithArray:[self.sliderInfoArr subarrayWithRange:NSMakeRange(0, 3)]];
                scrollViewCurrentIndex = self.currentIndex;
            } else if (self.currentIndex >= self.sliderInfoArr.count-2) {
                NSInteger navIndex = 3+self.currentIndex-self.sliderInfoArr.count;
                self.scrollviewSliderInfoArr = [[NSMutableArray alloc] initWithArray:[self.sliderInfoArr subarrayWithRange:NSMakeRange(self.sliderInfoArr.count-3, 3)]];
                scrollViewCurrentIndex = navIndex;
            } else {
                self.scrollviewSliderInfoArr = [[NSMutableArray alloc] initWithArray:[self.sliderInfoArr subarrayWithRange:NSMakeRange(self.currentIndex-1, 3)]];
                scrollViewCurrentIndex = 1;
            }
        }
    }
    
    __weak typeof(self) this = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [this drawSliderView:scrollViewCurrentIndex];
    });
}

#pragma mark - 绘制UIScrollView 的视图
- (void)drawSliderView:(NSInteger)scrollViewCurrentIndex {
    if (self.currentVCArr.count > 0) {
        for (NSInteger i = 0; i < self.currentVCArr.count; i++) {
            UIViewController *vc = (UIViewController *)self.currentVCArr[i];
            [vc.view removeFromSuperview];
            vc = nil;
        }
    }
    
    self.currentVCArr = [NSMutableArray new];
    self.currentVCIndex = scrollViewCurrentIndex;

    for (NSInteger i = 0; i < self.scrollviewSliderInfoArr.count; i++) {
        FFSliderModel *model = (FFSliderModel *)self.scrollviewSliderInfoArr[i];
        UIViewController *singleVC = (UIViewController *)[self getSingleVC:model.sliderIndex];
        singleVC.view.frame = CGRectMake(FFScreenWidth*i, 0, FFScreenWidth, self.selfFrame.size.height);
        
        [self.currentVCArr addObject:singleVC];
        NSLog(@"singleVC.view.frame--->>%.2f",singleVC.view.frame.size.height);
        [self.sliderScrollView addSubview:singleVC.view];
        
        if (i == scrollViewCurrentIndex) {
            self.currentSingleVC = singleVC;
            self.currentSliderModel = model;
//            singleVC.parentVC = self.mixSliderParentVC;
        } else {
//            singleVC.parentVC = nil;
        }
    }
    
    [self.sliderScrollView setContentOffset:CGPointMake(FFScreenWidth*scrollViewCurrentIndex, 0)];
    self.currentIndex = self.currentSliderModel.sliderIndex;
}

#pragma mark - set method
- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    
    if (self.sliderBlock && self.currentSingleVC) {
        self.sliderBlock(self.currentSingleVC, currentIndex, self.sliderInfoArr[_currentIndex]);
    }
}

- (void)setCachePolicy:(FFMixSliderCachePolicy)cachePolicy {
    _cachePolicy = cachePolicy;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"didReceiveMemoryWarning---->>内存紧张");
    
    self.memoryWarningCount++;
    self.cachePolicy = FFMixSliderCachePolicyLowMemory;
    
    // 取消正在增长的 cache 操作
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(growCachePolicyAfterMemoryWarning) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(growCachePolicyToHigh) object:nil];
    
    [self.sliderCache removeAllObjects];
    self.currentSingleVC = nil;
    
    // 如果收到内存警告次数小于 3，一段时间后切换到模式 Balanced
    if (self.memoryWarningCount < 3) {
        [self performSelector:@selector(growCachePolicyAfterMemoryWarning) withObject:nil afterDelay:3.0 inModes:@[NSRunLoopCommonModes]];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    // scrollView 位置
    NSInteger scrollViewIndex = offsetX/FFScreenWidth;

    FFSliderModel *model = (FFSliderModel *)[self.scrollviewSliderInfoArr firstObject];
    if (scrollViewIndex == 0 && model.sliderIndex == 0) {
        return;
    }
    
    if (self.sliderInfoArr.count <= 3) {
        self.currentSingleVC = nil;
        self.currentIndex = scrollViewIndex;
        [self resetScrollViewCon:FFMixSliderUIInitTypeForNormal];
    } else {
        if (self.currentIndex == 0 || (self.currentIndex == 1 && scrollViewIndex == 0)) {
            // 前3页
            self.currentSingleVC = nil;
            self.currentIndex = scrollViewIndex;
            [self resetScrollViewCon:FFMixSliderUIInitTypeForNormal];
        } else if (self.currentIndex == self.sliderInfoArr.count-2 && scrollViewIndex == 2) {
            // 倒数第2页,且朝后翻
            self.currentSingleVC = nil;
            self.currentIndex += 1;
            [self resetScrollViewCon:FFMixSliderUIInitTypeForNormal];
        } else if (self.currentIndex == self.sliderInfoArr.count-1 && scrollViewIndex == 2) {
            self.currentSingleVC = nil;
            self.currentIndex = self.currentSliderModel.sliderIndex;
            [self resetScrollViewCon:FFMixSliderUIInitTypeForNormal];
        } else {
            if (scrollViewIndex == 0) {
                [self resetScrollViewCon:FFMixSliderUIInitTypeForForward];
            } else if (scrollViewIndex == 2) {
                [self resetScrollViewCon:FFMixSliderUIInitTypeForBackward];
            } else {
                if (self.currentIndex == self.sliderInfoArr.count - 1 && scrollViewIndex == 1) {
                    self.currentSingleVC = nil;
                    self.currentIndex -= 1;
                    [self resetScrollViewCon:FFMixSliderUIInitTypeForNormal];
                }
            }
        }
    }
}

#pragma mark - get method
- (UIScrollView *)sliderScrollView {
    if (!_sliderScrollView) {
        _sliderScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, FFScreenWidth, self.view.frame.size.height)];
        _sliderScrollView.backgroundColor = [UIColor whiteColor];
        _sliderScrollView.delegate = self;
        _sliderScrollView.pagingEnabled = YES;
        _sliderScrollView.showsHorizontalScrollIndicator = NO;
        _sliderScrollView.showsVerticalScrollIndicator = NO;
        _sliderScrollView.contentSize = CGSizeMake(FFScreenWidth*3, self.view.frame.size.height);
    }
    return _sliderScrollView;
}


@end
