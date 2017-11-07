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
    combox.isDelete = YES;
    combox.currentIndex = 0;
    combox.isSearch = YES;
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

- (NSArray <NSNumber *>*)combox:(CGComBoxView *)combox searchText:(NSString *)searchText
{
    NSMutableArray *searchArr = [NSMutableArray array];
    for (NSInteger i = 0; i < self.datas.count ; i++) {
        NSString *string = self.datas[i];
        if ([string containsString:searchText]) {
            [searchArr addObject:@(i)];
        }
    }
    
    return searchArr;
}

- (void)deleteAtIndex:(NSInteger)index inCombox:(CGComBoxView *)combox
{
    
}

- (void)combox:(CGComBoxView *)combox didSelectRowAtIndex:(NSInteger)index
{
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

@end
