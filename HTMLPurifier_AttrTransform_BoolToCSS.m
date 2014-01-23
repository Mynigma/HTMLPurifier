//
//  HTMLPurifier_AttrTransform_BoolToCSS.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform_BoolToCSS.h"

/**
 * Pre-transform that changes converts a boolean attribute to fixed CSS
 */
@implementation HTMLPurifier_AttrTransform_BoolToCSS

/**
 * Name of boolean attribute that is trigger.
 * @type string
 */
@synthesize attr;

/**
 * CSS declarations to add to style, needs trailing semicolon.
 * @type string
 */
@synthesize css;


-(id) initWithAttr:(NSString*)nattr andCSS:(NSString*)ncss
{
    self = [super init];
    attr = nattr;
    css = ncss;
    return self;
}

/**
 * @param array $attr
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSDictionary*)transform:(NSDictionary*)attr_d sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (!attr_d[attr])
    {
        return attr_d;
    }
    NSMutableDictionary* attr_m = [attr_d mutableCopy];
    
    [attr_m removeObjectForKey:attr];
    
    [self prependCSS:attr_m css:css];
    
    return attr_m;
}


@end
