//
//  HTMLPurifier_AttrDef_Text.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_Text.h"

/**
 * Validates arbitrary text according to the HTML spec.
 */

@implementation HTMLPurifier_AttrDef_Text

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    return [super parseCDATAWithString:string];
}

@end
