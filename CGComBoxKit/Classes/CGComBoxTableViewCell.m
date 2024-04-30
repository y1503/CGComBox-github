//
//  CGComBoxTableViewCell.m
//  CGComBox
//
//  Created by ycg on 2017/10/30.
//  Copyright © 2017年 鱼鱼. All rights reserved.
//

#import "CGComBoxTableViewCell.h"
#import "Masonry.h"

@implementation CGComBoxTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        //显示内容
        self.backgroundColor = [UIColor clearColor];
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabel];
        //删除按钮
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setTitle:@"X" forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.contentView addSubview:_deleteBtn];
        
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(0);
            make.bottom.mas_equalTo(self.contentView).offset(0);
            make.left.mas_equalTo(self.contentView).offset(0);
            make.right.mas_equalTo(_deleteBtn.mas_left).offset(0);
        }];
        
        
        [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@30);
            make.right.mas_equalTo(self.contentView).offset(0);
            make.top.mas_equalTo(self.contentView).offset(0);
            make.bottom.mas_equalTo(self.contentView).offset(0);
        }];
        
        UIImageView *line = [[UIImageView alloc] init];
        [self.contentView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView).offset(0);
            make.right.mas_equalTo(self.contentView).offset(0);
            make.bottom.mas_equalTo(self.contentView).offset(0);
            make.height.mas_equalTo(@0.5);
        }];
    }
    
    return self;
}

- (void)setShowDeleteBtn:(BOOL)showDeleteBtn
{
    [_deleteBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@(showDeleteBtn?30:0));
    }];
    
    self.deleteBtn.hidden = !showDeleteBtn;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// 自绘分割线
- (void)drawRect:(CGRect)rect
{
    CGFloat dx = 0;
    CGFloat lineWidth = 1/UIScreen.mainScreen.scale;
    UIColor *color =  [UIColor colorWithRed:0xcc/255.0f green:0xcc/255.0f blue:0xcc/255.0f alpha:1];
    // 线的路径
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    // 起点
    [linePath moveToPoint:CGPointMake(dx, rect.size.height-lineWidth)];
    // 终点
    [linePath addLineToPoint:CGPointMake(rect.size.width, rect.size.height-lineWidth)];
    CAShapeLayer *lineLayer = [CAShapeLayer layer];

    lineLayer.lineWidth = lineWidth;
    lineLayer.strokeColor = color.CGColor;
    lineLayer.path = linePath.CGPath;
    lineLayer.fillColor = nil; // 默认为blackColor
    [self.contentView.layer addSublayer:lineLayer];
}

@end
