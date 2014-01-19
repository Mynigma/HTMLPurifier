//
//  HTMLPurifier_AttrDef_HTML_Nmtokens.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_HTML_Nmtokens.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_HTML_Nmtokens

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
- (NSString*) validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    string = trim(string);
    
    // Maybe [string isEmpty] ?
    // early abort: '' and '0' (strings that convert to false) are invalid
    if ([string isEqual:@""] || [string isEqual:@"0"])
    {
        return nil;
    }
    
    NSMutableArray* tokens = [self splitWithString:string config:config context:context];
    
    tokens = [self filterWithTokens:tokens config:config context:context];
    
    if ([tokens count] == 0)
    {
        return nil;
    }
    return implode(@" ", tokens);
}

/**
 * Splits a space separated list of tokens into its constituent parts.
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
-(NSArray*) splitWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    // OPTIMIZABLE!
    // do the preg_match, capture all subpatterns for reformulation
    
    // we don't support U+00A1 and up codepoints or
    // escaping because I don't know how to do that with regexps
    // and plus it would complicate optimization efforts (you never
    // see that anyway).
    
    // look behind for space or string start
    NSString* pattern = @"(?:(?<=\\s)|\\A)";
    //The actual pattern
    pattern = [pattern stringByAppendingString:@"((?:--|-?[A-Za-z_])[A-Za-z_\\-0-9]*)"];
    // look ahead for space or string end
    pattern = [pattern stringByAppendingString:@"(?:(?=\\s)|\\z)"];
    NSMutableArray* matches = [NSMutableArray new];
    
    preg_match_all_3(pattern, string, matches);
    
    // Nothing found?
    if ([matches count] == 0)
    {
        return matches;
    }
    
    //matches can includes subpattern (unwanted I guess)
    if ([[matches objectAtIndex:0] isKindOfClass:[NSArray class]])
    {
        return [matches objectAtIndex:0];
    }
    
    return matches;
}

/**
 * Template method for removing certain tokens based on arbitrary criteria.
 * @note If we wanted to be really functional, we'd do an array_filter
 *       with a callback. But... we're not.
 * @param array $tokens
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSMutableArray*) filterWithTokens:(NSMutableArray*)tokens config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    return tokens;
}

@end
