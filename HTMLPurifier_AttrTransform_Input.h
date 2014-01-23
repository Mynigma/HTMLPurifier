//
//  HTMLPurifier_AttrTransform_Input.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform.h"

/**
 * Performs miscellaneous cross attribute validation and filtering for
 * input elements. This is meant to be a post-transform.
 */
@interface HTMLPurifier_AttrTransform_Input : HTMLPurifier_AttrTransform

/**
* @type HTMLPurifier_AttrDef_HTML_Pixels
*/
protected $pixels;

@end
