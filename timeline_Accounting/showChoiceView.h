#import <UIKit/UIKit.h>

typedef void(^buttonOKBlock)();

@interface showChoiceView : UIView

@property (nonatomic, weak) IBOutlet UIImageView   *iconChoosed;      //显示所选图标
@property (nonatomic, weak) IBOutlet UILabel       *iconNameChoosed;  //显示所选子分类
@property (nonatomic, weak) IBOutlet UILabel       *countLabel;
@property (nonatomic, weak) IBOutlet UIButton      *coverButton;      //用于输入框添加点击事件
@property (nonatomic, copy) buttonOKBlock          buttonOKClicked;   //键盘 OK Block
@end
