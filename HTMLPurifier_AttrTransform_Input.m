//
//  HTMLPurifier_AttrTransform_Input.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform_Input.h"
#import "HTMLPurifier_AttrDef_HTML_Pixels.h"

/**
 * Performs miscellaneous cross attribute validation and filtering for
 * input elements. This is meant to be a post-transform.
 */
@implementation HTMLPurifier_AttrTransform_Input

/**
 * @type HTMLPurifier_AttrDef_HTML_Pixels
 */
@synthesize pixels;

-(id) init
{
    self = [super init];
    pixels = [HTMLPurifier_AttrDef_HTML_Pixels new];
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
    NSString* t = nil;
    
    if (!attr[@"type"])
    {
        t = @"text";
    }
    else
    {
        t =  [attr[@"type"] lowercaseString];
    }
    
    NSMutableDictionary* attr_m = [attr mutableCopy];
    if (attr_m[@"checked"] && ![t isEqual:@"radio"] && ![t isEqual:@"checkbox"])
    {
        [attr_m removeObjectForKey:@"checked"];
    }
    if (attr_m[@"maxlength"] && ![t isEqual:@"text"] && ![t isEqual:@"password"])
    {
        [attr_m removeObjectForKey:@"maxlength"];
    }
    if (attr_m[@"size"] && ![t isEqual:@"text"] && ![t isEqual:@"password"])
    {
        NSString* result = [pixels validateWithString:attr_m[@"size"] config:config context:context];
        
        if (!result)
        {
            [attr_m removeObjectForKey:@"size"];
        }
        else
        {
            [attr_m setObject:result forKey:@"size"];
        }
    }
    if (attr_m[@"src"] && ![t isEqual:@"image"])
    {
        [attr_m removeObjectForKey:@"src"];
    }
    if (!attr_m[@"value"] && ( [t isEqual:@"radio"] || [t isEqual:@"checkbox"]))
    {
        [attr_m setObject:@"" forKey:@"value"];
    }
    return attr_m;
}

@end
