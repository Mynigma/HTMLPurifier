//
//  HTMLPurifier_AttrDef_Enum.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef.h"

@interface HTMLPurifier_AttrDef_Enum : HTMLPurifier_AttrDef
{
    BOOL caseSensitive;
}


@property NSMutableDictionary* validValues;

- (id)init;
- (id)initWithValidValues:(NSArray*)array;
- (id)initWithValidValues:(NSArray*)array caseSensitive:(BOOL)newCaseSensitive;


- (NSString*)validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context *)context;

- (HTMLPurifier_AttrDef_Enum*)makeWithString:(NSString*)string;


@end
