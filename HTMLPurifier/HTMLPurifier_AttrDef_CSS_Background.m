//
//  HTMLPurifier_AttrDef_CSS_Background.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_CSS_Background.h"
#import "HTMLPurifier_CSSDefinition.h"
#import "HTMLPurifier_Config.h"
#import "BasicPHP.h"
#import "HTMLPurifier_AttrDef.h"

@implementation HTMLPurifier_AttrDef_CSS_Background

/**
 * @param HTMLPurifier_Config $config
 */
- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super init];
    if (self) {
        HTMLPurifier_CSSDefinition* def = [config getCSSDefinition];
        info = [NSMutableDictionary new];
        [info setObject:[def.info objectForKey:@"background-color"] forKey:@"background-color"];
        [info setObject:[def.info objectForKey:@"background-image"] forKey:@"background-image"];
        [info setObject:[def.info objectForKey:@"background-repeat"] forKey:@"background-repeat"];
        [info setObject:[def.info objectForKey:@"background-attachment"] forKey:@"background-attachment"];
        [info setObject:[def.info objectForKey:@"background-position"] forKey:@"background-position"];
    }
    return self;
}

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
- (NSString*)validateWithString:(NSString *)someString config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    // regular pre-processing
    NSString* string = [self parseCDATAWithString:someString];
    if ([string isEqualTo:@""]) {
        return nil;
    }

    // munge rgb() decl if necessary
    string = [self mungeRgbWithString:string];

    // assumes URI doesn't have spaces in it
    NSArray* bits = explode(@" ", string); // bits to process

    NSMutableDictionary* caught = [NSMutableDictionary dictionaryWithDictionary:@{@"color":@NO, @"image":@NO, @"repeat":@NO, @"attachment":@NO, @"position":@NO}];


    NSInteger i = 0; // number of catches

    NSString* r = nil;

    for(NSString* bit in bits)
    {
        if ([bit isEqualTo:@""])
        {
            continue;
        }
        for(NSString* key in caught)
        {
            NSObject* status = caught[key];

            if(![key isEqualTo:@"position"])
            {
                if(![status isEqualTo:@NO])
                    continue;
                r = [[info objectForKey:[NSString stringWithFormat:@"background-%@", key]] validateWithString:bit config:config context:context];
            }
            else
            {
                r = bit;
            }
            if(!r)
                continue;

            if ([key isEqualTo:@"position"])
            {
                if([status isEqualTo:@NO])
                {
                    [caught setObject:@"" forKey:key];
                }
                [caught setObject:[NSString stringWithFormat:@"%@%@ ",[[caught objectForKey:key] copy], r] forKey:key];
            }
            else
            {
                [caught setObject:r forKey:key];
            }
            i++;
            break;
        }
    }

        if(i==0)
        {
            return false;
        }
        if(![[caught objectForKey:@"position"] isEqualTo:@NO])
        {
            [caught setObject:[(HTMLPurifier_AttrDef*)[self->info objectForKey:@"background-position"] validateWithString:[caught objectForKey:@"position"] config:config context:context] forKey:@"position"];
        }

        NSMutableArray* ret = [NSMutableArray new];
        for(NSObject* key in caught)
        {
            NSObject* value = caught[key];
            if([value isEqualTo:@NO])
                continue;
            [ret addObject:value];
        }

        if (ret.count==0)
        {
            return nil;
        }
        return implode(@" ", ret);
    }


@end
