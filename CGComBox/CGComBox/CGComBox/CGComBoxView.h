
#import <UIKit/UIKit.h>

@class CGComBoxView;
@protocol CGComBoxViewDelegate <NSObject>

@required
-(NSInteger)numberOfRowsInCombox:(CGComBoxView *)combox;//个数
-(NSString *)combox:(CGComBoxView *)combox titleOfRowAtIndex:(NSInteger)index;//每条显示的内容

@optional
//选中了一行
-(void)combox:(CGComBoxView *)combox didSelectRowAtIndex:(NSInteger)index;
//将要展开
- (BOOL)comboxWillUnfold:(CGComBoxView *)combox;
//删除一行
-(void)deleteAtIndex:(NSInteger)index inCombox:(CGComBoxView *)combox;
//展开后，每一行显示的高度
-(CGFloat)combox:(CGComBoxView *)combox heightForRowAtIndex:(NSInteger)index;//默认combox自身的高度
//输入框内的字符正在变化，可以用做搜索
-(void)combox:(CGComBoxView *)combox searchText:(NSString *)searchText;
@end

@interface CGComBoxView : UIView<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>
@property (nonatomic, strong, readonly) UITextView *textView;
@property (nonatomic,strong,readonly) UIImageView *arrow;
@property (nonatomic,weak) UIView *supView;

@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic,assign, readonly) BOOL isOpen;
@property (nonatomic,assign) BOOL isSearch;//是否允许搜索，默认NO
@property (nonatomic,assign) BOOL isDelete;//是否允许删除，默认NO
@property (nonatomic, assign) BOOL isDown;//YES 下 NO 上,默认yes
@property (nonatomic, assign) BOOL hideArrow;//默认NO不隐藏
@property (nonatomic, assign) BOOL isTouchOutsideHide; //点击控件外面 是否隐藏, 默认YES 隐藏

@property (nonatomic,assign) NSInteger currentIndex;
@property (nonatomic, weak) id<CGComBoxViewDelegate>delegate;



- (void)reloadData;
- (void)tapAction;
- (void)closeCombox;


@end


/*
    注意：
    1.单元格默认跟控件本身的高度一致
 */
