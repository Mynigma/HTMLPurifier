//
//  HTMLPurifier_URIScheme_https.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_URIScheme_https.h"

/**
 * Validates https (Secure HTTP) according to http scheme.
 */
@implementation HTMLPurifier_URIScheme_https


-(id) init
{
    self = [super init];
    
    super.default_port = @(443);
    super.secure = @YES;
    
    return self;
}

@end
