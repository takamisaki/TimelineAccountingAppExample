#import "ViewController.h"
#import "AppTableView.h"
#import "HeaderView.h"
#import "LeftAppCell.h"
#import "RightAppCell.h"
#import "Record.h"
#import "AppDelegate.h"
#import "AddRecordViewController.h"
#import "AppSegue.h"
#import "AppSegueUnwind.h"

//打印简洁化
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak  ) IBOutlet HeaderView      *headerview;           //上方+号栏
@property (nonatomic, weak  ) IBOutlet AppTableView    *tableView;            //下方表格栏
@property (nonatomic, strong) NSManagedObjectContext   *managedObjectContext; //coreData上下文
@property (nonatomic, strong) NSMutableArray<Record *> *recordArray;          //coreData记录数组
@property (nonatomic, strong) NSFetchRequest           *fetch;                //查询对象
@property (nonatomic, strong) Record                   *recordOfCellClicked;  //点击的cell对应的记录
@property (nonatomic, assign) NSUInteger               cellClickedIndex;      //接收被点击cell的index
@end



@implementation ViewController


#pragma mark 视图载入前
/*
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ Results:
 ┃ 1.生成记录数组
 ┃ 2.配置 tableview
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 */
-(void)viewWillAppear:(BOOL)animated{
    
    //Result 1: 生成记录数组
    AppDelegate *appDelegate  = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    self.fetch                = [NSFetchRequest fetchRequestWithEntityName:@"Record"];
    [self refreshDataAndShow];//刷新 tableView 和 header
    
    //Result 2:
    _tableView.delegate   = self;
    _tableView.dataSource = self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark TableView & Header 刷新
/*
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ Results:
 ┃ 1.生成记录的倒序数组, 使新纪录可以出现在上面
 ┃ 2.刷新 Header 的收支总计
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 */
- (void)refreshDataAndShow {
    
    //Result 1:生成倒序数组
    NSArray *recordArrayTemp = [_managedObjectContext executeFetchRequest:_fetch error:nil];
    self.recordArray         = [NSMutableArray new];
    int arrayCount           = (int)recordArrayTemp.count;
    
    for (int index = arrayCount - 1; index >= 0; index --) {
        
        [_recordArray addObject:recordArrayTemp[index]];
    }
    
    [_tableView reloadData]; //tableview 刷新数值
    
    //Result 2:刷新 Header
    [self calculateSum];
}



#pragma mark 计算收支加总
/*
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ Mindset:
 ┃ 1.遍历记录数组, 截取每个记录的数值
 ┃ 2.根据收支分类, 分别加总
 ┃ 3.传值给 Header 进行显示
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 */
- (void)calculateSum {
    
    float incomeSum  = 0.0;  //初始化收入加总值
    float outcomeSum = 0.0;  //初始化支出加总值
    
    for (Record *recordTemp in self.recordArray) {
        
        //截取出数值部分
        NSString *countString = [recordTemp valueForKey:@"count"];
        NSRange range         = [countString rangeOfString:@"￥"];
        float countValue      = [countString substringFromIndex:range.location+1].floatValue;
        
        //分类加总
        if ([[recordTemp valueForKey:@"type"] isEqualToString:@"income"]) {
            incomeSum  += countValue;
        } else {
            outcomeSum += countValue;
        }
    }
    
    //传值给 header
    self.headerview.incomeSumLabel .text = [NSString stringWithFormat:@"￥%.2f",incomeSum ];
    self.headerview.outcomeSumLabel.text = [NSString stringWithFormat:@"￥%.2f",outcomeSum];
}


//设置tableview 的显示row 数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _recordArray.count;
}


//预处理, 让 cellForRow 更快
-(void)tableView:(AppTableView *)tableView willDisplayCell:(AppCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
}



#pragma mark Cell的配置和显示
/*
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ Mindset:
 ┃ 1.获取对应 row 的记录
 ┃ 2.根据收支 identifier 分别重用并配置
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 */
- (UITableViewCell *)tableView: (AppTableView *)tableView
         cellForRowAtIndexPath: (NSIndexPath  *)indexPath {
    
    Record *record = _recordArray [indexPath.row];
    NSString *type = [record valueForKey:@"type"];
    
    
    //如果是收入类型
    if ([type isEqualToString:@"income"]) {
        
        NSString *identifier = @"leftCell";
        LeftAppCell *cell    = [tableView dequeueReusableCellWithIdentifier:identifier
                                                               forIndexPath:indexPath];
        [self cellConfiguration:cell with:record forIndex:indexPath.row];
        [self cellButtonBlock:cell];
        return cell;
        
        
    }else { //如果是支出类型
        
        NSString *identifier = @"rightCell";
        RightAppCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier
                                                             forIndexPath:indexPath];
        [self cellConfiguration:cell with:record forIndex:indexPath.row];
        [self cellButtonBlock:cell];
        return cell;
    }
}


