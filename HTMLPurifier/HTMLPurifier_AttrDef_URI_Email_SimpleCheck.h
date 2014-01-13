//
//  HTMLPurifier_AttrDef_URI_Email_SimpleCheck.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_URI_Email.h"

@interface HTMLPurifier_AttrDef_URI_Email_SimpleCheck : HTMLPurifier_AttrDef_URI_Email

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context;

@end
