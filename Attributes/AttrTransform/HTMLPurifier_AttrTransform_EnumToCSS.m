//
//  HTMLPurifier_AttrTransform_EnumToCSS.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform_EnumToCSS.h"
#import "BasicPHP.h"

/**
 * Generic pre-transform that converts an attribute with a fixed number of
 * values (enumerated) to CSS.
 */
@implementation HTMLPurifier_AttrTransform_EnumToCSS


/**
 * Name of attribute to transform from.
 * @type string
 */
@synthesize attr_s;

/**
 * Lookup array of attribute values to CSS.
 * @type array
 */
@synthesize enumToCSS; // = array();

/**
 * Case sensitivity of the matching.
 * @type bool
 * @warning Currently can only be guaranteed to work with ASCII
 *          values.
 */
@synthesize caseSensitive; // = false;

/**
 * @param string attr Attribute name to transform from
 * @param array enum_to_css Lookup array of attribute values to CSS
 * @param bool case_sensitive Case sensitivity indicator, default false
 */
-(id) initWithAttr:(NSString*)attr enum:(NSDictionary*)enum_to_css caseSensitive:(NSNumber*)case_sensitive
{
    self = [super init];
    attr_s = attr;
    enumToCSS = enum_to_css;
    if (case_sensitive)
        caseSensitive = case_sensitive;
    else
        caseSensitive = @NO;
    
    return self;
}

/**
 * @param array attr
 * @param HTMLPurifier_Config config
 * @param HTMLPurifier_Context context
 * @return array
 */
- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (!attr[attr_s])
    {
        return attr;
    }
    
    NSString* value = trim(attr[attr_s]);
    NSMutableDictionary* attr_m = [attr mutableCopy];
    [attr_m removeObjectForKey:attr_s];
    [sortedKeys removeObject:attr_s];

    
    if (!caseSensitive)
    {
        value = [value lowercaseString];
    }
    
    if (!enumToCSS[value])
    {
        return attr_m;
    }
    [self prependCSS:attr_m sortedKeys:sortedKeys css:enumToCSS[value]];
    return attr_m;
}


@end
