//
//  ViewController.m
//  FFSlider
//
//  Created by ixiazer on 16/8/26.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "ViewController.h"
#import "FFCollectionSliderViewController.h"
#import "FFPageHomeViewController.h"
#import "FFSliderViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Slider Con";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableList = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableList.dataSource = self;
    self.tableList.delegate = self;
    [self.view addSubview:self.tableList];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSArray *arr = @[@"UICollectionView",@"UIScrollView",@"UIPageViewController"];
    cell.textLabel.text = arr[indexPath.row];
    
    return cell;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        FFCollectionSliderViewController *sliderVC = [[FFCollectionSliderViewController alloc] init];
        [self.navigationController pushViewController:sliderVC animated:YES];
    } else if (indexPath.row == 1) {
        FFSliderViewController *sliderVC = [[FFSliderViewController alloc] init];
        [self.navigationController pushViewController:sliderVC animated:YES];
    } else if (indexPath.row == 2) {
        FFPageHomeViewController *pageVC = [[FFPageHomeViewController alloc] init];
        [self.navigationController pushViewController:pageVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
