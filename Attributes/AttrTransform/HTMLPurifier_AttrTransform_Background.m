//
//  HTMLPurifier_AttrTransform_Background.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 22.01.14.


/**
 * Pre-transform that changes proprietary background attribute to CSS.
 */
#import "HTMLPurifier_AttrTransform_Background.h"

@implementation HTMLPurifier_AttrTransform_Background

/**
 * @param array $attr
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (!attr[@"background"])
    {
        return attr;
    }
    
    NSMutableDictionary* attr_m = [attr mutableCopy];
    
    NSObject* background = [self confiscateAttr:attr_m sortedKeys:sortedKeys key:@"background"];
    // some validation should happen here
    
    [self prependCSS:attr_m sortedKeys:sortedKeys css:[NSString stringWithFormat:@"background-image:url(%@);",background]];
    return attr_m;
}

@end
