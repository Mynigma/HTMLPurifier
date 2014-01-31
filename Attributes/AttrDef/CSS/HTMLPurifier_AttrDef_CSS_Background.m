//
//  HTMLPurifier_AttrDef_CSS_Background.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.


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
        if ([def.info objectForKey:@"background-color"])
            [info setObject:[def.info objectForKey:@"background-color"] forKey:@"background-color"];
        if ([def.info objectForKey:@"background-image"])
            [info setObject:[def.info objectForKey:@"background-image"] forKey:@"background-image"];
        if ([def.info objectForKey:@"background-repeat"])
            [info setObject:[def.info objectForKey:@"background-repeat"] forKey:@"background-repeat"];
        if ([def.info objectForKey:@"background-attachment"])
            [info setObject:[def.info objectForKey:@"background-attachment"] forKey:@"background-attachment"];
        if ([def.info objectForKey:@"background-position"])
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

    NSArray* sortedCaughtKeys = @[@"color", @"image", @"repeat", @"attachment", @"position"];

    NSInteger i = 0; // number of catches

    NSString* r = nil;

    for(NSString* bit in bits)
    {
        if ([bit isEqualTo:@""])
        {
            continue;
        }
        for(NSString* key in sortedCaughtKeys)
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
            return nil;
        }
        if(![[caught objectForKey:@"position"] isEqualTo:@NO])
        {
            if (![self->info objectForKey:@"background-position"] || ![[self->info objectForKey:@"background-position"] isKindOfClass:[HTMLPurifier_AttrDef class]])
                return nil;
            [caught setObject:[(HTMLPurifier_AttrDef*)[self->info objectForKey:@"background-position"] validateWithString:[caught objectForKey:@"position"] config:config context:context] forKey:@"position"];
        }

        NSMutableArray* ret = [NSMutableArray new];
        for(NSObject* key in sortedCaughtKeys)
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
