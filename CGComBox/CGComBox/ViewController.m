//
//  ViewController.m
//  CGComBox
//
//  Created by ycg on 2017/5/14.
//  Copyright © 2017年 鱼鱼. All rights reserved.
//

#import "ViewController.h"
#import "CGComBoxView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    CGComBoxView *combox = [[CGComBoxView alloc] initWithFrame:CGRectMake(10, 100, 200, 40)];
    combox.titlesList = @[@"123456789012345678901234567890", @"2"];
    combox.supView = self.view;
    combox.moreLines = YES;
    [self.view addSubview:combox];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
