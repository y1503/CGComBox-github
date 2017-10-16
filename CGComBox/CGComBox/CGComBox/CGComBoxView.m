#import "CGComBoxView.h"
#import "Masonry.h"

#define CGComBoxView_Notification @"CGComBoxView_Notification"

#define tableH 100
#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)
#define kBorderColor [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1]
#define kTextColor   [UIColor darkGrayColor]

static NSString *cellIndentifier = @"cellIndentifier";

@interface CGComBoxView ()

@property(nonatomic, strong)UIView      *coverView; // 覆盖视图

@end

@implementation CGComBoxView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeOhter:) name:CGComBoxView_Notification object:nil];
        
        //设置默认值
        cellIndexs = [NSMutableArray array];
        self.isDown = YES;
        self.borderColor = kBorderColor;
        
        //初始化_btn
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_btn addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btn];
        
        [_btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 5, 0, 5));
        }];
        
        //初始化textfiled
        _titleTextField = [[UITextField alloc] init];
        _titleTextField.font = [UIFont systemFontOfSize:14];
        _titleTextField.backgroundColor = [UIColor clearColor];
        _titleTextField.textAlignment = NSTextAlignmentLeft;
        _titleTextField.delegate = self;
        _titleTextField.returnKeyType = UIReturnKeyDone;
        _titleTextField.textColor = kTextColor;
        
        //初始化textfiled
        _titleTV = [[UITextView alloc] init];
        _titleTV.font = [UIFont systemFontOfSize:14];
        _titleTV.backgroundColor = [UIColor clearColor];
        _titleTV.textAlignment = NSTextAlignmentLeft;
        _titleTV.delegate = self;
        _titleTV.returnKeyType = UIReturnKeyDone;
        _titleTV.textColor = kTextColor;
        
        
        if (_isSearch == NO) {
            _titleTextField.userInteractionEnabled = NO;
            _titleTV.userInteractionEnabled = NO;
        }
        [_titleTextField addTarget:self action:@selector(editChange:) forControlEvents:UIControlEventEditingChanged];
        [_btn addSubview:_titleTextField];
        
        [_btn addSubview:_titleTV];
        
        _arrow = [[UIImageView alloc] init];
        _arrow.image = [UIImage imageNamed:@"xiala_big.png"];
        [_btn addSubview:_arrow];
        
        [_titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_btn).offset(0);
            make.top.mas_equalTo(_btn).offset(0);
            make.right.mas_equalTo(_arrow.mas_left).offset(0);
            make.bottom.mas_equalTo(_btn).offset(0);
        }];
        
        [_titleTV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.titleTextField).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        [_arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_btn).offset(0);
            make.centerY.mas_equalTo(_btn.mas_centerY);
            make.height.mas_equalTo(_btn.mas_height).multipliedBy(0.75);
            make.width.mas_equalTo(_arrow.mas_height).multipliedBy(0.75);
        }];
        
        
        //初始化tableView
        //默认不展开
        _isOpen = NO;
        _listTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listTable.delegate = self;
        _listTable.dataSource = self;
        _listTable.layer.borderWidth = 0.5;
        _listTable.layer.borderColor = kTextColor.CGColor;
        [_listTable registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIndentifier];
        _isTouchOutsideHide = YES;
        self.moreLines = NO;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}


- (void)setBorderColor:(UIColor *)borderColor
{
    if (borderColor) {
        _borderColor = borderColor;
        _listTable.layer.borderColor = borderColor.CGColor;
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3;
        self.layer.borderColor = borderColor.CGColor;
        self.layer.borderWidth = 0.5;
    }
    
    
}


- (void)setTitlesList:(NSArray *)titlesList
{
    if (titlesList.count == 0) {
        return;
    }
    
    _titlesList = titlesList;
    if (_titlesList.count > _defaultIndex) {
        _titleTextField.text = [_titlesList objectAtIndex:_defaultIndex];
        _titleTV.text = [_titlesList objectAtIndex:_defaultIndex];
    }
    if (_defaultTitle) {
        self.defaultTitle = _defaultTitle;
    }
    
    [self reSetCellIndexs];
    
    
    if (_isOpen) {
        [self displayListTableView];
        [_listTable reloadData];
    }
    
}

- (void)setDefaultIndex:(NSInteger)defaultIndex
{
    if (defaultIndex < 0 || defaultIndex >= _titlesList.count) {
        return;
    }
    
    _defaultIndex = defaultIndex;
    _currentIndex = defaultIndex;
    if (_titlesList.count > _defaultIndex) {
        _titleTextField.text = [_titlesList objectAtIndex:_defaultIndex];
        _titleTV.text = [_titlesList objectAtIndex:_defaultIndex];
        if([_delegate respondsToSelector:@selector(selectAtIndex:inCombox:)])
        {
            [_delegate selectAtIndex:_currentIndex inCombox:self];
        }
        
    }
    else if (_defaultTitle) {
        _titleTextField.text = _defaultTitle;
        _titleTV.text = _defaultTitle;
    }
}

