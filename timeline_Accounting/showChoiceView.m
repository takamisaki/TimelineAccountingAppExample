#import "showChoiceView.h"

#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

@interface showChoiceView ()

@property (weak) IBOutlet UIButton *button1;        //键盘
@property (weak) IBOutlet UIButton *button2;
@property (weak) IBOutlet UIButton *button3;
@property (weak) IBOutlet UIButton *button4;
@property (weak) IBOutlet UIButton *button5;
@property (weak) IBOutlet UIButton *button6;
@property (weak) IBOutlet UIButton *button7;
@property (weak) IBOutlet UIButton *button8;
@property (weak) IBOutlet UIButton *button9;
@property (weak) IBOutlet UIButton *button0;
@property (weak) IBOutlet UIButton *buttonC;
@property (weak) IBOutlet UIButton *buttonDot;
@property (weak) IBOutlet UIButton *buttonDel;
@property (weak) IBOutlet UIButton *buttonPlus;
@property (weak) IBOutlet UIButton *buttonEqual;
@property (weak) IBOutlet UIButton *buttonOK;

@property (nonatomic, assign) float valueTemp;              //用于加法暂存第一个数
@property (nonatomic, assign) BOOL  dotAdded;               //是否添加了小数点

@end



@implementation showChoiceView


#pragma mark 键盘各个键点击事件
/*
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ Mindset:
 ┃ 1. 数字键处理
 ┃ 2. C 键处理
 ┃ 3. 小数点键处理, 只能有一个小数点
 ┃ 4. 退格处理
 ┃ 5. +处理
 ┃ 6. = 处理
 ┃ 7. OK 处理
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 */
- (IBAction)calculatorButtonClicked: (UIButton *)sender {
    
    NSUInteger stringLength  = [self.countLabel.text length];
    NSString *stringOriginal = self.countLabel.text;
    NSString *stringTemp     = @"";
    
    switch (sender.tag) {
        
        //数字键
        case 100:
        case 101:
        case 102:
        case 103:
        case 104:
        case 105:
        case 106:
        case 107:
        case 108:
        case 109:
            [self numberButtonAction:sender];
            break;
            
        //C 键
        case 110:
            self.countLabel.text = @"￥0.00";
//            self.decimalBitCount = 0;
            break;
        
        //小数点键
        case 111:
            if (self.dotAdded) { //小数点不能点两遍
                return;
            }
            
            self.dotAdded = YES;
            break;
            
        //退格键
        case 112:
            
            //如果点过小数点(小数点状态已激活)
            if (self.dotAdded) {
                
                //A. 小数点后都是0, 去掉小数点激活
                if ([stringOriginal hasSuffix:@"00"]) {
                    self.dotAdded = NO;
                    return;
                    
                } else {
                    //B. 如果小数点后不都是0
                    //B-1. 末位是0
                    if ([stringOriginal hasSuffix:@"0"]) {
                        stringTemp = [stringOriginal substringToIndex:stringLength - 2];
                        self.countLabel.text = [NSString stringWithFormat:@"%@00",stringTemp];
                        return;
                    }
                    
                    //B-2. 末位不是0
                    stringTemp = [stringOriginal substringToIndex:stringLength - 1];
                    self.countLabel.text = [NSString stringWithFormat:@"%@0",stringTemp];
                    return;
                }
            
            //如果没有点过小数点(小数点状态未激活)
            } else {
                
                //A. 此时只有个位数
                if (stringOriginal.length == 5) {
                    self.countLabel.text = @"￥0.00";
                    return;
                }
                
                //B. 如果还没有只剩个位数
                stringTemp = [stringOriginal substringToIndex:stringLength - 4];
                self.countLabel.text = [NSString stringWithFormat:@"%@.00",stringTemp];
            }
            break;
            
        //+键, 按完后暂存, 显示清零
        case 113:
            self.valueTemp = [[self.countLabel.text substringFromIndex:1] floatValue];
            self.countLabel.text = @"￥0.00";
            break;
            
        //=键
        case 114:
            self.countLabel.text = [NSString stringWithFormat:@"￥%.2f",
                                         self.valueTemp + [stringOriginal substringFromIndex:1].floatValue];
            self.valueTemp = 0.00;
            break;
            
        //OK 键
        case 115:
            self.buttonOKClicked(); //OK 事件
            break;
    }
    
}


#pragma mark 数字键事件
/*
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ Mindset:
 ┃ 1. 先获取显示的值, 和按的数字键的值
 ┃ 2. 判断是否已经激活了小数点, 如果激活, 判断是小数点后第几位, 添加成对应格式小数
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 */
- (void)numberButtonAction: (UIButton *)sender {

    float valueOrginal       = [[self.countLabel.text substringFromIndex:1] floatValue];
    float buttonValue        = [sender.titleLabel.text floatValue];
    NSString *stringOriginal = self.countLabel.text;

    //A. 如果小数点状态未激活
    if (!self.dotAdded){
    self.countLabel.text     = [NSString stringWithFormat:@"￥%.2f",valueOrginal * 10 + buttonValue];

    //B. 如果小数点状态激活了
    } else {

        //B-1. 如果小数点后都是0
        if ([stringOriginal hasSuffix:@"00"]) {
    self.countLabel.text     = [NSString stringWithFormat:@"￥%.2f",valueOrginal + buttonValue/10];
            return;

        //B-2. 如果小数点后不都是0
        } else {

            //B-2-1. 如果末位是0
            if ([stringOriginal hasSuffix:@"0"]) {
    self.countLabel.text     = [NSString stringWithFormat:@"￥%.2f",valueOrginal + buttonValue/100];
                return;
            }

            //B-2-2. 如果末位不是0, 不操作.
        }
    }
}


@end
