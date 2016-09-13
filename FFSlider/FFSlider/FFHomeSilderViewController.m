//
//  FFHomeSilderViewController.m
//  FreshFresh
//
//  Created by ixiazer on 16/5/25.
//  Copyright © 2016年 com.freshfresh. All rights reserved.
//

#import "FFHomeSilderViewController.h"
#import "FFDetailViewController.h"

// 屏幕宽度
#define FFScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define FFScreenHeight [UIScreen mainScreen].bounds.size.height


@interface FFHomeSilderViewController () <UIScrollViewDelegate>
// 缓存池数据
@property (nonatomic, strong) NSMutableDictionary *sliderCacheDic; // 缓存池dic

// 收到内存警告的次数

// sliderView 相关数据
@property (nonatomic, strong) FFSliderModel *formerSliderModel; // 上次 model
@property (nonatomic, strong) FFSliderModel *currentSliderModel; // 当前UIViewController model

// 回掉block
@property (nonatomic, copy) void(^homeSliderBlock)(id vcData, NSInteger currentIndex, id data); // 当UIScrollView滚动后，通知父视图

@property (nonatomic, assign) NSInteger scrollViewBeginCount;
@end

@implementation FFHomeSilderViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    [self.view addSubview:self.sliderScrollView];
}

#pragma mark -- method
- (void)initHomeSlider:(NSArray *)sliderInfos homeSliderBlock:(void(^)(id vcData, NSInteger currentIndex, id data))homeSliderBlock {
    self.sliderInfoArr = sliderInfos;
    self.homeSliderBlock = homeSliderBlock;
    self.sliderScrollView.contentSize = CGSizeMake(FFScreenWidth*self.sliderInfoArr.count, FFScreenHeight);
}

- (void)configSlider:(FFSliderModel *)homeNavModel {
    self.currentSliderModel = homeNavModel;
    
    [self resetHomeSliderView];
}

- (void)resetHomeSliderView {
/*
 新逻辑，采用最基本方式，所有视图只有加载出来，就全部显示
 */

//    NSArray *willShowPageArr = [self getShowPageIndexArr:self.currentSliderModel.sliderIndex];
//    
//    // 新增视图
//    if (willShowPageArr.count > 0) {
//        for (NSString *str in willShowPageArr) {
//            FFRootViewController *vc = [self getSingleVC:[str integerValue]];
//            if (!vc) {
//                return;
//            }
//        }
//    }
//    
//    if (willShowPageArr.count > 0) {
//        for (NSInteger i = 0; i < willShowPageArr.count; i++) {
//            FFRootViewController *vc = [self getSingleVC:[willShowPageArr[i] integerValue]];
//            if (!vc) {
//                return;
//            }
//            [self configVCRequest:[willShowPageArr[i] integerValue] vc:vc];
//        }
//    }
//    
//    [self.sliderScrollView setContentOffset:CGPointMake(self.currentSliderModel.sliderIndex*FFScreenWidth, 0) animated:YES];
//    self.formerSliderModel = self.currentSliderModel;

/*
 原来逻辑，保证首页视图上最多显示3个viewcontroller，视图addsubview也会暂用系统内存，最大化减少内存占用
 */
    
    // 首页scrollview选择性加载选中对象附近的视图
    NSArray *willDeletePageIndexArr = [self getWillDeletePageIndexArr];
    NSArray *willAddPageIndexArr = [self getWillAddPageIndexArr];
    NSArray *willRetainageIndexArr = [self getWillRetainPageIndexArr];
    
    NSLog(@"delete/add/retain===>>%@/%@/%@",willDeletePageIndexArr,willAddPageIndexArr,willRetainageIndexArr);
    
    // 删除视图
    if (willDeletePageIndexArr.count > 0) {
        for (NSString *str in willDeletePageIndexArr) {
            [self removeCacheVC:[str integerValue]];
        }
    }
    
    // 新增视图
    if (willAddPageIndexArr.count > 0) {
        for (NSString *str in willAddPageIndexArr) {
            UIViewController *vc = [self getSingleVC:[str integerValue]];
            if (!vc) {
                return;
            }
            vc.view.frame = CGRectMake(FFScreenWidth*[str integerValue], 0, FFScreenWidth, FFScreenHeight);
            [self.sliderScrollView addSubview:vc.view];
        }
    }
    
    NSMutableArray *allShowView = [NSMutableArray arrayWithArray:willAddPageIndexArr];
    [allShowView addObjectsFromArray:willRetainageIndexArr];
    
    if (allShowView.count > 0) {
        for (NSInteger i = 0; i < allShowView.count; i++) {
            UIViewController *vc = [self getSingleVC:[allShowView[i] integerValue]];
            if (!vc) {
                return;
            }
            [self configVCRequest:[allShowView[i] integerValue] vc:vc];
        }
    }

    [self.sliderScrollView setContentOffset:CGPointMake(self.currentSliderModel.sliderIndex*FFScreenWidth, 0) animated:YES];
    self.formerSliderModel = self.currentSliderModel;
}

