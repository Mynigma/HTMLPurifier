//
//  HTMLPurifier_URIFilter_DisableExternalResources.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_URIFilter_DisableExternalResources.h"
#import "HTMLPurifier_Context.h"

@implementation HTMLPurifier_URIFilter_DisableExternalResources

/**
 * @type string
 */
//public $name = 'DisableExternalResources';

-(id) init
{
    self = [super init];
    super.name = @"DisableExternalResources";
    return self;
}

/**
 * @param HTMLPurifier_URI $uri
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool
 */
- (BOOL) filter:(HTMLPurifier_URI**)uri config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (![(NSNumber*)[context getWithName:@"EmbeddedURI" ignoreError:YES] boolValue]) {
        return YES;
    }
    return [super filter:uri config:config context:context];
}

@end
