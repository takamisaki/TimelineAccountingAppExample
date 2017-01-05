#import <UIKit/UIKit.h>
#import "Record.h"

@interface AddRecordViewController : UIViewController

@property (nonatomic, strong)  Record *record;          //接收修改按钮传来的记录
@property (nonatomic, assign)  BOOL isFromAdd;          //标记是否是由 add 按钮跳转的
@end
