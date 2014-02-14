//
//   HTMLPurifier_URIScheme_mailto.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.


#import "HTMLPurifier_URIScheme_mailto.h"
#import "HTMLPurifier_URI.h"
#import "BasicPHP.h"

// VERY RELAXED! Shouldn't cause problems, not even Firefox checks if the
// email is valid, but be careful!

/**
 * Validates mailto (for E-mail) according to RFC 2368 (With a somewhat relaxed regex)
 * @todo Filter allowed query parameters
 */
@implementation HTMLPurifier_URIScheme_mailto


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
    [uri setHost:nil];
    [uri setPort:nil];

    if ([uri path].length > 0)
    {
        //checks for the first email adress in the path (removes useless \)
        NSMutableArray* matches = [NSMutableArray new];
        BOOL result = preg_match_3(@"\\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}\\b", uri.path, matches);
        if (result)
        {
            [uri setPath:matches[0]];
            return YES;
        }
        return NO;
    }

    return true;
}

@end
