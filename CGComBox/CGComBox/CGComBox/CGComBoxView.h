
#import <UIKit/UIKit.h>

@class CGComBoxView;
@protocol CGComBoxViewDelegate <NSObject>

@required
-(NSInteger)numberOfRows;//个数
-(NSString *)combox:(CGComBoxView *)combox titleOfRowAtIndex:(NSInteger)index;//每条显示的内容

@optional
-(void)selectAtIndex:(NSInteger)index inCombox:(CGComBoxView *)combox;
-(void)combox:(CGComBoxView *)combox didSelectRowAtIndex:(NSInteger)index;

- (BOOL)willClickAction:(CGComBoxView *)combox;

-(void)deleteAtIndex:(NSInteger)index inCombox:(CGComBoxView *)combox;
-(CGFloat)combox:(CGComBoxView *)combox heightForRowAtIndex:(NSInteger)index;//默认combox自身的高度
-(void)combox:(CGComBoxView *)combox searchText:(NSString *)searchText;
@end

@interface CGComBoxView : UIView<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>

@property (nonatomic,assign, readonly) BOOL isOpen;

@property (nonatomic,assign) NSInteger currentIndex;
@property (nonatomic,strong,readonly) UIImageView *arrow;
@property (nonatomic, weak) id<CGComBoxViewDelegate>delegate;
@property (nonatomic,weak) UIView *supView;
@property (nonatomic, assign) BOOL isDown;//YES 下 NO 上,默认yes
@property (nonatomic, strong, readonly) UITextView *textView;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) BOOL hideArrow;//默认NO不隐藏
@property (nonatomic, assign) BOOL isTouchOutsideHide; //点击控件外面 是否隐藏, 默认YES 隐藏

- (void)tapAction;
- (void)closeCombox;


@end


/*
    注意：
    1.单元格默认跟控件本身的高度一致
 */
