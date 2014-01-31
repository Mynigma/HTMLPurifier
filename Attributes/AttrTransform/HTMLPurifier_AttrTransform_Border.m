//
//  HTMLPurifier_AttrTransform_Border.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.


#import "HTMLPurifier_AttrTransform_Border.h"

/**
 * Pre-transform that changes deprecated border attribute to CSS.
 */
@implementation HTMLPurifier_AttrTransform_Border

/**
 * @param array $attr
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (!attr[@"border"]) {
        return attr;
    }
    
    NSMutableDictionary* attr_m = [attr mutableCopy];
    
    NSObject* border_width = [self confiscateAttr:attr_m sortedKeys:sortedKeys key:@"border"];
    // some validation should happen here
    [self prependCSS:attr_m sortedKeys:sortedKeys css:[NSString stringWithFormat:@"border:{%@}px solid;",border_width]];
    return attr_m;
}

@end