- (void)setDefaultTitle:(NSString *)defaultTitle
{
    if ([defaultTitle isKindOfClass:[NSString class]] == NO) {
        return;
    }
    
    _defaultTitle = defaultTitle;
    _titleTextField.text = defaultTitle;
    _titleTV.text = defaultTitle;
    if (_defaultTitle != defaultTitle) {
        _defaultTitle = [defaultTitle copy];
    }

    self.defaultIndex = [_titlesList indexOfObject:defaultTitle];
    
}

#pragma mark -- 关闭自己
- (void)closeCombox
{
    if(self.isOpen)
    {
        [self tapAction];
    }
}

- (void)reSetCellIndexs
{
    NSInteger count = _titlesList.count;
    [cellIndexs removeAllObjects];
    for (int i = 0; i < count; i++) {
        [cellIndexs addObject:[NSNumber numberWithInt:i]];
    }
}


#pragma mark -- 点击事件
-(void)tapAction
{
    if (self.isSearch == NO) {
        [_supView endEditing:YES];
    }
    
    if(_isOpen)
    {
        _isOpen = NO;
        self.coverView.hidden = YES;
        [_titleTextField resignFirstResponder];
        [_titleTV resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = _listTable.frame;
            if (self.isDown) {
                rect.size.height = 0;
            }else{
                rect.origin.y += rect.size.height;
                rect.size.height = 0;
            }
            _listTable.frame =  rect;
        } completion:^(BOOL finished){
            [_listTable removeFromSuperview];//移除
            
                CGFloat rotate = 180;
                if (_isDown == NO) {
                    rotate = -180;
                }
                _arrow.transform = CGAffineTransformRotate(_arrow.transform, DEGREES_TO_RADIANS(rotate));

            }];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CGComBoxView_Notification object:self];

        
        self.coverView.hidden = NO;
        if ([_delegate respondsToSelector:@selector(willClickAction:)]) {
            if (![_delegate willClickAction:self]) {
                return;
            }
        }
        _isOpen = YES;
        
        CGRect rect = [_supView convertRect:self.frame fromView:self];
        //去除在原来坐标系中的偏移
        rect = CGRectOffset(rect, 0-self.frame.origin.x, 0-self.frame.origin.y);
        if (self.isDown) {//down
            _listTable.frame =  CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, rect.size.width, 0);
            
        }else{//up
            _listTable.frame =  CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 0);
        }
        
        self.coverView.hidden = NO;
        if (self.isTouchOutsideHide && self.titlesList.count) {
            [_supView addSubview:self.coverView];
            [_supView bringSubviewToFront:self.coverView];
        }
        
        [_supView addSubview:_listTable];
        
        [_supView bringSubviewToFront:_listTable];//避免被其他子视图遮盖住

        [UIView animateWithDuration:0.3 animations:^{
            
            CGFloat tableHeight = self.titlesList.count * rect.size.height;
            if (self.isDown) {//down
                CGFloat height = _supView.frame.size.height - rect.origin.y - rect.size.height;
                if (tableHeight > height) {
                    tableHeight = height;
                }
                
                _listTable.frame =  CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, rect.size.width, tableHeight);
                
            }else{//up
                CGFloat height = rect.origin.y;
                if (tableHeight > height) {
                    tableHeight = height;
                }
                _listTable.frame =  CGRectMake(rect.origin.x, rect.origin.y - tableHeight, rect.size.width, tableHeight);
            }

            
        } completion:^(BOOL finished){

            CGFloat rotate = 180;
            if (_isDown == NO) {
                rotate = -180;
            }
            _arrow.transform = CGAffineTransformRotate(_arrow.transform, DEGREES_TO_RADIANS(rotate));
        }];
        [_listTable reloadData];
    }
    
}

- (UIView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.supView.bounds];
        _coverView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClicked:)];
        tap.numberOfTouchesRequired = 1;
        tap.numberOfTapsRequired = 1;
        
        [_coverView addGestureRecognizer:tap];
    }
    
    return _coverView;
}


#pragma mark - 点击外部隐藏视图
- (void)tapClicked:(UITapGestureRecognizer *)tap
{
    if (_isTouchOutsideHide == NO || !self.titlesList.count) {
        self.coverView.hidden = YES;
        return;
    }
    
    if (tap.view == self.coverView) {
        [self tapAction];
    }
}

