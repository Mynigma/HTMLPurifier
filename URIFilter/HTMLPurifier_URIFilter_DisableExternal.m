//
//  HTMLPurifier_URIFilter_DisableExternal.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.


#import "HTMLPurifier_URIFilter_DisableExternal.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_URI.h"
#import "BasicPHP.h"
#import "HTMLPurifier_URIDefinition.h"

@implementation HTMLPurifier_URIFilter_DisableExternal

/**
 * @type string
 */
//public $name = 'DisableExternal';

/**
 * @type array
 */
@synthesize ourHostParts; // = false;


-(id) init
{
    self = [super init];
    
    super.name = @"";
    self.ourHostParts = nil;
    return self;
}

/**
 * @param HTMLPurifier_Config $config
 * @return void
 */

// VOID OR BOOL ?
- (BOOL) prepare:(HTMLPurifier_Config*)config
{
    NSString* our_host = [(HTMLPurifier_URIDefinition*)[config getDefinition:@"URI"] host];
    if (our_host) {
        self.ourHostParts = array_reverse([explode(@".", our_host) mutableCopy]);
        return YES;
    }
    return NO;
}

/**
 * @param HTMLPurifier_URI $uri Reference
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool
 */
- (BOOL) filter:(HTMLPurifier_URI**)uri config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (![*uri host]) {
        return YES;
    }
    if (!self.ourHostParts) {
        return NO;
    }
    
    // Why that complicatied? just let them be strings and compare? TODODOTO
    /* MY Code instead of for...
     if ([host_parts isEqual:ourHostParts])
        return TRUE;
     return FALSE;
     */
    
    NSArray* host_parts = array_reverse([explode(@".", [*uri host]) mutableCopy]);
    for (NSInteger i = 0; i < self.ourHostParts.count; i++)
    {
        if ( (i >= host_parts.count) || !host_parts[i]) {
            return NO;
        }
        if (![host_parts[i] isEqual:ourHostParts[i]]) {
            return NO;
        }
    }
    return YES;
}


@end
