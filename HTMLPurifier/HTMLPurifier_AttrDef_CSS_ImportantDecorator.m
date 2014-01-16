//
//  HTMLPurifier_AttrDef_CSS_ImportantDecorator.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 15.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

/**
 * Decorator which enables !important to be used in CSS values.
 */

#import "HTMLPurifier_AttrDef_CSS_ImportantDecorator.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_CSS_ImportantDecorator

/**
 * @type HTMLPurifier_AttrDef
 */
@synthesize def;
/**
 * @type bool
 */
@synthesize allow;

/**
 * @param HTMLPurifier_AttrDef $def Definition to wrap
 * @param bool $allow Whether or not to allow !important
 */
-(id) initWithDef:(HTMLPurifier_AttrDef*)ndef AllowImportnat:(NSNumber*)nallow
{
    self = [super init];
    def = ndef;
    allow = nallow;
    return self;
}

/**
 * Intercepts and removes !important if necessary
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    // test for ! and important tokens
    string = trim(string);
    BOOL is_important = NO;
    
    // :TODO: optimization: test directly for !important and ! important
    if (([string length] >= 9) && ([[string substringFromIndex:[string length]-9] isEqual:@"important"]))
    {
        NSString* temp = rtrim([string substringWithRange:NSMakeRange(0,[string length]-9)]);
        // use a temp, because we might want to restore important
        if (([temp length] >= 1) && ([[temp substringFromIndex:[temp length]-1] isEqual:@"!"]))
        {
            string = rtrim([temp substringFromIndex:[temp length]-1]);
            is_important = YES;
        }
    }
    
    string = [def validateWithString:string config:config context:context];
    if (allow && is_important)
    {
        string = [string stringByAppendingString:@" !important"];
    }
    return string;
}

@end
