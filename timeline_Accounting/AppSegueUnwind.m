#import "AppSegueUnwind.h"

@implementation AppSegueUnwind

- (void)perform {
  
    UIView *secondVCView = self.sourceViewController.view;
    UIView *firstVCView = self.destinationViewController.view;
    
    CGFloat screehH = [UIScreen mainScreen].bounds.size.height;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window insertSubview:firstVCView aboveSubview:secondVCView];
    
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveLinear
     
                     animations:^{
                         firstVCView.frame = CGRectOffset(firstVCView.frame, 0.0, screehH);
                         secondVCView.frame = CGRectOffset(secondVCView.frame, 0.0, screehH);
                         
                     } completion:^(BOOL finished) {
                         [self.sourceViewController dismissViewControllerAnimated:NO
                                                                       completion:^{
                                                                           nil;
                                                                       }];
                     }];
}

@end
