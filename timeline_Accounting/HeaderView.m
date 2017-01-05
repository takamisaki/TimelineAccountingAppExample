#import "HeaderView.h"
#import "ViewController.h"


@implementation HeaderView

- (void)transferIncomeSum: (float)incomeSum {
    
    self.incomeSumLabel.text = [NSString stringWithFormat:@"￥%.2f",incomeSum];
}


- (void)transferOutcomeSum: (float)outcomeSum {
    
    self.outcomeSumLabel.text = [NSString stringWithFormat:@"￥%.2f",outcomeSum];
}

@end
