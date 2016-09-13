//
//  FFSliderViewController.h
//  FFSlider
//
//  Created by ixiazer on 15/12/22.
//  Copyright © 2015年 ixiazer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FFMixSliderCachePolicy) {
    FFMixSliderCachePolicyNoLimit = 0, // 无限制
    FFMixSliderCachePolicyLowMemory = 1, // 内存过低
    FFMixSliderCachePolicyBalanced = 3, // 内存平衡状态
    FFMixSliderCachePolicyHighMemory = 5 // 内存充足
};

typedef NS_ENUM(NSInteger, FFMixSliderUIInitType) {
    FFMixSliderUIInitTypeForNormal = 1 << 0, // 初始化
    FFMixSliderUIInitTypeForForward = 1 << 1, // 向前滑动
    FFMixSliderUIInitTypeForBackward = 1 << 2, // 向后滑动
};

@interface FFMixSliderViewController : FFRootViewController
@property (nonatomic, strong) FFRootViewController *currentSingleVC; // 当前UIViewController

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) FFMixSliderCachePolicy cachePolicy; // 缓存策略

- (void)configSliderView:(NSArray *)sliderInfoArr currentIndex:(NSInteger)currentIndex vcClassNameArr:(NSArray *)vcClassNameArr parentVC:(FFRootViewController *)parentVC sliderBlock:(void(^)(id vcData, NSInteger currentIndex, id data))sliderBlock;

@end
