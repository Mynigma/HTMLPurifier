//
//  HTMLPurifier_AttrDef_CSS_Ident.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 15.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//


/**
 * Validates based on {ident} CSS grammar production
 */

#import "HTMLPurifier_AttrDef_CSS_Ident.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_CSS_Ident


/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    string = trim(string);
    
    // early abort: '' and '0' (strings that convert to false) are invalid
    if ([string isEqual:@""] || [string isEqual:@"0"]) {
        return nil;
    }
    
    NSString* pattern = @"^(-?[A-Za-z_][A-Za-z_\\-0-9]*)$";
    if (!preg_match_2(pattern, string)) {
        return nil;
    }
    return string;
}

@end
