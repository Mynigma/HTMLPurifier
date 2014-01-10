//
//  HTMLPurifier_CSSDefinition.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HTMLPurifier_CSSDefinition : HTMLPurifier_Definition

@property NSString* type;
@property NSMutableDictionary* info;

@end
