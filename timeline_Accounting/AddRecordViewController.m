#import "AddRecordViewController.h"
#import "ChooseCell.h"
#import "ChooseCollectionView.h"
#import "showChoiceView.h"
#import "recordModel.h"
#import "AppDelegate.h"

//打印简洁化
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

@interface AddRecordViewController () <UICollectionViewDelegate,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak  ) IBOutlet UIBarButtonItem      *cancelButton;          //顶部取消按钮
@property (nonatomic, weak  ) IBOutlet ChooseCollectionView *chooseCollectionView;  //分类view
@property (nonatomic, weak  ) IBOutlet showChoiceView       *showChoiceViewInstance;//计算显示view
@property (nonatomic, strong) NSMutableArray<recordModel *> *iconAndSubTypeArray;   //显示分类图标用
@property (nonatomic, strong) UITapGestureRecognizer        *tapGesture;            //解决tap手势冲突
@property (nonatomic, strong) NSManagedObjectContext        *managedObjectContext;  //coreData上下文
@end



@implementation AddRecordViewController


#pragma mark 视图载入前
/*
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ Mindset:
 ┃ 1.从 plist获取分类的种类数组,用以显示
 ┃ 2.获取 coreData 上下文, 准备删除和更改
 ┃ 3.配置 collectionview
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 */
- (void)viewWillAppear: (BOOL)animated {
    
    [self prepareIconAndSubTypeArray];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    _managedObjectContext    = appDelegate.managedObjectContext;
    
    //如果数据有内容, 就进行更改, 配置视图显示数据的图标和分类, 数值
//    if (_record) {
    if (!self.isFromAdd) {
    
        _showChoiceViewInstance.countLabel.text      = [self.record valueForKey:@"count"];
        _showChoiceViewInstance.iconNameChoosed.text = [self.record valueForKey:@"subType"];
        _showChoiceViewInstance.iconChoosed.image    = [UIImage imageNamed:[self.record valueForKey:@"icon"]];
    
        
    //如果数据空, 就进行插入空白数据
    } else {
        self.showChoiceViewInstance.countLabel.text      = @"￥0.00"; //数值栏默认显示
        self.showChoiceViewInstance.iconNameChoosed.text = @"默认";
        self.showChoiceViewInstance.iconChoosed.image    = [UIImage imageNamed:@"defaultMiddle"];
        self.record = [NSEntityDescription insertNewObjectForEntityForName:@"Record"
                                                    inManagedObjectContext:_managedObjectContext];
    }
    
    self.chooseCollectionView.delegate   = self;
    self.chooseCollectionView.dataSource = self;
    self.chooseCollectionView.alwaysBounceVertical = YES;
    [self.chooseCollectionView registerClass:[ChooseCell class] forCellWithReuseIdentifier:@"chooseCell"];

}



#pragma mark 视图载入后+OK 按钮保存事件
/*
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ Mindset:
 ┃ 1.配置 OK 按钮 block
 ┃ 2.配置输入框事件, 用于恢复隐藏的键盘
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 */
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self tapGestureConfig]; //手势冲突解决(否则 cell 需要长按才能激活点击事件)
    
    self.showChoiceViewInstance.buttonOKClicked = ^(){
        
        //按 OK 时,如果输入框是默认值, 不保存
        if ([self.showChoiceViewInstance.countLabel.text isEqualToString:@"￥0.00"]) {
            [_managedObjectContext rollback];
            
        //如果输入框有值, 保存
        } else {
            
            //如果没有点击collectionView 的 Item, 只是通过默认来添加的记录
            if ([self.showChoiceViewInstance.iconNameChoosed.text isEqualToString:@"默认"]) {
                [_record setValue:@"defaultMiddle" forKey:@"icon"];
            }
            
            [_record setValue:_showChoiceViewInstance.countLabel.text forKey:@"count"  ];
            [_record setValue:_showChoiceViewInstance.iconNameChoosed.text forKey:@"subType"];
            
            if ([_managedObjectContext save:nil]) {
                NSLog(@"saved"); //保存成功提示
            }
        }
        
        //如果是 add 跳转来的, 用 dismiss
        if (self.isFromAdd) {
            self.isFromAdd = NO;
            [self dismissViewControllerAnimated:YES completion:^{ nil; }];
            
        //如果是 modify 调整来的, 用 unwind
        } else {
        [self performSegueWithIdentifier:@"appSegueUnwind" sender:self];
        }
    };
    
    
    //输入框激活隐藏键盘事件
    [_showChoiceViewInstance.coverButton addTarget:self
                                           action:@selector(coverButtonClicked)
                                 forControlEvents:UIControlEventTouchUpInside];
}


//取消按钮事件: 不保存, 直接回到另一界面
- (IBAction)cancelButtonClicked: (UIBarButtonItem *)sender {
    
    self.isFromAdd = NO;
    
    [_managedObjectContext rollback];
    
    [self dismissViewControllerAnimated:YES completion:^{ nil; }];

}


