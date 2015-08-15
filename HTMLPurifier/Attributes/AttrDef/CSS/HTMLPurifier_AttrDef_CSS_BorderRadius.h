//
//  HTMLPurifier_AttrDef_CSS_BorderRadius.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 15.08.15.
//  Copyright (c) 2015 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef.h"

@interface HTMLPurifier_AttrDef_CSS_BorderRadius : HTMLPurifier_AttrDef
/**
 * Validates the border-radius property as defined by CSS.
 */

- (NSString*)validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;

@end

