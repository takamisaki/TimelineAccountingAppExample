

#import "Record.h"

NS_ASSUME_NONNULL_BEGIN

@interface Record (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *count;        //金额(@"￥5.67")这种样式
@property (nullable, nonatomic, retain) NSString *icon;         //中间图标
@property (nullable, nonatomic, retain) NSString *subType;      //子分类(比如支出下面的子分类)
@property (nullable, nonatomic, retain) NSString *type;         //主分类(收入/支出)

@end

NS_ASSUME_NONNULL_END
