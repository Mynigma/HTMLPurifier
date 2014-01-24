//
//  HTMLPurifier_AttrTransform_ScriptRequired.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform.h"

/**
 * Implements required attribute stipulation for <script>
 */
@interface HTMLPurifier_AttrTransform_ScriptRequired : HTMLPurifier_AttrTransform

- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;

@end
