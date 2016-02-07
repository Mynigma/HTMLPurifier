//
//   HTMLPurifier_AttrTransform.h
//   HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.


#import <Foundation/Foundation.h>
#import "AutoCodingObject.h"




@class HTMLPurifier_Config, HTMLPurifier_Context;

@interface HTMLPurifier_AttrTransform : AutoCodingObject


- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;

- (void)prependCSS:(NSMutableDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys css:(NSString*)css;

- (NSObject*)confiscateAttr:(NSMutableDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys key:(NSString*)key;

@end
