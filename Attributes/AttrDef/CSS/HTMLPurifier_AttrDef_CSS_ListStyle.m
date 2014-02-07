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
        info = [NSMutableDictionary new];
        if ([[def info] objectForKey:@"list-style-type"])
            [info setObject:[[def info] objectForKey:@"list-style-type"] forKey:@"list-style-type"];
        if ([[def info] objectForKey:@"list-style-position"])
            [info setObject:[[def info] objectForKey:@"list-style-position"] forKey:@"list-style-position"];
        if ([[def info] objectForKey:@"list-style-image"])
            [info setObject:[[def info] objectForKey:@"list-style-image"] forKey:@"list-style-image"];
    }
    return self;
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
        if ([string isEqualTo:@""]) {
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
            if ([bit isEqualTo:@""]) {
                continue;
            }
            for(NSString* key in caught)
            {
                NSString* attrDefKey = [@"list-style-" stringByAppendingString:key];
                HTMLPurifier_AttrDef* attrDef = info[attrDefKey];
                NSString* r = [attrDef validateWithString:bit config:config context:context];

                if (!r)
                {
                    continue;
                }
                if ([r isEqualTo:@"none"])
                {
                    if (none)
                    {
                        continue;
                    }
                    else
                    {
                        none = YES;
                    }
                    if ([key isEqualTo:@"image"])
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
