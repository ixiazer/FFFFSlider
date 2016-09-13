//
//  FFHomeSliderNavView.h
//  FreshFresh
//
//  Created by ixiazer on 16/3/23.
//  Copyright © 2016年 com.freshfresh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FFHomeSliderNavView : UIView
@property (nonatomic, strong) NSArray *sliderInfoArr;
@property (nonatomic, assign) CGFloat navWidth;

- (void)configSliderNav:(NSArray *)sliderInfoArr currentIndex:(NSInteger)currentIndex actionBlock:(void(^)(id sliderData, NSInteger currentIndex))actionBlock;

- (void)doNavReset:(CGFloat)navWidth;
- (void)doNavMove:(NSInteger)index withReset:(BOOL)withReset;

@end
