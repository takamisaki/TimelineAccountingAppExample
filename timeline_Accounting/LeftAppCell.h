//显示在主界面的 tableviewcell 的派生类的左子类
#import "AppCell.h"

@interface LeftAppCell : AppCell

@property (nonatomic, weak) IBOutlet UILabel *contentLabel; //显示消费的内容

@end

