//
//  HTMLPurifier_AttrTransform_Background.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 22.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

/**
 * Pre-transform that changes proprietary background attribute to CSS.
 */
#import "HTMLPurifier_AttrTransform.h"

@interface HTMLPurifier_AttrTransform_Background : HTMLPurifier_AttrTransform

- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;

@end
