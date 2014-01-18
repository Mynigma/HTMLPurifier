//
//  HTMLPurifier_AttrDef_Enum.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_Enum.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_Enum

- (id)init
{
    return [self initWithValidValues:nil caseSensitive:NO];
}

- (id)initWithValidValues:(NSArray*)array
{
    return [self initWithValidValues:array caseSensitive:NO];
}


- (id)initWithValidValues:(NSArray*)array caseSensitive:(BOOL)newCaseSensitive
{
    self = [super init];
    if (self) {
        _validValues = [array mutableCopy];
        _caseSensitive = newCaseSensitive;
    }
    return self;
}

- (NSString*)validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context *)context
{
    NSString* newString = trim(string);
    if(!self.caseSensitive)
    {
        newString = [newString lowercaseString];
    }
    BOOL result = NO;

    //TO DO: fix
    //validValues is sometimes set to a string
    
    if([self.validValues isKindOfClass:[NSArray class]])
        result = [self.validValues containsObject:newString];

    return result?newString:nil;
}

- (HTMLPurifier_AttrDef_Enum*)makeWithString:(NSString*)string;
{
    BOOL sensitive;
    if (string.length > 2 && [string characterAtIndex:0] == 's' && [string characterAtIndex:1] == ':') {
        string = substr(string, 2);
        sensitive = YES;
    } else {
        sensitive = NO;
    }
    NSArray* values = explode(@",", string);
    return [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:values caseSensitive:sensitive];
}


@end
