//
//  HTMLPurifier_AttrTransform_SafeObject.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform.h"

/**
 * Writes default type for all objects. Currently only supports flash.
 */
@interface HTMLPurifier_AttrTransform_SafeObject : HTMLPurifier_AttrTransform

/**
 * @type string
 */
@property NSString* name; // = "SafeObject";

- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;


@end
