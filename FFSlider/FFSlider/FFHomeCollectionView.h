//
//  FFHomeCollectionView.h
//  FreshFresh
//
//  Created by ixiazer on 16/5/29.
//  Copyright © 2016年 com.freshfresh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFSliderModel.h"

@interface FFHomeCollectionView : UIViewController
@property (nonatomic, strong) NSArray *sliderInfoArr;

- (void)initHomeSlider:(NSArray *)sliderInfos homeCollectionBlock:(void(^)(id vcData, NSInteger currentIndex, id data))homeCollectionBlock;
- (void)configSlider:(FFSliderModel *)homeNavModel;


@end
