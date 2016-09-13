//
//  FFHomeCollectionView.m
//  FreshFresh
//
//  Created by ixiazer on 16/5/29.
//  Copyright © 2016年 com.freshfresh. All rights reserved.
//

#import "FFHomeCollectionView.h"
#import "FFDetailViewController.h"

// 屏幕宽度
#define FFScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define FFScreenHeight [UIScreen mainScreen].bounds.size.height


@interface FFHomeCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *homeCollecionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableDictionary *sliderCacheDic;

// sliderView 相关数据
@property (nonatomic, strong) FFSliderModel *currentSliderModel; // 当前UIViewController model

// 回掉block
@property (nonatomic, copy) void(^homeCollectionBlock)(id vcData, NSInteger currentIndex, id data); // 当UIScrollView滚动后，通知父视图

@end

@implementation FFHomeCollectionView

- (instancetype)init {
    if (self = [super init]) {
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.flowLayout.itemSize = CGSizeMake(FFScreenWidth, self.view.frame.size.height);
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.flowLayout.minimumLineSpacing = 0;
        self.flowLayout.minimumInteritemSpacing = 0;
        
        //设置collectionView的属性
        self.homeCollecionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
        self.homeCollecionView.frame = CGRectMake(0, 0, FFScreenWidth, self.view.frame.size.height);
        self.homeCollecionView.scrollsToTop = NO;
        self.homeCollecionView.pagingEnabled = YES;
        [self.homeCollecionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"homecell"];
        self.homeCollecionView.delegate = self;
        self.homeCollecionView.dataSource = self;
        self.homeCollecionView.backgroundColor = [UIColor whiteColor];
        self.homeCollecionView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:self.homeCollecionView];
        
    }
    return self;
}

#pragma mark -- method
- (void)initHomeSlider:(NSArray *)sliderInfos homeCollectionBlock:(void(^)(id vcData, NSInteger currentIndex, id data))homeCollectionBlock {
    self.sliderInfoArr = [NSArray arrayWithArray:sliderInfos];
    self.homeCollectionBlock = homeCollectionBlock;
    
    [self.homeCollecionView reloadData];
}
- (void)configSlider:(FFSliderModel *)homeNavModel {
    if (homeNavModel.sliderIndex == self.currentSliderModel.sliderIndex) {
        self.currentSliderModel = homeNavModel;
        
        FFDetailViewController *baseView = [self getSingleVC:homeNavModel.sliderIndex];
        [self configVCRequest:homeNavModel.sliderIndex vc:baseView];
        
        return;
    }
    
    self.currentSliderModel = homeNavModel;
    CGFloat offsetX = self.view.bounds.size.width * self.currentSliderModel.sliderIndex;
    self.homeCollecionView.contentOffset = CGPointMake(offsetX, 0);
}

- (void)configVCRequest:(NSInteger)index vc:(FFDetailViewController *)vc {
    [vc setDetailTitle:[NSString stringWithFormat:@"collection--%ld",(long)index]];
}

#pragma mark -- get method
- (id)getSingleVC:(NSInteger)index {
    if (index > self.sliderInfoArr.count-1) {
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
    }
    
    return singleVC;
}


#pragma mark - collectionView datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sliderInfoArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"homecell" forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    FFDetailViewController *baseView = [self getSingleVC:indexPath.item];
    [cell.contentView addSubview:baseView.view];
    baseView.view.frame = cell.bounds;
    
    [self configVCRequest:indexPath.item vc:baseView];

    return cell;
}

#pragma mark - collectionView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x/self.view.bounds.size.width;
    if (index == self.currentSliderModel.sliderIndex) {
        return;
    }
    
    self.currentSliderModel = self.sliderInfoArr[index];
    if (self.homeCollectionBlock) {
        self.homeCollectionBlock([self getSingleVC:self.currentSliderModel.sliderIndex], self.currentSliderModel.sliderIndex, self.currentSliderModel);
    }
}

#pragma mark -- get method
- (NSMutableDictionary *)sliderCacheDic {
    if (!_sliderCacheDic) {
        _sliderCacheDic = [NSMutableDictionary new];
    }
    return _sliderCacheDic;
}
- (NSArray *)sliderInfoArr {
    if (!_sliderInfoArr) {
        _sliderInfoArr = [[NSArray alloc] init];
    }
    
    return _sliderInfoArr;
}


@end
