//
//  HTMLPurifier_AttrDef_CSS_TextDecoration.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.


#import "HTMLPurifier_AttrDef_CSS_TextDecoration.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_CSS_TextDecoration

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
- (NSString*)validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    NSDictionary* allowedValues = @{@"line-through":@YES, @"overline":@YES, @"underline":@YES};

    string = [[self parseCDATAWithString:string] lowercaseString];

    if ([string isEqual:@"none"])
    {
        return string;
    }

    NSArray* parts = explode(@" ", string);
    NSMutableString* final = [@"" mutableCopy];
    for(NSString* part in parts)
    {
        if([allowedValues objectForKey:part])
        {
            [final appendFormat:@"%@ ", part];
        }
    }
    final = [trim(final) mutableCopy];
    if ([final isEqualTo:@""])
    {
        return nil;
    }
    return final;
}

@end
