//
//   HTMLPurifier_AttrDef_Lang.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 13.01.14.


/**
 * Validates the HTML attribute lang, effectively a language code.
 * @note Built according to RFC 3066, which obsoleted RFC 1766
 */

#import "HTMLPurifier_AttrDef_Lang.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_Lang

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    string = trim(string);
    if (!string)
    {
        return nil;
    }
    
    NSMutableArray* subtags = [explode(@"-",string) mutableCopy];
    NSUInteger num_subtags = [subtags count];
    
    if (num_subtags == 0)
    { // sanity check
        return nil;
    }
    
    // process primary subtag : $subtags[0]
    NSString* primary_subtag = [subtags objectAtIndex:0];
    NSUInteger length = [primary_subtag length];
    switch (length) {
        case 0:
            return nil;
        case 1:
            if (!([primary_subtag isEqual:@"x"] || [primary_subtag isEqual:@"i"]))
            {
                return nil;
            }
            break;
        case 2:
        case 3:
            if (!ctype_alpha(primary_subtag))
            {
                return nil;
            }
            else
            {
                [subtags replaceObjectAtIndex:0 withObject:[primary_subtag lowercaseString]];
            }
            break;
        default:
            return nil;
    }
    
    NSString* new_string = [subtags objectAtIndex:0];
    if (num_subtags == 1)
    {
        return new_string;
    }
    
    // process second subtag : $subtags[1]
    
    NSString* second_subtag = [subtags objectAtIndex:1];
    length = [second_subtag length];
    if (length == 0 || (length == 1 && ![second_subtag isEqual:@"x"]) || length > 8 || !ctype_alnum(second_subtag))
    {
        return new_string;
    }

    [subtags replaceObjectAtIndex:1 withObject:[second_subtag lowercaseString]];
    
    new_string = [NSString stringWithFormat:@"%@-%@",new_string,[subtags objectAtIndex:1]];
    if (num_subtags == 2)
    {
        return new_string;
    }
    
    // process all other subtags, index 2 and up
    for (NSInteger i = 2; i < num_subtags; i++)
    {
        length = [[subtags objectAtIndex:i] length];
        if (length == 0 || length > 8 || !ctype_alnum([subtags objectAtIndex:i]))
        {
            return new_string;
        }
        [subtags replaceObjectAtIndex:i withObject:[[subtags objectAtIndex:i] lowercaseString]];
        new_string = [NSString stringWithFormat:@"%@-%@",new_string,[subtags objectAtIndex:i]];
    }
    return new_string;
}

@end
