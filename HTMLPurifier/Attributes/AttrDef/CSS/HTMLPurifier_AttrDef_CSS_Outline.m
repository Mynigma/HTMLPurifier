//
//  HTMLPurifier_AttrDef_CSS_Outline.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 15.08.15.
//  Copyright (c) 2015 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_CSS_Outline.h"
#import "HTMLPurifier_CSSDefinition.h"
#import "BasicPHP.h"


@implementation HTMLPurifier_AttrDef_CSS_Outline

- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super init];
    if (self) {
        NSMutableDictionary* tempInfo = [NSMutableDictionary new];
        HTMLPurifier_CSSDefinition* def = [config getCSSDefinition];
        tempInfo[@"outline-color"] = def.info[@"outline-color"];
        tempInfo[@"outline-style"] = def.info[@"outline-style"];
        tempInfo[@"outline-width"] = def.info[@"outline-width"];
        _info = tempInfo;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _info = [coder decodeObjectForKey:@"info"];
    }
    return self;
}



- (void)encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_info forKey:@"info"];
}


- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else if(![other isKindOfClass:[HTMLPurifier_AttrDef_CSS_Outline class]])
    {
        return NO;
    }
    else
    {
        return (!self.info && ![(HTMLPurifier_AttrDef_CSS_Outline*)other info]) || [self.info isEqual:[(HTMLPurifier_AttrDef_CSS_Outline*)other info]];
    }
}

- (NSUInteger)hash
{
    return [_info hash] ^ [super hash];
}







/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
- (NSString*)validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    string = [self parseCDATAWithString:string];
    string = [self mungeRgbWithString:string];
    NSArray* bits = explode(@" ", string);
    NSMutableDictionary* done = [NSMutableDictionary new]; // segments we've finished
    NSMutableString* ret = [@"" mutableCopy]; // return value
    for(NSString* bit in bits)
    {
        for(NSString* propname in self.info)
        {
            HTMLPurifier_AttrDef_CSS_Outline* validator = [self.info objectForKey:propname];
            if([done objectForKey:propname])
                continue;
            NSString* r = [validator validateWithString:bit config:config context:context];
            if(r)
            {
                [ret appendFormat:@"%@ ", r];
                [done setObject:@YES forKey:propname];
                break;
            }
        }
    }
    return rtrim_whitespaces(ret);
}


@end