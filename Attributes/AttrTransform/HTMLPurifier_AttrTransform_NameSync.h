//
//  HTMLPurifier_AttrTransform_NameSync.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HTMLPurifier_AttrTransform.h"

@class HTMLPurifier_AttrDef_HTML_ID;

/**
 * Post-transform that performs validation to the name attribute; if
 * it is present with an equivalent id attribute, it is passed through;
 * otherwise validation is performed.
 */
@interface HTMLPurifier_AttrTransform_NameSync : HTMLPurifier_AttrTransform

@property HTMLPurifier_AttrDef_HTML_ID* idDef;


- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;


@end
