//
//  HTMLPurifier_AttrDef_URI_IPv4.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 12.01.14.


/**
 * Validates an IPv4 address
 * @author Feyd @ forums.devnetwork.net (public domain)
 */

#import "HTMLPurifier_AttrDef_URI_IPv4.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_URI_IPv4

/**
 * IPv4 regex, protected so that IPv6 can reuse it.
 * @type string
 */
@synthesize ip4;

/**
 * @param string $aIP
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString*)aIP config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (!ip4)
    {
       [self loadRegex];
    }
    
    if (preg_match_2_WithLineBreak([NSString stringWithFormat:@"^%@$",ip4],aIP))
    {
        return aIP;
    }
    return nil;
}

/**
 * Lazy load function to prevent regex from being stuffed in
 * cache.
 */
-(void) loadRegex
{
    NSString* oct = @"(?:(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9]))"; // 0-255
    ip4 = [NSString stringWithFormat:@"(?:%@\\.%@\\.%@\\.%@)",oct,oct,oct,oct];
}


@end
