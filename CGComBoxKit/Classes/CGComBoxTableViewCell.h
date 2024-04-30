//
//  CGComBoxTableViewCell.h
//  CGComBox
//
//  Created by ycg on 2017/10/30.
//  Copyright © 2017年 鱼鱼. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CGComBoxTableViewCell : UITableViewCell
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UIButton *deleteBtn;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) BOOL showDeleteBtn;//显示删除按钮

@end
