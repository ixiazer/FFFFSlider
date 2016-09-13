//
//  FFHomeSliderNavView.m
//  FreshFresh
//
//  Created by ixiazer on 16/3/23.
//  Copyright © 2016年 com.freshfresh. All rights reserved.
//

#import "FFHomeSliderNavView.h"
#import "FFSliderModel.h"
#import <Foundation/Foundation.h>

// 屏幕宽度
#define FFScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define FFScreenHeight [UIScreen mainScreen].bounds.size.height


@interface FFHomeSliderNavView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, copy) void(^actionBlock)(id sliderData, NSInteger currentIndex);
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIView *bottonLineView;
@end

@implementation FFHomeSliderNavView

- (instancetype)initWithFrame:(CGRect)frame {
    self =  [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.scrollView];
    }

    return self;
}

- (void)configSliderNav:(NSArray *)sliderInfoArr currentIndex:(NSInteger)currentIndex actionBlock:(void(^)(id sliderData, NSInteger currentIndex))actionBlock {
    self.actionBlock = actionBlock;
    
    self.sliderInfoArr = sliderInfoArr;
    self.currentIndex = currentIndex;
    
    [self configNavView:currentIndex];
}

- (void)doNavReset:(CGFloat)navWidth {
    CGRect navFrame = self.scrollView.frame;
    if (navFrame.size.width != navWidth) {
        self.navWidth = navWidth;
        navFrame.size.width = navWidth;
        self.scrollView.frame = navFrame;
        
        [self doNavMove:self.currentIndex withReset:NO];
    }
}

#pragma mark - Draw UI
- (void)configNavView:(NSInteger)index {
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    [self.bottonLineView removeFromSuperview];
    [self.buttons removeAllObjects];
    self.buttons = nil;
    
    if (self.sliderInfoArr.count > 0) {
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.bottonLineView];

        for (NSInteger i = 0; i < self.sliderInfoArr.count; i++) {
            FFSliderModel *navModel = (FFSliderModel *)self.sliderInfoArr[i];
            
            UIButton *navButton = [UIButton buttonWithType:UIButtonTypeCustom];
            navButton.frame = CGRectMake([self getNavLeft:i], 0, [self getNavWidth:i], 40);
            [navButton setTitle:navModel.sliderTitle forState:UIControlStateNormal];
            navButton.titleLabel.font = [UIFont systemFontOfSize:18];
            if (i == index) {
                [navButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            } else {
                [navButton setTitleColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6] forState:UIControlStateNormal];
            }
            navButton.tag = i;
            navButton.backgroundColor = [UIColor clearColor];
            [navButton addTarget:self action:@selector(navClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:navButton];
            
            [self.buttons addObject:navButton];
        }
        
        if ([self getAllNavWidth] > FFScreenWidth) {
            self.scrollView.contentSize = CGSizeMake([self getAllNavWidth], 40);
        } else {
            self.scrollView.contentSize = CGSizeMake(FFScreenWidth+1, 40);
        }
    }
}

- (void)bottonLineMove:(NSInteger)index {
    CGFloat bottonLineWidth = [self getNavWidth:index]-20+8;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.bottonLineView.frame = CGRectMake([self getNavLeft:index]+10-4, 40-8, bottonLineWidth, 2.0);
    } completion:^(BOOL finished) {
    }];
}

- (void)scrollContentMove:(NSInteger)index {
    CGPoint point;
    CGFloat navCenter = [self getNavLeft:index]+[self getNavWidth:index]/2;
    if (navCenter > self.navWidth/2) {
        CGFloat navLeft = [self getAllNavWidth]-self.navWidth/2;
        if (navCenter < navLeft) {
            point = CGPointMake(navCenter-self.navWidth/2, 0);
        } else {
            point = CGPointMake([self getAllNavWidth]-self.navWidth, 0);
        }
    } else {
        point = CGPointMake(0, 0);
    }
    [self.scrollView setContentOffset:point animated:YES];
}

