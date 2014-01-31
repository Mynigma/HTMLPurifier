//
//   HTMLPurifier_AttrTransform_SafeObject.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.


#import "HTMLPurifier_AttrTransform_SafeObject.h"

/**
 * Writes default type for all objects. Currently only supports flash.
 */
@implementation HTMLPurifier_AttrTransform_SafeObject

/**
 * @type string
 */
@synthesize name; // = "SafeObject";

-(id) init
{
    self = [super init];
    name = @"SafeObject";
    return self;
}

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
        [attr_m setObject:@"application/x-shockwave-flash" forKey:@"type"];
        [sortedKeys addObject:@"type"];
        return attr_m;
    }
    return attr;
}

@end
