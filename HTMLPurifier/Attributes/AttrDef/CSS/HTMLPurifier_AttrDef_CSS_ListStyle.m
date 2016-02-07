//
//   HTMLPurifier_AttrDef_CSS_ListStyle.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.


#import "HTMLPurifier_AttrDef_CSS_ListStyle.h"
#import "HTMLPurifier_CSSDefinition.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_CSS_ListStyle

    /**
     * @param HTMLPurifier_Config $config
     */
- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super init];
    if (self) {
        HTMLPurifier_CSSDefinition* def = [config getCSSDefinition];
        NSMutableDictionary* tempInfo = [NSMutableDictionary new];
        if ([[def info] objectForKey:@"list-style-type"])
            [tempInfo setObject:[[def info] objectForKey:@"list-style-type"] forKey:@"list-style-type"];
        if ([[def info] objectForKey:@"list-style-position"])
            [tempInfo setObject:[[def info] objectForKey:@"list-style-position"] forKey:@"list-style-position"];
        if ([[def info] objectForKey:@"list-style-image"])
            [tempInfo setObject:[[def info] objectForKey:@"list-style-image"] forKey:@"list-style-image"];
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
    } else if(![other isKindOfClass:[HTMLPurifier_AttrDef_CSS_ListStyle class]])
    {
        return NO;
    }
    else
    {
        return (!self.info && ![(HTMLPurifier_AttrDef_CSS_ListStyle*)other info]) || [self.info isEqual:[(HTMLPurifier_AttrDef_CSS_ListStyle*)other info]];
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
- (NSString*)validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
    {
        // regular pre-processing
        string = [self parseCDATAWithString:string];
        if ([string isEqual:@""]) {
            return nil;
        }

        // assumes URI doesn't have spaces in it
        NSArray* bits = explode(@" ", [string lowercaseString]); // bits to process

        NSMutableDictionary* caught = [NSMutableDictionary new];
        [caught setObject:@NO forKey:@"type"];
        [caught setObject:@NO forKey:@"position"];
        [caught setObject:@NO forKey:@"image"];

        NSInteger i = 0; // number of catches
        BOOL none = NO;

        for(NSString* bit in bits)
        {
            if (i >= 3)
            {
                return nil;
            } // optimization bit
            if ([bit isEqual:@""]) {
                continue;
            }
            for(NSString* key in caught)
            {
                NSString* attrDefKey = [@"list-style-" stringByAppendingString:key];
                HTMLPurifier_AttrDef* attrDef = self.info[attrDefKey];
                NSString* r = [attrDef validateWithString:bit config:config context:context];

                if (!r)
                {
                    continue;
                }
                if ([r isEqual:@"none"])
                {
                    if (none)
                    {
                        continue;
                    }
                    else
                    {
                        none = YES;
                    }
                    if ([key isEqual:@"image"])
                    {
                        continue;
                    }
                }
                [caught setObject:r forKey:key];
                i++;
                break;
            }
        }

        if (i==0)
        {
            return nil;
        }

        NSMutableArray* ret = [NSMutableArray new];

        // construct type
        if ([caught objectForKey:@"type"] && ![[caught objectForKey:@"type"] isEqual:@NO])
        {
            [ret addObject:[caught objectForKey:@"type"]];
        }

        // construct image
        if ([caught objectForKey:@"image"] && ![[caught objectForKey:@"image"] isEqual:@NO])
        {
            [ret addObject:[caught objectForKey:@"image"]];
        }

        // construct position
        if ([caught objectForKey:@"position"] && ![[caught objectForKey:@"position"] isEqual:@NO])
        {
            [ret addObject:[caught objectForKey:@"position"]];
        }

        if (ret.count==0) {
            return nil;
        }
        return implode(@" ", ret);
    }


@end
