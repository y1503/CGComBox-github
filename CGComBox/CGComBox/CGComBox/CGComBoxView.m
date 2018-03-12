#import "CGComBoxView.h"
#import "Masonry.h"
#import "CGComBoxTableViewCell.h"
#define CGComBoxView_Notification @"CGComBoxView_Notification"

#define tableH 100
#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)
#define kBorderColor [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1]
#define kTextColor   [UIColor darkGrayColor]

static NSString *cellIndentifier = @"cellIndentifier";

@interface CGComBoxView ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate>
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
        self.textField = [[UITextField alloc] init];
        self.textField.font = [UIFont systemFontOfSize:14];
        self.textField.backgroundColor = [UIColor clearColor];
        self.textField.textAlignment = NSTextAlignmentLeft;
        self.textField.delegate = self;
        self.textField.returnKeyType = UIReturnKeyDone;
        self.textField.textColor = kTextColor;
        [self.textField addTarget:self action:@selector(textFieldTextChaged:) forControlEvents:UIControlEventEditingChanged];
        [_btn addSubview:_textField];
        
        _arrow = [[UIImageView alloc] init];
        _arrow.image = [UIImage imageNamed:@"xiala_big.png"];
        [_btn addSubview:_arrow];
        
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
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
        self.isDelete = NO;
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
    if (!self.isSearch) {
        [_supView endEditing:YES];
    }
    
    if(_isOpen)
    {
        _isOpen = NO;
        self.coverView.hidden = YES;
        [_textField resignFirstResponder];
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
        self.coverView.hidden = NO;
        if ([_supView.subviews containsObject:self.coverView]) {
            [_supView bringSubviewToFront:self.coverView];
        }else if (self.isTouchOutsideHide && [self rows]) {
            [_supView addSubview:self.coverView];
        }
        
        [_supView addSubview:_listTable];
        [_supView bringSubviewToFront:_listTable];//避免被其他子视图遮盖住
        
        [self displayListTableView];
    }
    
}

- (void)displayTableViewHeight
{
    CGRect rect = [_supView convertRect:self.frame fromView:self];
    //去除在原来坐标系中的偏移
    rect = CGRectOffset(rect, 0-self.frame.origin.x, 0-self.frame.origin.y);
    if (self.isDown) {//down
        _listTable.frame =  CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, rect.size.width, 0);
        
    }else{//up
        _listTable.frame =  CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 0);
    }
    
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


- (UIView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.supView.bounds];
        _coverView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClicked:)];
        //        tap.delegate = self;
        tap.numberOfTouchesRequired = 1;
        tap.numberOfTapsRequired = 1;
        
        [_coverView addGestureRecognizer:tap];
    }
    
    return _coverView;
}


#pragma mark - 点击外部隐藏视图
- (void)tapClicked:(UITapGestureRecognizer *)tap
{
    if (self.isSearch) {
        //获取当前点击的点在_textField坐标系中的位置
        CGPoint point = [tap locationInView:_textField];
        if (CGRectContainsPoint(_textField.frame, point)) {//判断这个点是否在_textField所在的矩形内
            return;
        }
    }
    
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
    
    cell.textLabel.textAlignment = self.textField.textAlignment;
    cell.textLabel.font = self.textField.font;
    cell.textLabel.textColor = self.textField.textColor;//kTextColor;
    cell.borderColor = self.borderColor;
    
    NSInteger index = indexPath.row;
    if (self.searchResultArr) {
        index = [self.searchResultArr[indexPath.row] integerValue];
    }
    if ([self.delegate respondsToSelector:@selector(combox:titleOfRowAtIndex:)]) {
        cell.textLabel.text = [self.delegate combox:self titleOfRowAtIndex:index];
    }
    cell.deleteBtn.tag = index;
    [cell.deleteBtn addTarget:self action:@selector(deleteOneData:) forControlEvents:UIControlEventTouchUpInside];
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

#pragma mark -- 搜索的代理方法用
- (void)textChage:(NSString *)text
{
    if (self.isSearch&&[self.delegate respondsToSelector:@selector(combox:searchText:)]) {
        BOOL (^condition)(NSInteger index) = [self.delegate combox:self searchText:text];
        if (!condition) {
            return;
        }
        NSMutableArray *searchResult = [NSMutableArray array];
        NSInteger total = [self rows];
        for (NSInteger i = 0; i < total; i++) {
            if (condition(i)) {//返回YES，说明该项满足搜索条件
                [searchResult addObject:@(i)];
            }
        }
        self.searchResultArr = searchResult;
        if (self.searchResultArr.count == 0 && text.length == 0) {
            self.searchResultArr = nil;
        }
        if (!self.isOpen) {
            [self tapAction];
        }else{
            [self.listTable reloadData];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (!self.isOpen) {
        [self tapAction];
    }
    return YES;
}

- (void)textFieldTextChaged:(UITextField *)textField
{
    [self textChage:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
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
    
    [self.listTable reloadData];
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    NSInteger index = currentIndex;
    _currentIndex = currentIndex;
    if ([self rows] == 0) {
        return;//如果个数0就不作操作
    }
    if (self.searchResultArr) {
        index = [self.searchResultArr[currentIndex] integerValue];
    }
    if ([self.delegate respondsToSelector:@selector(combox:titleOfRowAtIndex:)]) {
        self.textField.text = [self.delegate combox:self titleOfRowAtIndex:index];
    }
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
    self.textField.userInteractionEnabled = isSearch;
}

- (void)setIsDelete:(BOOL)isDelete
{
    _isDelete = isDelete;
    [self.listTable reloadData];
}

- (void)reloadData
{
    if (self.isSearch) {
        [self search:self.textField.text];
    }
    [self displayListTableView];
}

- (void)search:(NSString *)searchKey
{
    [self textChage:searchKey];
}

//#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//
//    if ([touch.view isMemberOfClass:NSClassFromString(@"UITableViewCellContentView")]
//        || [touch.view isMemberOfClass:[UITextField class]]
//        || [touch.view isMemberOfClass:[UITextView class]]) {
//        return NO;
//    }
//
//    return YES;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if ([otherGestureRecognizer.view isKindOfClass:[UITableView class]]) {
//        return NO;
//    }
//    return YES;
//}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CGComBoxView_Notification object:nil];
}

@end

