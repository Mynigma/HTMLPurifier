//
//  HTMLPurifier_AttrDef_CSS_Outline.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 15.08.15.
//  Copyright (c) 2015 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef.h"

@interface HTMLPurifier_AttrDef_CSS_Outline : HTMLPurifier_AttrDef

@property NSDictionary* info;



- (id)initWithConfig:(HTMLPurifier_Config*)config;

- (NSString*)validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;

@end
