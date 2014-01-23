//
//  HTMLPurifier_AttrTransform_BoolToCSS.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform.h"

/**
 * Pre-transform that changes converts a boolean attribute to fixed CSS
 */
@interface HTMLPurifier_AttrTransform_BoolToCSS : HTMLPurifier_AttrTransform


/**
 * Name of boolean attribute that is trigger.
 * @type string
 */
@property NSString* attr;

/**
 * CSS declarations to add to style, needs trailing semicolon.
 * @type string
 */
@property NSString* css;


-(id) initWithAttr:(NSString*)nattr andCSS:(NSString*)ncss;


- (NSDictionary*)transform:(NSDictionary*)attr config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;

@end