- (void)configVCRequest:(NSInteger)index vc:(UIViewController *)vc {
    FFDetailViewController *recommendVC = (FFDetailViewController *)vc;
}

- (NSArray *)getWillAddPageIndexArr {
    NSArray *formerIndexArr = [NSArray new];
    if (self.formerSliderModel) {
        formerIndexArr = [self getShowPageIndexArr:self.formerSliderModel.sliderIndex];
    }

    NSArray *currentIndexArr = [self getShowPageIndexArr:self.currentSliderModel.sliderIndex];
    // 获取将添加视图数组
    NSMutableArray *willAddArr = [NSMutableArray new];
    for (NSInteger i = 0; i < currentIndexArr.count; i++) {
        NSInteger currentIndex = [currentIndexArr[i] integerValue];
        BOOL isWillAdd = YES;
        for (NSInteger j = 0; j < formerIndexArr.count; j++) {
            NSInteger formerIndex = [formerIndexArr[j] integerValue];
            
            if (formerIndex == currentIndex) {
                isWillAdd = NO;
                break;
            }
        }
        
        if (isWillAdd) {
            [willAddArr addObject:@(currentIndex)];
        }
    }
    
    return willAddArr;
}

- (NSArray *)getWillDeletePageIndexArr {
    NSArray *formerIndexArr = [NSArray new];
    if (self.formerSliderModel) {
        formerIndexArr = [self getShowPageIndexArr:self.formerSliderModel.sliderIndex];
    }
    if (formerIndexArr.count == 0) {
        return nil;
    }

    NSArray *currentIndexArr = [self getShowPageIndexArr:self.currentSliderModel.sliderIndex];
    
    // 获取将删除视图数组
    NSMutableArray *willDeleteArr = [NSMutableArray new];
    for (NSInteger i = 0; i < formerIndexArr.count; i++) {
        NSInteger formerIndex = [formerIndexArr[i] integerValue];
        BOOL isWillDelete = YES;
        for (NSInteger j = 0; j < currentIndexArr.count; j++) {
            NSInteger currentIndex = [currentIndexArr[j] integerValue];
            
            if (formerIndex == currentIndex) {
                isWillDelete = NO;
                break;
            }
        }
        
        if (isWillDelete) {
            [willDeleteArr addObject:@(formerIndex)];
        }
    }
    
    return willDeleteArr;
}

- (NSArray *)getWillRetainPageIndexArr {
    NSArray *formerIndexArr = [NSArray new];
    if (self.formerSliderModel) {
        formerIndexArr = [self getShowPageIndexArr:self.formerSliderModel.sliderIndex];
    }
    if (formerIndexArr.count == 0) {
        return nil;
    }
    
    NSArray *currentIndexArr = [self getShowPageIndexArr:self.currentSliderModel.sliderIndex];
    
    // 获取将删除视图数组
    NSMutableArray *willRetainArr = [NSMutableArray new];
    for (NSInteger i = 0; i < formerIndexArr.count; i++) {
        NSInteger formerIndex = [formerIndexArr[i] integerValue];
        BOOL isWillRetain = NO;
        for (NSInteger j = 0; j < currentIndexArr.count; j++) {
            NSInteger currentIndex = [currentIndexArr[j] integerValue];
            
            if (formerIndex == currentIndex) {
                isWillRetain = YES;
                break;
            }
        }
        
        if (isWillRetain) {
            [willRetainArr addObject:@(formerIndex)];
        }
    }
    
    return willRetainArr;
}


- (void)setFormerSliderModel:(FFSliderModel *)formerSliderModel {
    _formerSliderModel = formerSliderModel;
    
    if (self.homeSliderBlock) {
        self.homeSliderBlock([self getSingleVC:formerSliderModel.sliderIndex], formerSliderModel.sliderIndex, formerSliderModel);
    }
}


