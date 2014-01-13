//
//  HTMLPurifier_AttrDef_URI_Email_SimpleCheck.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_URI_Email_SimpleCheck.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_URI_Email_SimpleCheck

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    // no support for named mailboxes i.e. "Bob <bob@example.com>"
    // that needs more percent encoding to be done
    if ([string isEqual:@""])
    {
        return nil;
    }
    string = trim(string);
    result = preg_match(@"/^[A-Z0-9._%-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$",string);
    return result ? string : nil;
}

@end
