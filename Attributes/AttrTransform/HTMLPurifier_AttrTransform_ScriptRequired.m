//
//  HTMLPurifier_AttrTransform_ScriptRequired.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform_ScriptRequired.h"

/**
 * Implements required attribute stipulation for <script>
 */
@implementation HTMLPurifier_AttrTransform_ScriptRequired


/**
 * @param array $attr
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (!attr[@"type"])
    {
        NSMutableDictionary* attr_m = [attr mutableCopy];
        [attr_m setObject:@"text/javascript" forKey:@"type"];
        if (![sortedKeys containsObject:@"type"])
            [sortedKeys addObject:@"type"];
        return attr_m;
    }
    return attr;
}

@end
