//
//   HTMLPurifier_ChildDef.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 15.01.14.


#import "HTMLPurifier_ChildDef.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import <objc/runtime.h>


/**
 * Defines allowed child nodes and validates nodes against it.
 */

@implementation HTMLPurifier_ChildDef


- (id)init
{
    self = [super init];
    if (self) {
        _elements = [NSMutableDictionary new];
    }
    return self;
}



- (NSMutableDictionary*)getAllowedElements:(HTMLPurifier_Config*)config
{
    return self.elements;
}

/**
 * Validates nodes according to definition and returns modification.
 *
 * @param HTMLPurifier_Node[] $children Array of HTMLPurifier_Node
 * @param HTMLPurifier_Config $config HTMLPurifier_Config object
 * @param HTMLPurifier_Context $context HTMLPurifier_Context object
 * @return bool|array true to leave nodes as is, false to remove parent node, array of replacement children
 */
- (NSObject*)validateChildren:(NSArray*)children config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    return nil;
}





@end
