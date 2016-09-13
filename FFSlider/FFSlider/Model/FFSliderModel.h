//
//  FFSliderModel.h
//  FFSlider
//
//  Created by ixiazer on 15/12/22.
//  Copyright © 2015年 ixiazer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFSliderModel : NSObject
@property (nonatomic, strong) NSString *sliderTitle;
@property (nonatomic, assign) NSInteger sliderIndex;
@property (nonatomic, strong) id sliderData;
@property (nonatomic, strong) NSString *classNameStr;
@end
