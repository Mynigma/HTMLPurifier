//
//  HTMLPurifier_AttrDef_HTML_LinkTypes.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef.h"

@interface HTMLPurifier_AttrDef_HTML_LinkTypes : HTMLPurifier_AttrDef

/**
 * Name config attribute to pull.
 * @type string
 */
@property NSString* name;

/**
 * @param string newName
 */
-(id) initWithName:(NSString*)newName;

@end