- (id)getCurrentVC:(NSInteger)index {
    NSString *keyStr = [NSString stringWithFormat:@"mixIndex%@",@(index)];
    id tempVC = [self.sliderCacheDic objectForKey:keyStr];

    return tempVC;
}


#pragma mark -- UIScrollViewDelegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.sliderScrollView.scrollEnabled = YES;
    CGFloat offsetX = scrollView.contentOffset.x;
    // scrollView 位置
    NSInteger scrollViewIndex = offsetX/FFScreenWidth;
    
    [self configSlider:self.sliderInfoArr[scrollViewIndex]];
    self.scrollViewBeginCount = 0;
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return NO;
}

#pragma mark -- get method
- (id)getSingleVC:(NSInteger)index {
    if (index > self.sliderInfoArr.count-1 || self.sliderInfoArr.count == 0) {
        return nil;
    }
    FFSliderModel *model = (FFSliderModel *)[self.sliderInfoArr objectAtIndex:index];
    
    id singleVC;
    NSString *keyStr = [NSString stringWithFormat:@"mixIndex%@",@(model.sliderIndex)];
    id tempVC = [self.sliderCacheDic objectForKey:keyStr];
    if (tempVC) {
        singleVC = tempVC;
    } else {
        Class someClass = NSClassFromString(model.classNameStr);
        singleVC = [[someClass alloc] init];
        
        NSString *elseKeyStr = [NSString stringWithFormat:@"mixIndex%@",@(model.sliderIndex)];
        [self.sliderCacheDic setObject:singleVC forKey:elseKeyStr];
        
//        FFRootViewController *vc = (FFRootViewController *)singleVC;
//        vc.view.frame = CGRectMake(FFScreenWidth*index, 0, FFScreenWidth, FFScreenHeight);
//        [self.sliderScrollView addSubview:vc.view];
    }
    
//    FFLog(@"sliderCacheDic==>%@",_sliderCacheDic);
    
    return singleVC;
}

- (id)getExistSingleVC:(NSInteger)index {
    FFSliderModel *model = (FFSliderModel *)[self.sliderInfoArr objectAtIndex:index];

    id singleVC;
    NSString *keyStr = [NSString stringWithFormat:@"mixIndex%@",@(model.sliderIndex)];
    singleVC = [self.sliderCacheDic objectForKey:keyStr];

    return singleVC;
}

- (BOOL)removeCacheVC:(NSInteger)index {
    FFSliderModel *model;
    if (index >= self.sliderInfoArr.count) {
        return YES;
    }
    
    model = (FFSliderModel *)[self.sliderInfoArr objectAtIndex:index];
    NSString *keyStr = [NSString stringWithFormat:@"mixIndex%@",@(model.sliderIndex)];
    
    // 移除缓存并移除视图
    UIViewController *vc = (UIViewController *)[self getExistSingleVC:index];
    if (vc) {
        [vc.view removeFromSuperview];
        vc = nil;
    }
    [self.sliderCacheDic removeObjectForKey:keyStr];
    
    return YES;
}



- (NSArray *)getShowPageIndexArr:(NSInteger)index {
    if (self.sliderInfoArr.count <= 2) {
        return @[@(0),@(1)];
    } else {
        if (index < 1) {
            return @[@(0),@(1)];
        } else if (index == self.sliderInfoArr.count-1) {
            return @[@(index-1),@(index)];
        } else {
            return @[@(index-1),@(index),@(index+1)];
        }
    }
}

#pragma mark -- get method
- (NSArray *)sliderInfoArr {
    if (!_sliderInfoArr) {
        _sliderInfoArr = [[NSArray alloc] init];
    }
    
    return _sliderInfoArr;
}

- (UIScrollView *)sliderScrollView {
    if (!_sliderScrollView) {
        _sliderScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,FFScreenWidth, FFScreenHeight)];
        _sliderScrollView.backgroundColor = [UIColor clearColor];
        _sliderScrollView.delegate = self;
        _sliderScrollView.pagingEnabled = YES;
        _sliderScrollView.showsHorizontalScrollIndicator = NO;
        _sliderScrollView.showsVerticalScrollIndicator = NO;
    }
    return _sliderScrollView;
}

- (NSMutableDictionary *)sliderCacheDic {
    if (!_sliderCacheDic) {
        _sliderCacheDic = [NSMutableDictionary new];
    }
    return _sliderCacheDic;
}

@end
