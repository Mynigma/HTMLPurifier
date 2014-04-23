//
//   HTMLPurifier_URIScheme_nntp.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.


#import "HTMLPurifier_URIScheme_nntp.h"
#import "HTMLPurifier_URI.h"

/**
 * Validates nntp (Network News Transfer Protocol) as defined by generic RFC 1738
 */
@implementation HTMLPurifier_URIScheme_nntp

/**
 * @type int
 */

-(id) init
{
    self = [super init];
    super.default_port = @(119);
    super.browsable = @NO;
    
    return self;
}

/**
 * @param HTMLPurifier_URI $uri
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool
 */
-(BOOL) doValidate:(HTMLPurifier_URI*)uri config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    [uri setUserinfo:nil];
    [uri setQuery:nil];
    return YES;
}

@end
