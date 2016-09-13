//
//  FFSliderViewController.h
//  FFSlider
//
//  Created by ixiazer on 15/12/22.
//  Copyright © 2015年 ixiazer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FFSliderCachePolicy) {
    FFSliderCachePolicyNoLimit = 0, // 无限制
    FFSliderCachePolicyLowMemory = 1, // 内存过低
    FFSliderCachePolicyBalanced = 3, // 内存平衡状态
    FFSliderCachePolicyHighMemory = 5 // 内存充足
};

typedef NS_ENUM(NSInteger, FFSliderUIInitType) {
    FFSliderUIInitTypeForNormal = 1 << 0, // 初始化
    FFSliderUIInitTypeForForward = 1 << 1, // 向前滑动
    FFSliderUIInitTypeForBackward = 1 << 2, // 向后滑动
};

@interface FFSliderViewController : FFRootViewController
@property (nonatomic, strong) FFRootViewController *currentSingleVC; // 当前UIViewController

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) FFSliderCachePolicy cachePolicy; // 缓存策略

- (void)configSliderView:(NSArray *)sliderInfoArr currentIndex:(NSInteger)currentIndex vcClassName:(NSString *)vcClassName sliderBlock:(void(^)(id vcData, NSInteger currentIndex, id data))sliderBlock;

@end
