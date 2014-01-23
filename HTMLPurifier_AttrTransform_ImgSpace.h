//
//  HTMLPurifier_AttrTransform_ImgSpace.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform.h"

/**
 * Pre-transform that changes deprecated hspace and vspace attributes to CSS
 */
@interface HTMLPurifier_AttrTransform_ImgSpace : HTMLPurifier_AttrTransform

/**
 * @type string
 */
@property NSString* attr_s;

/**
 * @type array
 */
@property NSDictionary* css;


- (NSDictionary*)transform:(NSDictionary*)attr config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;

-(id) initWithAttr:(NSString*) attr;

@end
