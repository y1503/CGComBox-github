//
//  ViewController.m
//  CGComBox
//
//  Created by ycg on 2017/5/14.
//  Copyright © 2017年 鱼鱼. All rights reserved.
//

#import "ViewController.h"
#import "CGComBoxView.h"

@interface ViewController ()<CGComBoxViewDelegate>
@property (nonatomic, strong) NSMutableArray *datas;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datas = [NSMutableArray arrayWithObjects:@"1234567890123456789012345678901234566666", @"2", nil];
    
    CGComBoxView *combox = [[CGComBoxView alloc] initWithFrame:CGRectMake(10, 100, 200, 40)];
    combox.supView = self.view;
    combox.delegate = self;
    combox.currentIndex = 0;
    [self.view addSubview:combox];
}


- (NSInteger)numberOfRowsInCombox:(CGComBoxView *)combox
{
    return self.datas.count;
}

- (NSString *)combox:(CGComBoxView *)combox titleOfRowAtIndex:(NSInteger)index
{
    return self.datas[index];
}

-(CGFloat)combox:(CGComBoxView *)combox heightForRowAtIndex:(NSInteger)index
{
    return 44.0f;
}

- (void)combox:(CGComBoxView *)combox searchText:(NSString *)searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains %@", searchText];
    [self.datas filterUsingPredicate:predicate];
}

@end
