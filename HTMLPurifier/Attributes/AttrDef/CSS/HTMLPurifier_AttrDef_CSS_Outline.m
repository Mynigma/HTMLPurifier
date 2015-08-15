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
        info = [NSMutableDictionary new];
        HTMLPurifier_CSSDefinition* def = [config getCSSDefinition];
        info[@"outline-color"] = def.info[@"outline-color"];
        info[@"outline-style"] = def.info[@"outline-style"];
        info[@"outline-width"] = def.info[@"outline-width"];
    }
    return self;
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
        for(NSString* propname in self->info)
        {
            HTMLPurifier_AttrDef_CSS_Outline* validator = [self->info objectForKey:propname];
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