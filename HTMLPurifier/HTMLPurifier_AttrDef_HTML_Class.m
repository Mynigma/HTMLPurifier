//
//  HTMLPurifier_AttrDef_HTML_Class.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_HTML_Class.h"
#import "BasicPHP.h"
#import "HTMLPurifier_HTMLDefinition.h"

/**
* Implements special behavior for class attribute (normally NMTOKENS)
*/
@implementation HTMLPurifier_AttrDef_HTML_Class


-(id) init
{
    return [super init];
}

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) splitWithString:(NSString*)string Config:(HTMLPurifier_Config*)config Context:(HTMLPurifier_Context*)context
{
    // really, this twiddle should be lazy loaded
    NSString* name = [[(HTMLPurifier_HTMLDefinition*)[config getDefinition:@"HTML"] doctype] name];
    if ([name isEqual:@"XHTML 1.1"] || [name isEqual:@"XHTML 2.0"])
    {
        return [super splitWithString:string Config:config Context:context];
    } else {
        return preg_split(@"/\\s+/", string);
    }
}

/**
 * @param array $tokens
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
-(NSMutableArray*) filterWithTokens:(NSMutableArray*)tokens Config:(HTMLPurifier_Config*)config Context:(HTMLPurifier_Context*)context
{
    NSMutableArray* allowed = (NSMutableArray*)[[config get:@"Attr.AllowedClasses"] mutableCopy];
    NSMutableArray* forbidden = (NSMutableArray*)[[config get:@"Attr.ForbiddenClasses"] mutableCopy];
    NSMutableArray* ret = [NSMutableArray new];
    for (NSString* token in tokens)
    {
        if ((allowed == nil || [allowed containsObject:token]) &&
            (![forbidden containsObject:token]) &&
            // We need this O(n) check because of PHP's array
            // implementation that casts -0 to 0.
            [ret containsObject:token])
        {
            [ret addObject:token];
        }
    }
    return ret;
}





@end
