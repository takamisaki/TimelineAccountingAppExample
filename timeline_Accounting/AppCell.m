#import "AppCell.h"
#import "LeftAppCell.h"
#import "RightAppCell.h"

//打印简洁化
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);


@implementation AppCell

- (IBAction)middleButtonClicked: (UIButton *)sender {
    
    [self middleAnimation];
}


#pragma mark 中间按钮点击动画
/*
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ Results:
 ┃ 1.配置合体动画
 ┃ 2.配置分体动画
 ┃
 ┃ Mindset:
 ┃ 1.获取中间按钮的 CGPoint
 ┃ 2.配置动画的开始和终止位置, 结束后标记是否合体状态
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 */
- (void)middleAnimation {
    
    __block CGPoint centerPoint  = self.middleButton.center;
    __weak typeof(self) weakSelf = self;
    
    //点击了中间按钮后, 如果在合体状态
    if (!self.isExpand) {
        
        //进行分体动画
        [UIView animateWithDuration:0.2 animations: ^{
         
            weakSelf.modifyButton.hidden = NO;
            weakSelf.deleteButton.hidden = NO;
            weakSelf.modifyButton.center = CGPointMake(centerPoint.x - 100, centerPoint.y);
            weakSelf.deleteButton.center = CGPointMake(centerPoint.x + 100, centerPoint.y);
        
        } completion: ^(BOOL finished) {
            weakSelf.isExpand = true;
        }];
        
        
    //如果在分体状态
    } else {
        
        [UIView animateWithDuration:0.2 animations: ^{
            
            weakSelf.modifyButton.center = centerPoint;
            weakSelf.deleteButton.center = centerPoint;
        
        } completion:^(BOOL finished) {
        
            weakSelf.modifyButton.hidden = YES;
            weakSelf.deleteButton.hidden = YES;
            weakSelf.isExpand = false;
        }];
    }
}


//更改按钮点击事件
- (IBAction)modifyButtonClicked: (UIButton *)sender {
    
     //更改内容按钮, 弹出添加的界面
     self.modifyButtonBlock(self.index);
    [self middleAnimation];
}


//删除按钮点击事件
- (IBAction)deleteButtonClicked: (UIButton *)sender {
    
    //删除该内容按钮, 删除本个 cell 对应的记录
    [self middleAnimation];
     self.deleteButtonBlock(self.index);
}

@end
