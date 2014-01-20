//
//  HTMLPurifier_URIScheme_file.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_URIScheme_file.h"
#import "HTMLPurifier_URI.h"

/**
 * Validates file as defined by RFC 1630 and RFC 1738.
 */
@implementation HTMLPurifier_URIScheme_file

/**
 * Generally file:// URLs are not accessible from most
 * machines, so placing them as an img src is incorrect.
 * @type bool
 */
// public $browsable = false;

/**
 * Basically the *only* URI scheme for which this is true, since
 * accessing files on the local machine is very common.  In fact,
 * browsers on some operating systems don't understand the
 * authority, though I hear it is used on Windows to refer to
 * network shares.
 * @type bool
 */
// public $may_omit_host = true;

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
    // Authentication method is not supported
    [uri setUserinfo:nil];
    // file:// makes no provisions for accessing the resource
    [uri setPort:nil];
    // While it seems to work on Firefox, the querystring has
    // no possible effect and is thus stripped.
    [uri setQuery:nil];
    
    return YES;
}

@end
