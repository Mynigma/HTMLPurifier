//
//  HTMLPurifier_URIFilter_HostBlacklist.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_URIFilter_HostBlacklist.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_URI.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_URIFilter_HostBlacklist

/**
 * @type string
 */
//public $name = 'HostBlacklist';

/**
 * @type array
 */
@synthesize blacklist; // = array();

-(id) init
{
    self = [super init];
    super.name = @"HostBlacklist";
    self.blacklist = [NSArray new];
    
    return self;
}

/**
 * @param HTMLPurifier_Config $config
 * @return bool
 */
- (BOOL) prepare:(HTMLPurifier_Config*)config
{
    self.blacklist = (NSArray*)[config get:@"URI.HostBlacklist"];
    return YES;
}

/**
 * @param HTMLPurifier_URI $uri
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool
 */
- (BOOL) filter:(HTMLPurifier_URI*)uri config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    for (NSString* blacklisted_host_fragment in self.blacklist)
    {
        if (strpos([uri host],blacklisted_host_fragment) != NSNotFound)
        {
            return NO;
        }
    }
    return YES;
}

@end
