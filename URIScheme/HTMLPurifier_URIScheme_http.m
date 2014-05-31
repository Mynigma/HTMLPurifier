//
//   HTMLPurifier_URIScheme_http.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.


#import "HTMLPurifier_URIScheme_http.h"
#import "HTMLPurifier_URI.h"

/**
 * Validates http (HyperText Transfer Protocol) as defined by RFC 2616
 */
@implementation HTMLPurifier_URIScheme_http


-(id) init
{
    self = [super init];
    super.default_port = @(80);
    super.browsable = @YES;
    super.hierarchical = @YES;
    
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
    //set the default scheme
    //only do this if a host is provided
    if ((![uri scheme] || [[uri scheme] isEqual:@""]) && uri.host)
        [uri setScheme:@"http"];
    
    [uri setUserinfo:nil];
    return YES;
}

@end
