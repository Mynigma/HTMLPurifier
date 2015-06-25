//
//   HTMLPurifier_AttrTransform_BgColor.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.


/**
 * Pre-transform that changes deprecated bgcolor attribute to CSS.
 */
#import "HTMLPurifier_AttrTransform_BgColor.h"

@implementation HTMLPurifier_AttrTransform_BgColor

/**
 * @param array $attr
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (!attr[@"bgcolor"])
    {
        return attr;
    }
    
    NSMutableDictionary* attr_m = [attr mutableCopy];
    NSObject* bgcolor = [self confiscateAttr:attr_m sortedKeys:sortedKeys key:@"bgcolor"];
    // some validation should happen here
    
    [self prependCSS:attr_m sortedKeys:sortedKeys css:[NSString stringWithFormat:@"background-color:%@;",bgcolor]];
    return attr_m;
}

@end
