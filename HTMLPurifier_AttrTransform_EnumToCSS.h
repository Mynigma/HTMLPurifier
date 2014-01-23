//
//  HTMLPurifier_AttrTransform_EnumToCSS.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform.h"

/**
 * Generic pre-transform that converts an attribute with a fixed number of
 * values (enumerated) to CSS.
 */
@interface HTMLPurifier_AttrTransform_EnumToCSS : HTMLPurifier_AttrTransform

/**
 * Name of attribute to transform from.
 * @type string
 */
protected $attr;

/**
 * Lookup array of attribute values to CSS.
 * @type array
 */
protected $enumToCSS = array();

/**
 * Case sensitivity of the matching.
 * @type bool
 * @warning Currently can only be guaranteed to work with ASCII
 *          values.
 */
protected $caseSensitive = false;

@end
