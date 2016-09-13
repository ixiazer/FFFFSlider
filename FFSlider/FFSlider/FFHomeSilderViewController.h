//
//  FFHomeSilderViewController.h
//  FreshFresh
//
//  Created by ixiazer on 16/5/25.
//  Copyright © 2016年 com.freshfresh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFSliderModel.h"

@interface FFHomeSilderViewController : UIViewController

@property (nonatomic, strong) NSArray *sliderInfoArr; // 所有导航数据，只显示其中3条数据
// sliderView容器
@property (nonatomic, strong) UIScrollView *sliderScrollView; // UIScrollView容器

- (void)initHomeSlider:(NSArray *)sliderInfos homeSliderBlock:(void(^)(id vcData, NSInteger currentIndex, id data))homeSliderBlock;
- (void)configSlider:(FFSliderModel *)homeNavModel;

- (id)getCurrentVC:(NSInteger)index;
- (id)getSingleVC:(NSInteger)index;

@end
