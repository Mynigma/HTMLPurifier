//
//  HTMLPurifier_AttrDef_URI_Email_SimpleCheck.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_URI_Email_SimpleCheck.h"

@implementation HTMLPurifier_AttrDef_URI_Email_SimpleCheck

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
public function validate($string, $config, $context)
{
    // no support for named mailboxes i.e. "Bob <bob@example.com>"
    // that needs more percent encoding to be done
    if ($string == '') {
        return false;
    }
    $string = trim($string);
    $result = preg_match('/^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i', $string);
    return $result ? $string : false;
}

@end
