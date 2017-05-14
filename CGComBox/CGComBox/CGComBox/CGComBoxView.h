
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CGComBoxViewTypeWithDeleteBtn,
    CGComBoxViewTypeWithOutDeleteBtn,
} CGComBoxViewType;

@class CGComBoxView;
@protocol CGComBoxViewDelegate <NSObject>

@optional
-(void)selectAtIndex:(NSInteger)index inCombox:(CGComBoxView *)combox;

- (BOOL)willClickAction:(CGComBoxView *)combox;

-(void)deleteAtIndex:(NSInteger)index inCombox:(CGComBoxView *)combox;

@end

@interface CGComBoxView : UIView<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSMutableArray *cellIndexs;
    CGRect defaultFrame;
    UIButton *_btn;
}
@property (nonatomic,assign, readonly) BOOL isOpen;
@property (nonatomic,strong,readonly) UITableView *listTable;
@property (nonatomic,strong) NSArray *titlesList;
@property (nonatomic,assign) NSInteger defaultIndex;
@property (nonatomic,assign,readonly) NSInteger currentIndex;
@property (nonatomic, copy) NSString *defaultTitle;//默认是defaultIndex对应的值
@property (nonatomic,strong,readonly) UIImageView *arrow;
@property (nonatomic,assign) id<CGComBoxViewDelegate>delegate;
@property (nonatomic,weak) UIView *supView;
@property (nonatomic, assign) BOOL isDown;//YES 下 NO 上,默认yes
@property (nonatomic, assign) BOOL isSearch;// 默认的不可以搜索
@property (nonatomic,strong,readonly) UITextField *titleTextField;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) BOOL hideArrow;//默认NO不隐藏
@property (nonatomic, assign) BOOL isTouchOutsideHide; //点击控件外面 是否隐藏, 默认YES 隐藏
//- (void)reloadData;
//- (void)closeOtherCombox;
- (void)tapAction;
- (void)closeCombox;
- (void)setTExtPlacehold:(NSString *)placeholdString;

@property(nonatomic, assign) CGComBoxViewType type;

@end


/*
    注意：
    1.单元格默认跟控件本身的高度一致
 */
