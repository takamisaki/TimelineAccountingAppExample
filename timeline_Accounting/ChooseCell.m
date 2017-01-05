#import "ChooseCell.h"

@implementation ChooseCell

//重写该方法, 解决 collectionView 滑动 cell 会重叠的情况
- (instancetype)initWithFrame: (CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.chooseIcon                = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 70, 70)];
        self.chooseIcon.contentMode    = UIViewContentModeScaleAspectFit;
        
        self.chooseLabel               = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 90, 20)];
        self.chooseLabel.textAlignment = NSTextAlignmentCenter;
        self.chooseLabel.textColor     = [UIColor colorWithRed:85/255 green:85/255 blue:85/255 alpha:1];
    }
    return self;
}

@end
