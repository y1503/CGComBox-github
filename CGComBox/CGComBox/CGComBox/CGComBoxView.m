#import "CGComBoxView.h"
#import "Masonry.h"
#import "CGComBoxTableViewCell.h"
#define CGComBoxView_Notification @"CGComBoxView_Notification"

#define tableH 100
#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)
#define kBorderColor [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1]
#define kTextColor   [UIColor darkGrayColor]

static NSString *cellIndentifier = @"cellIndentifier";

@interface CGComBoxView ()
{
    UIButton *_btn;
}

@property (nonatomic, strong) UIView *coverView; // 覆盖视图
@property (nonatomic, strong) UITableView *listTable;
@property (nonatomic, strong) UILabel *placeHolderLbl;
@property (nonatomic, strong) NSArray *searchResultArr;//搜索用，不为空，就使用该数组显示数据
@end

@implementation CGComBoxView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeOhter:) name:CGComBoxView_Notification object:nil];
        
        self.borderColor = kBorderColor;
        
        //初始化_btn
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_btn addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btn];
        
        [_btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 5, 0, 5));
        }];
        
        //初始化textfiled
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.delegate = self;
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.textColor = kTextColor;
        
        [_textView addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        
        _placeHolderLbl = [[UILabel alloc] init];
        _placeHolderLbl.textColor = [UIColor lightGrayColor];
        _placeHolderLbl.font = [UIFont systemFontOfSize:14];
        _placeHolderLbl.textAlignment = NSTextAlignmentLeft;
        _placeHolderLbl.numberOfLines = 0;
        _placeHolderLbl.lineBreakMode = NSLineBreakByCharWrapping;
        [_textView addSubview:_placeHolderLbl];
        [self.placeHolderLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_textView).offset(10/2);
            make.right.mas_equalTo(_textView).offset(-10/2);
            make.top.mas_equalTo(_textView).offset(10/2);
            make.bottom.mas_equalTo(_textView).offset(-10/2);
            make.width.mas_lessThanOrEqualTo(_textView.mas_width).offset(-10);
        }];
        
        
        
        [_btn addSubview:_textView];
        
        _arrow = [[UIImageView alloc] init];
        _arrow.image = [UIImage imageNamed:@"xiala_big.png"];
        [_btn addSubview:_arrow];
        
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_btn).offset(0);
            make.right.mas_equalTo(_arrow.mas_left).offset(0);
            make.centerY.mas_equalTo(_btn.mas_centerY);
            make.height.mas_equalTo(_btn.mas_height).offset(0);
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
        [_listTable registerClass:[CGComBoxTableViewCell class] forCellReuseIdentifier:cellIndentifier];
        _isTouchOutsideHide = YES;
        
        
        
        //设置默认值
        self.isDown = YES;
        self.isSearch = NO;
        self.isMoreLine = NO;
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


#pragma mark -- 关闭自己
- (void)closeCombox
{
    if(self.isOpen)
    {
        [self tapAction];
    }
}

#pragma mark -- 列表显示的总个数
- (NSInteger)rows
{
    if ([self.delegate respondsToSelector:@selector(numberOfRowsInCombox:)]) {
        return [self.delegate numberOfRowsInCombox:self];
    }
    return 0;
}

