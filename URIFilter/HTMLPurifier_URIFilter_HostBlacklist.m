//
//   HTMLPurifier_URIFilter_HostBlacklist.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.


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
    self.name = @"HostBlacklist";
    self.blacklist = [NSArray new];
    
    return self;
}

/**
 * @param HTMLPurifier_Config $config
 * @return bool
 */
- (BOOL) prepare:(HTMLPurifier_Config*)config
{
    NSObject* def= [config get:@"URI.HostBlacklist"];
    
    // This List can be a single String
    if ([def isKindOfClass:[NSString class]])
    {
        if([(NSString*)def length]>0)
            self.blacklist = [NSArray arrayWithObject:def];
    }
    else
    {
        self.blacklist = (NSArray*)def;
    }
    return YES;
}

/**
 * @param HTMLPurifier_URI $uri
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool
 */
- (BOOL) filter:(HTMLPurifier_URI**)uri config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    for (NSString* blacklisted_host_fragment in self.blacklist)
    {
        if([*uri host] && strpos([*uri host],blacklisted_host_fragment) != NSNotFound)
        {
            return NO;
        }
    }
    return YES;
}

@end
