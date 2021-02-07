#import <Foundation/Foundation.h>

@interface LiteADLibrary : NSObject

+(LiteADLibrary*)shared;
- (NSDictionary*)getInfo;

@end