#pragma mark -tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cellIndexs.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.frame.size.height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    cell.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = self.titleTextField.textAlignment;
    label.font = self.titleTextField.font;
    label.textColor = self.titleTextField.textColor;//kTextColor;
    NSInteger row = [cellIndexs[indexPath.row] integerValue];
    label.text = [_titlesList objectAtIndex:row];
    [cell.contentView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView).insets(UIEdgeInsetsMake(0, 5, 0, 0));
    }];
    
    if ([self.delegate respondsToSelector:@selector(deleteAtIndex:inCombox:)]) {
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setTitle:@"X" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteOneData:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteBtn];
        deleteBtn.tag = indexPath.row;
        [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@30);
            make.right.mas_equalTo(cell.contentView).offset(0);
            make.top.mas_equalTo(cell.contentView).offset(0);
            make.height.mas_equalTo(@35);
        }];
        if (self.type == CGComBoxViewTypeWithDeleteBtn) {
            deleteBtn.hidden = NO;
        }else{
            deleteBtn.hidden = YES;
        }
    }
    UIImageView *line = [[UIImageView alloc] init];
    line.backgroundColor = _borderColor;
    [cell.contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cell.contentView).offset(0);
        make.right.mas_equalTo(cell.contentView).offset(0);
        make.bottom.mas_equalTo(cell.contentView).offset(0);
        make.height.mas_equalTo(@0.5);
    }];
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _currentIndex = [cellIndexs[indexPath.row] integerValue];
    self.defaultIndex = _currentIndex;
    [self tapAction];

}

-(void)deSelectedRow
{
    [_listTable deselectRowAtIndexPath:[_listTable indexPathForSelectedRow] animated:YES];
}

- (void)deleteOneData:(UIButton *)btn {
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.titlesList];
    
    [array removeObjectAtIndex:btn.tag];
    _titlesList = array;
    [cellIndexs removeObjectAtIndex:btn.tag];
    [self reSetCellIndexs];
    [_listTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.listTable reloadData];
    if (array.count == 0) {
        [self closeCombox];
    }
    if ([self.delegate respondsToSelector:@selector(deleteAtIndex:inCombox:)]) {
        [self.delegate deleteAtIndex:btn.tag inCombox:self];
        [self displayListTableView];
        [self.listTable reloadData];
    }
}

- (void)setIsSearch:(BOOL)isSearch
{
    _isSearch = isSearch;
    _titleTextField.userInteractionEnabled = isSearch;
    _titleTV.userInteractionEnabled = isSearch;
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)editChange:(UITextField *)textField
{
    [self change:textField.text];
}

#pragma mark -- 中间方法，便于调用
- (void)change:(NSString *)tempStr
{
    if (self.isOpen == NO) {
        [self tapAction];
    }
    
    
    NSInteger lastCount = cellIndexs.count;
    
    [cellIndexs removeAllObjects];
    NSInteger count = _titlesList.count;
    for (int i = 0; i < count; i++ ) {
        if (tempStr.length == 0) {
            break;
        }
        NSString *str = _titlesList[i];
        if ([str containsString:tempStr]) {
            [cellIndexs addObject:[NSNumber numberWithInt:i]];
        }
    }
    if (tempStr.length == 0) {
        [self reSetCellIndexs];
    }
    
    _defaultIndex = 0;
    _currentIndex = 0;
    
    if (lastCount != cellIndexs.count) {
        [self displayListTableView];
    }
    
    
    [_listTable reloadData];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    [self change:textView.text];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark -- 调整tableview的高度
- (void)displayListTableView
{
    CGRect rect = [_supView convertRect:self.frame fromView:self];
    //去除在原来坐标系中的偏移
    rect = CGRectOffset(rect, 0-self.frame.origin.x, 0-self.frame.origin.y);
    CGFloat tableHeight = cellIndexs.count * rect.size.height;
    if (self.isDown) {//down
        CGFloat height = _supView.frame.size.height - rect.origin.y - rect.size.height;
        if (tableHeight > height) {
            tableHeight = height;
        }
        
        _listTable.frame =  CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, rect.size.width, tableHeight);
        
    }else{//up
        CGFloat height = rect.origin.y;
        if (tableHeight > height) {
            tableHeight = height;
        }
        _listTable.frame =  CGRectMake(rect.origin.x, rect.origin.y - tableHeight, rect.size.width, tableHeight);
    }
}

- (void)setTExtPlacehold:(NSString *)placeholdString
{
    _titleTextField.placeholder = placeholdString;
}

- (void)closeOhter:(NSNotification *)notification
{
    if ([notification.object isEqual:self] == NO) {
        [self closeCombox];
    }
}

- (void)setHideArrow:(BOOL)hideArrow
{
    _hideArrow = hideArrow;
    if (_hideArrow) {
        [_arrow mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_btn).offset(0);
            make.centerY.mas_equalTo(_btn.mas_centerY);
            make.height.mas_equalTo(@0);
            make.width.mas_equalTo(@0);
        }];
    }else{
        [_arrow mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_btn).offset(0);
            make.centerY.mas_equalTo(_btn.mas_centerY);
            make.height.mas_equalTo(_btn.mas_height).multipliedBy(0.75);
            make.width.mas_equalTo(_arrow.mas_height).multipliedBy(0.75);
        }];
    }
    _arrow.hidden = hideArrow;
    
}

- (void)setMoreLines:(BOOL)moreLines
{
    _moreLines = moreLines;
    self.titleTextField.hidden = moreLines;
    self.titleTV.hidden = !moreLines;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CGComBoxView_Notification object:nil];
}

@end
