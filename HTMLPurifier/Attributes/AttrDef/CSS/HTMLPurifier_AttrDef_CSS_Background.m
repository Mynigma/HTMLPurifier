//
//   HTMLPurifier_AttrDef_CSS_Background.m
//   HTMLPurifier
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
        NSMutableDictionary* tempInfo = [NSMutableDictionary new];
        if ([def.info objectForKey:@"background-color"])
            [tempInfo setObject:[def.info objectForKey:@"background-color"] forKey:@"background-color"];
        if ([def.info objectForKey:@"background-image"])
            [tempInfo setObject:[def.info objectForKey:@"background-image"] forKey:@"background-image"];
        if ([def.info objectForKey:@"background-repeat"])
            [tempInfo setObject:[def.info objectForKey:@"background-repeat"] forKey:@"background-repeat"];
        if ([def.info objectForKey:@"background-attachment"])
            [tempInfo setObject:[def.info objectForKey:@"background-attachment"] forKey:@"background-attachment"];
        if ([def.info objectForKey:@"background-position"])
            [tempInfo setObject:[def.info objectForKey:@"background-position"] forKey:@"background-position"];
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
    } else if(![other isKindOfClass:[HTMLPurifier_AttrDef_CSS_Background class]])
    {
        return NO;
    }
    else
    {
        return (!self.info && ![(HTMLPurifier_AttrDef_CSS_Background*)other info]) || [self.info isEqual:[(HTMLPurifier_AttrDef_CSS_Background*)other info]];
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
- (NSString*)validateWithString:(NSString *)someString config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    // regular pre-processing
    NSString* string = [self parseCDATAWithString:someString];
    if ([string isEqual:@""]) {
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
        if ([bit isEqual:@""])
        {
            continue;
        }
        for(NSString* key in sortedCaughtKeys)
        {
            NSObject* status = caught[key];

            if(![key isEqual:@"position"])
            {
                if(![status isEqual:@NO])
                    continue;
                r = [[_info objectForKey:[NSString stringWithFormat:@"background-%@", key]] validateWithString:bit config:config context:context];
            }
            else
            {
                r = bit;
            }
            if(!r)
                continue;

            if ([key isEqual:@"position"])
            {
                if([status isEqual:@NO])
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
        if(![[caught objectForKey:@"position"] isEqual:@NO])
        {
            if (![self.info objectForKey:@"background-position"] || ![[self.info objectForKey:@"background-position"] isKindOfClass:[HTMLPurifier_AttrDef class]])
                return nil;
            NSString* res = [(HTMLPurifier_AttrDef*)[self.info objectForKey:@"background-position"] validateWithString:[caught objectForKey:@"position"] config:config context:context];
            if (!res)
                return nil;
            [caught setObject:res forKey:@"position"];
        }

        NSMutableArray* ret = [NSMutableArray new];
        for(NSObject* key in sortedCaughtKeys)
        {
            NSObject* value = caught[key];
            if([value isEqual:@NO])
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