#pragma mark 输入框点击(键盘恢复动画)
/*
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ Mindset:
 ┃ 1.判断此时键盘是否隐藏
 ┃ 2.如果隐藏则 collectionview 缩短, 键盘 view 变长
 ┃ 3.如果没隐藏则不反应
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 */
- (void)coverButtonClicked {
    
    //如果在隐藏
    if (self.view.frame.size.height - self.showChoiceViewInstance.frame.origin.y
        < self.showChoiceViewInstance.frame.size.height) {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect viewBelowFrame              = _showChoiceViewInstance.frame;
                             CGRect viewAboveFrame              = _chooseCollectionView.frame;
                             viewAboveFrame.size.height        -= 190;
                             viewBelowFrame.origin.y           -= 190;
                             self.showChoiceViewInstance.frame  = viewBelowFrame;
                             self.chooseCollectionView.frame    = viewAboveFrame;
                         }];
    }
    
    //如果没有隐藏
    return;
}


//解决tap手势冲突
- (void)tapGestureConfig {
    
    self.tapGesture = [UITapGestureRecognizer new];
    self.tapGesture.cancelsTouchesInView = NO;
}


#pragma mark 读取 plist, 生成图标和子分类的数组
- (void)prepareIconAndSubTypeArray {
    
    self.iconAndSubTypeArray  = [NSMutableArray new];
    NSString *path            = [[NSBundle mainBundle] pathForResource:@"recordIconAndSubType.plist"
                                                                ofType:nil];
    NSArray *dataOrginalArray = [NSArray arrayWithContentsOfFile:path];
    
    for (NSDictionary *dict in dataOrginalArray) {
        
        recordModel *model = [recordModel recordModelInitWithDict:dict];
        [self.iconAndSubTypeArray addObject:model];
    }
}



#pragma mark cell点击后的动画和传值
/*
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ Mindset:
 ┃ 1.取得动画移动的起始位置和目标位置
 ┃ 2.动画设置: 建立一个同图标的 imageView, 移动动画结束后移除
 ┃ 3.传值并显示
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 */
- (void)collectionView: (UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //1. 取得点击对应的model 数据
    __block recordModel *modelClicked = self.iconAndSubTypeArray[indexPath.item];
    
    CGRect cellClickedFrame = [collectionView.collectionViewLayout   //取得点击的 item 的 frame
                               layoutAttributesForItemAtIndexPath:indexPath].frame;
    
    //2. 算出该item 的 icon 的 frame
    cellClickedFrame.origin.x   += 10;
    cellClickedFrame.origin.y   += 64;
    cellClickedFrame.size.height = 70;
    cellClickedFrame.size.width  = 70;
    
    //3. 点击后给 record 的属性(图标, 收支大分类, 收支子分类)赋值 (预先准备 OK 点击的保存)
    NSString *cellRecordType     = [self.iconAndSubTypeArray[indexPath.item] valueForKey:@"type"];
    [_record setValue:cellRecordType forKey:@"type"];
    [_record setValue:self.iconAndSubTypeArray[indexPath.item].icon forKey:@"icon"];
    [_record setValue:self.iconAndSubTypeArray[indexPath.item].subType forKey:@"subType"];
    
    //4. 生成一个和点击的 item 的 icon 相同的 UIImageView, 用于动画
    __block UIImageView *iconCopyView = [[UIImageView alloc] initWithFrame:cellClickedFrame];
    iconCopyView.image = [UIImage imageNamed:[modelClicked valueForKey:@"icon"]];
    [self.view addSubview:iconCopyView];
    
    //5. 算出动画终止位置和大小(frame)
    CGRect viewBelowFrame = CGRectMake(7, 491, 50, 50);
    
    //6. 设置动画
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         iconCopyView.frame = viewBelowFrame;
                     }
                     completion:^(BOOL finished) {
                         //传值
                         weakSelf.showChoiceViewInstance.iconNameChoosed.text = modelClicked.subType;
                         weakSelf.showChoiceViewInstance.iconChoosed.image = [UIImage imageNamed:modelClicked.icon];
                         [iconCopyView removeFromSuperview];
                     }];
}


//两个 delegate 方法的 implementation
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView: (UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    return self.iconAndSubTypeArray.count;
}


#pragma mark cell 展示的内容, 根据 plist 的 model数组进行配置
- (UICollectionViewCell *)collectionView: (UICollectionView *)collectionView
                  cellForItemAtIndexPath: (NSIndexPath *)indexPath {
    
    ChooseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"chooseCell"
                                                                 forIndexPath:indexPath];
    
    cell.chooseLabel.text          = self.iconAndSubTypeArray[indexPath.item].subType;
    cell.chooseIcon.image          = [UIImage imageNamed:self.iconAndSubTypeArray[indexPath.item].icon];
    
    [cell.contentView addSubview:cell.chooseIcon ];
    [cell.contentView addSubview:cell.chooseLabel];
    
    return cell;
}



#pragma mark collectionView 滚动事件:  键盘隐藏动画, collectionView 扩大动画
- (void)scrollViewWillBeginDragging: (UIScrollView *)scrollView {
    
    if (self.showChoiceViewInstance.frame.origin.y == 481) {
        
        [UIView animateWithDuration:0.3
                              delay:0
             usingSpringWithDamping:0.4
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGRect viewBelowFrame             = self.showChoiceViewInstance.frame;
                             CGRect viewAboveFrame             = self.chooseCollectionView.frame;
                             viewAboveFrame.size.height       += 190;
                             viewBelowFrame.origin.y          += 190;
                             self.showChoiceViewInstance.frame = viewBelowFrame;
                             self.chooseCollectionView.frame   = viewAboveFrame;
                         } completion:^(BOOL finished) {
                             nil;
                         }];
    }
    
}

@end
