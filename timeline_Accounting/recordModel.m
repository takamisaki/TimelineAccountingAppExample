
#import "recordModel.h"

@implementation recordModel

//两个字典转模型方法的实现

- (instancetype)initWithDict: (NSDictionary *)dict {
    
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}


+ (instancetype)recordModelInitWithDict: (NSDictionary *)dict {
 
    return [[recordModel alloc] initWithDict:dict];
}


@end
