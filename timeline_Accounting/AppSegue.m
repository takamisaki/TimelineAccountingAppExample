#import "AppSegue.h"

@implementation AppSegue

- (void)perform {
    UIView *firstVCView = self.sourceViewController.view;
    UIView *secondVCView = self.destinationViewController.view;
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    
    secondVCView.frame = CGRectMake(0, screenH, screenW, screenH);  //目标视图初始位置
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow; //添加为窗口的子视图
    [window insertSubview:secondVCView aboveSubview:firstVCView];
    
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveLinear
     
                     animations:^{
                         firstVCView.frame  = CGRectOffset(firstVCView.frame, 0.0, -screenH);
                         secondVCView.frame = CGRectOffset(secondVCView.frame, 0.0, -screenH);
                     
                     } completion:^(BOOL finished) {
                         [self.sourceViewController presentViewController:self.destinationViewController
                                                                 animated:NO
                                                               completion:^{
                                                                   nil;
                                                               }];
                     }];
}

@end
