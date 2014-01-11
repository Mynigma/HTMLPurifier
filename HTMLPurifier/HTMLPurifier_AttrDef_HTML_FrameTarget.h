//
//  HTMLPurifier_AttrDef_HTML_FrameTarget.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 11.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_Enum.h"

@interface HTMLPurifier_AttrDef_HTML_FrameTarget : HTMLPurifier_AttrDef_Enum

@property NSMutableArray* valid_values;

@property BOOL case_sensitive;


@end
