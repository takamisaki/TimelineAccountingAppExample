//显示在上面的横幅

#import <UIKit/UIKit.h>

@interface HeaderView : UIView

@property (nonatomic, weak) IBOutlet UILabel *incomeSumLabel ; //显示收入总额的 label
@property (nonatomic, weak) IBOutlet UILabel *outcomeSumLabel; //显示支出总额的 label

@end
