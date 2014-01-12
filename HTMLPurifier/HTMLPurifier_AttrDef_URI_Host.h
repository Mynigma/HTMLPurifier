//
//  HTMLPurifier_AttrDef_URI_Host.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef.h"
#import "HTMLPurifier_AttrDef_URI_IPv4.h"
#import "HTMLPurifier_AttrDef_URI_IPv6.h"


@interface HTMLPurifier_AttrDef_URI_Host : HTMLPurifier_AttrDef

/**
 * IPv4 sub-validator.
 * @type HTMLPurifier_AttrDef_URI_IPv4
 */
@property HTMLPurifier_AttrDef_URI_IPv4* ipv4;

/**
 * IPv6 sub-validator.
 * @type HTMLPurifier_AttrDef_URI_IPv6
 */
@property HTMLPurifier_AttrDef_URI_IPv6* ipv6;

@end
