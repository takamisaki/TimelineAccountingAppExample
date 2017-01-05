//用来转换 plist 文件的model, 存储图标, 主分类, 子分类,用于 collectionview 的 cell 显示

#import <Foundation/Foundation.h>

@interface recordModel : NSObject

@property (nonatomic, copy) NSString *icon;                 //cell 的图标
@property (nonatomic, copy) NSString *subType;              //cell 的子分类
@property (nonatomic, copy) NSString *type;                 //cell 的主分类

-(instancetype)initWithDict:(NSDictionary *)dict;           //实例方法 字典转模型
+(instancetype)recordModelInitWithDict:(NSDictionary*)dict; //类方法 字典转模型


@end
