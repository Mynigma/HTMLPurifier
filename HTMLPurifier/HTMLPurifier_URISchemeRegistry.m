//
//  HTMLPurifier_URISchemeRegistry.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//


/**
 * Registry for retrieving specific URI scheme validator objects.
 */

#import "HTMLPurifier_URISchemeRegistry.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_URIScheme.h"

@implementation HTMLPurifier_URISchemeRegistry

/**
 * Cache of retrieved schemes.
 * @type HTMLPurifier_URIScheme[]
 */

@synthesize schemes;

- (id)init
{
    self = [super init];
    if (self) {
        schemes = [NSMutableDictionary new];
    }
    return self;
}

/**
 * Retrieve sole instance of the registry.
 * @param HTMLPurifier_URISchemeRegistry $prototype Optional prototype to overload sole instance with,
 *                   or bool true to reset to default registry.
 * @return HTMLPurifier_URISchemeRegistry
 * @note Pass a registry object $prototype with a compatible interface and
 *       the function will copy it and return it all further times.
 */
+(HTMLPurifier_URISchemeRegistry*) instance:(HTMLPurifier_URISchemeRegistry*)prototype // = null)
{
    HTMLPurifier_URISchemeRegistry* instance = nil;
    if (prototype != nil)
    {
        instance = prototype;
    }
    else if (!instance || !prototype)
    {
        instance = [HTMLPurifier_URISchemeRegistry new];
    }
    return instance;
}

/**
 * Retrieves a scheme validator object
 * @param string $scheme String scheme name like http or mailto
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return HTMLPurifier_URIScheme
 */
- (HTMLPurifier_URIScheme*) getScheme:(NSString*)scheme config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (!config) {
        config = [HTMLPurifier_Config createDefault];
    }
    
    // important, otherwise attacker could include arbitrary file
    NSDictionary* allowed_schemes = (NSDictionary*)[config get:@"URI.AllowedSchemes"];
    if ((![config get:@"URI.OverrideAllowedSchemes"]) && (![allowed_schemes objectForKey:scheme]))
    {
        return nil;
    }
    
    if ([schemes objectForKey:scheme])
    {
        return [schemes objectForKey:scheme];
    }
    if (![allowed_schemes objectForKey:scheme])
    {
        return nil;
    }
    
    NSString* class = [@"HTMLPurifier_URIScheme_" stringByAppendingString:scheme];
    if (!(NSClassFromString(class)))
    {
        return nil;
    }
    [schemes setObject:[NSClassFromString(class) new] forKey:scheme];
    return [schemes objectForKey:scheme];
}

/**
 * Registers a custom scheme to the cache, bypassing reflection.
 * @param string $scheme Scheme name
 * @param HTMLPurifier_URIScheme $scheme_obj
 */
-(void) registerScheme:(NSString*)scheme object:(HTMLPurifier_URIScheme*)scheme_obj
{
    [schemes setObject:scheme_obj forKey:scheme];
}

@end
