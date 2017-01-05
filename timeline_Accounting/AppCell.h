//显示在主界面的tableviewcell 的派生类, 而且是父类
#import <UIKit/UIKit.h>

@interface AppCell : UITableViewCell

@property (nonatomic, weak  ) IBOutlet UIButton *middleButton;       //3个中间按钮
@property (nonatomic, weak  ) IBOutlet UIButton *modifyButton;
@property (nonatomic, weak  ) IBOutlet UIButton *deleteButton;

@property (nonatomic, copy  ) void (^deleteButtonBlock)(NSUInteger); //两个操作按钮 block
@property (nonatomic, copy  ) void (^modifyButtonBlock)(NSUInteger);

@property (nonatomic, assign) BOOL       isExpand;                   //两个操作按钮是否合体
@property (nonatomic, assign) NSUInteger index;                      //cell 对应的 index

- (void)middleAnimation;                                             //中间按钮的点击动画

@end
