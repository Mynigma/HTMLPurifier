//
//   HTMLPurifier_AttrTransform_Textarea.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.


#import "HTMLPurifier_AttrTransform_Textarea.h"

/**
 * Sets height/width defaults for <textarea>
 */
@implementation HTMLPurifier_AttrTransform_Textarea

/**
 * @param array $attr
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    // Calculated from Firefox
    NSMutableDictionary* attr_m = [attr mutableCopy];
    
    if (!attr_m[@"cols"])
    {
        [attr_m setObject:@"22" forKey:@"cols"];
        if (![sortedKeys containsObject:@"cols"])
            [sortedKeys addObject:@"cols"];
    }
    if (!attr_m[@"rows"])
    {
        [attr_m setObject:@"3" forKey:@"rows"];
        if (![sortedKeys containsObject:@"rows"])
            [sortedKeys addObject:@"rows"];
    }
    return attr_m;
}

@end
