//显示在主界面的 tableviewcell 的派生类的右子类
#import "AppCell.h"

@interface RightAppCell : AppCell

@property (nonatomic, weak) IBOutlet UILabel *contentLabel; 

@end
