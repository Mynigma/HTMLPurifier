//
//  HTMLPurifier_AttrTransform_Lang.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform_Lang.h"

/**
 * Post-transform that copies lang's value to xml:lang (and vice-versa)
 * @note Theoretically speaking, this could be a pre-transform, but putting
 *       post is more efficient.
 */
@implementation HTMLPurifier_AttrTransform_Lang

/**
 * @param array $attr
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    NSObject* lang = attr[@"lang"] ? attr[@"lang"] : nil;
    
    NSObject* xml_lang = attr[@"xml:lang"] ? attr[@"xml:lang"] : nil;
    
    NSMutableDictionary* attr_m = [attr mutableCopy];
    
    if (lang && !xml_lang)
    {
        [attr_m setObject:lang forKey:@"xml:lang"];
    }
    else if (xml_lang)
    {
        [attr_m setObject:xml_lang forKey:@"lang"];
    }
    return attr_m;
}

@end
