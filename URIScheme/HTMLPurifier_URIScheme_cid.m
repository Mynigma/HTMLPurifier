//
//  HTMLPurifier_URIScheme_cid.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 14.02.14.

#import "HTMLPurifier_URIScheme_cid.h"
#import "HTMLPurifier_URI.h"
#import "BasicPHP.h"


/** 
 * Implementation of cid validation after RFC2111
 * The content-id from cid:content-id is basically an url encoded addr-spec from RFC822
 * My regex handels this as an lazy matched email address
 **/

@implementation HTMLPurifier_URIScheme_cid



-(id) init
{
    self = [super init];
    super.browsable = @YES;
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
    [uri setHost:nil];
    [uri setPort:nil];
    [uri setQuery:nil];
    [uri setFragment:nil];
    
    if ([uri path].length > 0)
    {
        return preg_match_2(@"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", uri.path);
    }
    
    return true;
}


@end
