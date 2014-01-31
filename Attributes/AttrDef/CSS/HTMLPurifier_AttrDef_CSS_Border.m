//
//  HTMLPurifier_AttrDef_CSS_Border.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_CSS_Border.h"
#import "HTMLPurifier_CSSDefinition.h"
#import "BasicPHP.h"


@implementation HTMLPurifier_AttrDef_CSS_Border

- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super init];
    if (self) {
        info = [NSMutableDictionary new];
        HTMLPurifier_CSSDefinition* def = [config getCSSDefinition];
        info[@"border-width"] = def.info[@"border-width"];
        info[@"border-style"] = def.info[@"border-style"];
        info[@"border-top-color"] = def.info[@"border-top-color"];
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
                HTMLPurifier_AttrDef_CSS_Border* validator = [self->info objectForKey:propname];
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