#pragma mark -- 点击事件
-(void)tapAction
{
    if (![self.delegate respondsToSelector:@selector(combox:searchText:)]) {
        [_supView endEditing:YES];
    }
    
    if(_isOpen)
    {
        _isOpen = NO;
        self.coverView.hidden = YES;
        [_textView resignFirstResponder];
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
        if ([_delegate respondsToSelector:@selector(comboxWillUnfold:)]) {
            if (![_delegate comboxWillUnfold:self]) {
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
        if (self.isTouchOutsideHide && [self rows] ) {
            [_supView addSubview:self.coverView];
            [_supView bringSubviewToFront:self.coverView];
        }
        
        [_supView addSubview:_listTable];
        
        [_supView bringSubviewToFront:_listTable];//避免被其他子视图遮盖住

        [UIView animateWithDuration:0.3 animations:^{
            
            CGFloat tableHeight = [self rows] * rect.size.height;
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
    if (_isTouchOutsideHide == NO || ![self rows]) {
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
    if (self.searchResultArr) {
        return self.searchResultArr.count;
    }
    return [self rows];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.frame.size.height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    CGComBoxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
    
    cell.textLabel.textAlignment = self.textView.textAlignment;
    cell.textLabel.font = self.textView.font;
    cell.textLabel.textColor = self.textView.textColor;//kTextColor;
    cell.borderColor = self.borderColor;
    [cell.deleteBtn addTarget:self action:@selector(deleteOneData:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self.delegate respondsToSelector:@selector(combox:titleOfRowAtIndex:)]) {
        
        NSInteger index = indexPath.row;
        if (self.searchResultArr) {
            index = [self.searchResultArr[indexPath.row] integerValue];
        }
        cell.textLabel.text = [self.delegate combox:self titleOfRowAtIndex:index];
    }
    
    cell.showDeleteBtn = self.isDelete;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.currentIndex = indexPath.row;
    if ([self.delegate respondsToSelector:@selector(combox:didSelectRowAtIndex:)]) {
        NSInteger index = indexPath.row;
        if (self.searchResultArr) {
            index = [self.searchResultArr[indexPath.row] integerValue];
        }
        [self.delegate combox:self didSelectRowAtIndex:index];
    }
    
    [self tapAction];

}

-(void)deSelectedRow
{
    [_listTable deselectRowAtIndexPath:[_listTable indexPathForSelectedRow] animated:YES];
}

- (void)deleteOneData:(UIButton *)btn {
    
    if ([self.delegate respondsToSelector:@selector(deleteAtIndex:inCombox:)]) {
        [self.delegate deleteAtIndex:btn.tag inCombox:self];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(combox:searchText:)]) {
        self.searchResultArr = [self.delegate combox:self searchText:textView.text];
        if (self.searchResultArr.count == 0 && textView.text.length == 0) {
            self.searchResultArr = nil;
        }

        if (!self.isOpen) {
            [self tapAction];
        }else{
            [self.listTable reloadData];
        }
    }

    if (_textView.text.length == 0) {
        self.placeHolderLbl.hidden = NO;
    }else{
        self.placeHolderLbl.hidden = YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (_textView.text.length == 0) {
        self.placeHolderLbl.hidden = NO;
    }else{
        self.placeHolderLbl.hidden = YES;
    }
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    self.placeHolderLbl.text = placeHolder;
    _placeHolder = placeHolder;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (!self.isOpen) {
        [self tapAction];
    }
    return YES;
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
    CGFloat tableHeight = [self rows] * rect.size.height;
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

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    NSInteger index = currentIndex;
    if (self.searchResultArr) {
        index = [self.searchResultArr[currentIndex] integerValue];
    }
    if ([self.delegate respondsToSelector:@selector(combox:titleOfRowAtIndex:)]) {
        self.textView.text = [self.delegate combox:self titleOfRowAtIndex:currentIndex];
    }
    _currentIndex = currentIndex;
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

- (void)setIsSearch:(BOOL)isSearch
{
    _isSearch = isSearch;
    self.textView.userInteractionEnabled = isSearch;
}

- (void)setIsMoreLine:(BOOL)isMoreLine
{
    [_textView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (isMoreLine) {
            make.height.mas_equalTo(_btn.mas_height).offset(0);
        }else{
            make.height.mas_equalTo(@21);
        }
    }];
    _isMoreLine = isMoreLine;
}

- (void)reloadData
{
    [self.listTable reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CGComBoxView_Notification object:nil];
    [self removeObserver:self forKeyPath:@"text"];
}

@end