#pragma mark 配置 cell 的属性和显示内容
/*
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ Parameters:
 ┃ 1.cell:   该 row 对应的 cell
 ┃ 2.record: 该 row 对应的记录
 ┃ 3.index:  该 row
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 */
- (void)cellConfiguration: (AppCell *)cell with:(Record *)record forIndex:(NSUInteger)index {
    
    NSString *textString = [NSString stringWithFormat:@"%@ %@",[record valueForKey:@"subType"],
                            [record valueForKey: @"count"]];
    
    [cell setValue:textString forKeyPath:@"contentLabel.text"];                          //显示内容
    [cell setValue:@4         forKeyPath:@"contentLabel.layer.cornerRadius"];            //圆角
    [cell setValue:@YES       forKeyPath:@"contentLabel.clipsToBounds"];
    [cell.middleButton        setImage:[UIImage imageNamed:[record valueForKey:@"icon"]] //图标
                              forState:UIControlStateNormal];
    cell.index    = index; //设定cell 对应的 index, 用于按钮 block
    cell.isExpand = false; //折叠图标
}


#pragma mark cell 按钮 block 设置
/*
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ Results:
 ┃ 1.delete 按钮 block 设置
 ┃ 2.modify 按钮 block 设置
 ┃
 ┃ Mindset:
 ┃ 1.delete block 获取按钮所在的 cell, 找出对应的记录, 删除, 更新显示
 ┃ 2.modify block 先在 prepareForSegue 里设置对应的记录传值, 然后在 block 里调用 segue
 ┃
 ┃ Parameters:
 ┃ 1.cell: 按钮所在的 cell
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 */
- (void)cellButtonBlock: (AppCell *)cell {
    
    __weak typeof(self) weakSelf = self;
    
    cell.deleteButtonBlock = ^(NSUInteger index){
        
        weakSelf.recordOfCellClicked = weakSelf.recordArray[index];
        [weakSelf.managedObjectContext deleteObject:weakSelf.recordOfCellClicked];
        [weakSelf.managedObjectContext save:nil];
        [weakSelf refreshDataAndShow];
    };
    
    cell.modifyButtonBlock = ^(NSUInteger index){
        self.cellClickedIndex = index;
        [weakSelf performSegueWithIdentifier:@"appSegue" sender:weakSelf];
    };
}

//segue 准备: 获取按钮在的 cell, 然后找出对应的记录, 传值给弹出页面
- (void)prepareForSegue: (UIStoryboardSegue *)segue sender:(id)sender {

    AddRecordViewController *destionationVC = segue.destinationViewController;
    
    //如果是 modify 按钮激活的 segue, 传值
    //如果无记录, 就不传值. (解决空白记录时, 点+ 导致 crash.)
    if ([segue.identifier isEqualToString:@"appSegue"]) {
        self.recordOfCellClicked = self.recordArray[self.cellClickedIndex];
        [destionationVC setValue:self.recordOfCellClicked forKey:@"record"];
        [destionationVC setValue:@NO forKey:@"isFromAdd"]; //标记不是 add激活的 segue
        
    //如果是 add 激活的 segue
    } else if ([segue.identifier isEqualToString:@"addSegue"]) {
        [destionationVC setValue:@YES forKey:@"isFromAdd"];
    }
}

- (IBAction)returnFromSegueActions: (UIStoryboardSegue *)sender{ //用于 unwind segue执行的方法
    
}


- (UIStoryboardSegue *)segueForUnwindingToViewController: (UIViewController *)toViewController
                                      fromViewController:(UIViewController *)fromViewController
                                              identifier:(NSString *)identifier {
    
    if ([identifier isEqualToString:@"appSegueUnwind"]) {
    
        UIStoryboardSegue *unwindSegue = [AppSegueUnwind segueWithIdentifier:@"appSegueUnwind"
                                                                      source:fromViewController
                                                                 destination:toViewController
                                                              performHandler:^{
                                                                  nil;
                                                              }];
        return unwindSegue;
    }
    return [super segueForUnwindingToViewController:toViewController
                                 fromViewController:fromViewController
                                         identifier:identifier];
}


//取消按钮点击高亮
- (BOOL)tableView: (UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}


@end
