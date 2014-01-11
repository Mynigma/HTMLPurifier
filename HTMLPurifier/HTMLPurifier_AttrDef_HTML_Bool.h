//
//  HTMLPurifier_AttrDef_HTML_Bool.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HTMLPurifier_AttrDef.h"

/**
 * Validates a boolean attribute
 */
@interface HTMLPurifier_AttrDef_HTML_Bool :HTMLPurifier_AttrDef

@property BOOL name;

@property BOOL minimized;

-(id)initWithName:(BOOL)newName;

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */

-(BOOL) validateWithString:(NSString*)string Config:(HTMLPurifier_Config*)config Context:(HTMLPurifier_Context*)context;

/**
 * @param string $string Name of attribute
 * @return HTMLPurifier_AttrDef_HTML_Bool
 */
-(HTMLPurifier_AttrDef_HTML_Bool*) makeWithString:(NSString*)string;


@end
