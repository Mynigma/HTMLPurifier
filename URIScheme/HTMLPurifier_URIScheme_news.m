//
//   HTMLPurifier_URIScheme_news.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.


#import "HTMLPurifier_URIScheme_news.h"
#import "HTMLPurifier_URI.h"

/**
 * Validates news (Usenet) as defined by generic RFC 1738
 */
@implementation HTMLPurifier_URIScheme_news

-(id) init
{
    self = [super init];
    super.browsable = @NO;
    super.may_omit_host = @YES;
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
    [uri setHost: nil];
    [uri setPort:nil];
    [uri setQuery:nil];
    // typecode check needed on path
    return YES;
}

@end
