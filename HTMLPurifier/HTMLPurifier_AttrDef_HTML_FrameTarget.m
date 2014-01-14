//
//  HTMLPurifier_AttrDef_HTML_FrameTarget.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 11.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_HTML_FrameTarget.h"

@implementation HTMLPurifier_AttrDef_HTML_FrameTarget

/**
 * @type array
 */
@synthesize valid_values;

/**
 * @type bool
 */
@synthesize case_sensitive;

-(id) init
{
    self = [super init];
    return self;
}

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    if (!valid_values)
    {
        valid_values = (NSMutableArray*)[[config get:@"Attr.AllowedFrameTargets"] mutableCopy];
    }
    return [super validateWithString:string config:config context:context];
}

@end
