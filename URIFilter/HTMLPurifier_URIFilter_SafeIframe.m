//
//  HTMLPurifier_URIFilter_SafeIframe.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_URIFilter_SafeIframe.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_URI.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Token.h"
#import "BasicPHP.h"

/**
 * Implements safety checks for safe iframes.
 *
 * @warning This filter is *critical* for ensuring that %HTML.SafeIframe
 * works safely.
 */
@implementation HTMLPurifier_URIFilter_SafeIframe


/**
 * @type string
 */
//public $name = 'SafeIframe';

/**
 * @type bool
 */
// public $always_load = true;

/**
 * @type string
*/
@synthesize regexp; // = null;

-(id) init
{
    self = [super init];
    
    super.name = @"SafeIframe";
    super.always_load = YES;
    self.regexp = nil;
    
    return self;
}

// XXX: The not so good bit about how this is all set up now is we
// can't check HTML.SafeIframe in the 'prepare' step: we have to
// defer till the actual filtering.
/**
* @param HTMLPurifier_Config $config
* @return bool
*/
- (BOOL) prepare:(HTMLPurifier_Config*)config
    {
        self.regexp = (NSString*)[config get:@"URI.SafeIframeRegexp"];
        return true;
    }
    
    /**
     * @param HTMLPurifier_URI $uri
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool
     */
- (BOOL) filter:(HTMLPurifier_URI**)uri config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
    {
        // check if filter not applicable
        if (![config get:@"HTML.SafeIframe"])
        {
            return YES;
        }
        // check if the filter should actually trigger
        if (![context getWithName:@"EmbeddedURI" ignoreError:YES]) {
            return YES;
        }
        HTMLPurifier_Token* token = (HTMLPurifier_Token*)[context getWithName:@"CurrentToken" ignoreError:YES];
        if (!(token && [[token name] isEqual:@"iframe"])) {
            return YES;
        }
        // check if we actually have some whitelists enabled
        if (!self.regexp) {
            return NO;
        }
        // actually check the whitelists
        return preg_match_2(self.regexp,[*uri toString]);
    }

@end