#pragma mark - method
- (void)navClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    
    self.currentIndex = tag;
    self.actionBlock(self.sliderInfoArr[tag], tag);
}

- (void)doNavMove:(NSInteger)index withReset:(BOOL)withReset {
    self.currentIndex = index;
    if (withReset) {
        [self navBtnColorReset:index];
    }
    
    [self scrollContentMove:index];
    [self bottonLineMove:index];
}

- (void)navBtnColorReset:(NSInteger)index {
    for (NSInteger i = 0; i < self.buttons.count; i++) {
        UIButton *navButton = (UIButton *)self.buttons[index];
        [navButton removeFromSuperview];
        navButton = nil;
    }
    
    [self.scrollView addSubview:self.bottonLineView];
    for (NSInteger i = 0; i < self.sliderInfoArr.count; i++) {
        FFSliderModel *navModel = (FFSliderModel *)self.sliderInfoArr[i];
        
        UIButton *navButton = [UIButton buttonWithType:UIButtonTypeCustom];
        navButton.frame = CGRectMake([self getNavLeft:i], 0, [self getNavWidth:i], 40);
        [navButton setTitle:navModel.sliderTitle forState:UIControlStateNormal];
        navButton.titleLabel.font = [UIFont systemFontOfSize:18];
        if (i == index) {
            [navButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        } else {
            [navButton setTitleColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6] forState:UIControlStateNormal];
        }
        navButton.tag = i;
        [navButton addTarget:self action:@selector(navClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:navButton];
        
        [self.buttons addObject:navButton];
    }
}

#pragma mark - get method
- (CGFloat)getAllNavWidth {
    CGFloat width = 0.0;
    for (NSInteger i = 0; i < self.sliderInfoArr.count; i++) {
        width += [self getNavWidth:i];
    }
    
    return width;
}

- (CGFloat)getNavLeft:(NSInteger)index {
    CGFloat width = 0.0;
    if (index == 0) {
        return 0;
    }
    
    for (NSInteger i = 0; i < index; i++) {
        width += [self getNavWidth:i];
    }
    
    return width;
}

- (CGFloat)getNavWidth:(NSInteger)index {
    if (index >= self.sliderInfoArr.count) {
        return 0.0;
    }
    FFSliderModel *navModel = (FFSliderModel *)self.sliderInfoArr[index];
    NSString *title = navModel.sliderTitle;
    
    CGFloat textWidth;
    CGSize size = [self getTextSizeWithFont:[UIFont systemFontOfSize:18] width:FFScreenWidth text:title];
    textWidth = size.width+10;
    
    return textWidth+10+10;
}

- (CGSize)getTextSizeWithFont:(UIFont*)font width:(float)width text:(NSString *)text {
    //动态计算文字大小
    NSDictionary *oldDict = @{NSFontAttributeName:font};
    CGSize oldPriceSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:oldDict context:nil].size;
    return oldPriceSize;
}


#pragma mark - get method
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, FFScreenWidth, 40)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
    }
    
    return _scrollView;
}

- (NSArray *)sliderInfoArr {
    if (!_sliderInfoArr) {
        _sliderInfoArr = [[NSArray alloc] init];
    }
    
    return _sliderInfoArr;
}

- (NSMutableArray *)buttons {
    if (!_buttons) {
        _buttons = [[NSMutableArray alloc] init];
    }
    
    return _buttons;
}

- (UIView *)bottonLineView {
    if (!_bottonLineView) {
        NSString *defaultTitle = @"推荐";
        CGSize size = [self getTextSizeWithFont:[UIFont systemFontOfSize:18] width:100 text:defaultTitle];
        _bottonLineView = [[UIView alloc] initWithFrame:CGRectMake(10, 40-8, size.width, 2.0)];
        _bottonLineView.backgroundColor = [UIColor blueColor];
    }
    return _bottonLineView;
}

@end
