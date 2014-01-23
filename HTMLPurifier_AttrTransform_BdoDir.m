//
//  HTMLPurifier_AttrTransform_BdoDir.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 22.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform_BdoDir.h"
#import "HTMLPurifier_Config.h"

// this MUST be placed in post, as it assumes that any value in dir is valid

/**
 * Post-trasnform that ensures that bdo tags have the dir attribute set.
 */
@implementation HTMLPurifier_AttrTransform_BdoDir

/**
 * @param array $attr
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSDictionary*)transform:(NSDictionary*)attr config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (attr[@"dir"])
    {
        return attr;
    }
    NSMutableDictionary* attr_m = [attr mutableCopy];
    [attr_m setValue:[config get:@"Attr.DefaultTextDir"] forKey:@"dir"];
    
    return attr_m;
}

@end
