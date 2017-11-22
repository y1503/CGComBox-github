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
@property (nonatomic, strong) CGComBoxView *combox;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datas = [NSMutableArray arrayWithObjects:@"123", @"2",@"123", @"2",@"123", @"2",@"123", @"2", nil];
    
    CGComBoxView *combox = [[CGComBoxView alloc] initWithFrame:CGRectMake(10, 100, 200, 60)];
    combox.supView = self.view;
    combox.delegate = self;
    combox.isDelete = YES;
    combox.currentIndex = 0;
    combox.isSearch = YES;
    combox.textField.placeholder = @"测试了";
    self.combox = combox;
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

- (BOOL (^)(NSInteger))combox:(CGComBoxView *)combox searchText:(NSString *)searchText
{
    return NULL;
    return  ^(NSInteger index){
        NSString *string = self.datas[index];
        return [string containsString:searchText];
    };
}


- (void)deleteAtIndex:(NSInteger)index inCombox:(CGComBoxView *)combox
{
    [self.datas removeObjectAtIndex:index];
    [combox reloadData];
}

- (void)combox:(CGComBoxView *)combox didSelectRowAtIndex:(NSInteger)index
{
    
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    self.combox.textView.text = @"来了";
//}


@end
