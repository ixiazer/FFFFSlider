//
//  FFDetailViewController.m
//  FFSlider
//
//  Created by ixiazer on 16/8/26.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "FFDetailViewController.h"

@interface FFDetailViewController ()
@property (nonatomic, strong) UILabel *detailLab;
@end

@implementation FFDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Detail ViewController";

    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.detailLab];
    self.detailLab.text = self.detailTitle;
}

#pragma mark -- get method
- (UILabel *)detailLab {
    if (!_detailLab) {
        _detailLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
        _detailLab.textAlignment = NSTextAlignmentCenter;
        _detailLab.font = [UIFont boldSystemFontOfSize:60];
        _detailLab.backgroundColor = [UIColor clearColor];
        _detailLab.textColor = [UIColor blackColor];
    }
    return _detailLab;
}

#pragma mark -- set method
- (void)setDetailTitle:(NSString *)detailTitle {
    _detailTitle = detailTitle;
    
    self.detailLab.text = self.detailTitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
