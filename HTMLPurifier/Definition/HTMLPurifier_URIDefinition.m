//
//   HTMLPurifier_URIDefinition.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 13.01.14.


#import "HTMLPurifier_URIDefinition.h"
#import "HTMLPurifier_URI.h"
#import "HTMLPurifier_URIFilter.h"
#import "HTMLPurifier_URIFilter_DisableExternal.h"
#import "HTMLPurifier_URIFilter_DisableExternalResources.h"
#import "HTMLPurifier_URIFilter_HostBlacklist.h"
#import "HTMLPurifier_URIFilter_MakeAbsolute.h"
#import "HTMLPurifier_URIFilter_DisableResources.h"
#import "HTMLPurifier_URIFilter_SafeIframe.h"
#import "HTMLPurifier_URIFilter_Munge.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_URIParser.h"
#import "HTMLPurifier_URISchemeRegistry.h"
#import "HTMLPurifier_Context.h"


@implementation HTMLPurifier_URIDefinition



/**
 * HTMLPurifier_URI object of the base specified at %URI.Base
 */
@synthesize base;

/**
 * String host to consider "home" base, derived off of $base
 */
@synthesize host;

/**
 * Name of default scheme based on %URI.DefaultScheme and %URI.Base
 */
@synthesize defaultScheme;


-(id) init
{
    self = [super init];

    self.type = @"URI";
    _filters = [NSMutableDictionary new];
    _postFilters = [NSMutableDictionary new];

    _registeredFilters = [NSMutableDictionary new];
    
    [self registerFilter:[HTMLPurifier_URIFilter_DisableExternal new]];
    [self registerFilter:[HTMLPurifier_URIFilter_DisableExternalResources new]];
    [self registerFilter:[HTMLPurifier_URIFilter_DisableResources new]];
    [self registerFilter:[HTMLPurifier_URIFilter_HostBlacklist new]];
    [self registerFilter:[HTMLPurifier_URIFilter_SafeIframe new]];
    [self registerFilter:[HTMLPurifier_URIFilter_MakeAbsolute new]];
    [self registerFilter:[HTMLPurifier_URIFilter_Munge new]];
    
    return self;
}

-(void) registerFilter:(HTMLPurifier_URIFilter*) filter
{
    if (filter && [filter name])
        [self.registeredFilters setObject:filter forKey:[filter name]];
}

-(void) addFilter:(HTMLPurifier_URIFilter*)filter config:(HTMLPurifier_Config*)config
{
    BOOL r = [filter prepare:config];
    if (r == NO)
        return; // null is ok, for backwards compat
    if ([filter post])
    {
        if ([filter name])
            [self.postFilters setObject:filter forKey:[filter name]];
    }
    else
    {
        if ([filter name])
            [self.filters setObject:filter forKey:[filter name]];
    }
}

-(void) doSetup:(HTMLPurifier_Config*)config
{
    [self setupMemberVariables:config];
    [self setupFilters:config];
}

-(void) setupFilters:(HTMLPurifier_Config*)config
{
    for (NSString* name in self.registeredFilters.allKeys)
    {
        HTMLPurifier_URIFilter* filter = [self.registeredFilters objectForKey:name];
        if ([filter always_load])
        {
            [self addFilter:filter config:config];
        }
        else
        {
            // TODODOTO
            NSNumber* conf = (NSNumber*)[config get:[NSString stringWithFormat:@"URI.%@",name]];
            if ((conf != nil) && (![conf  isEqual:@NO]))
            {
                [self addFilter:filter config:config];
            }
        }
    }
    //unset($this->registeredFilters);
}

-(void) setupMemberVariables:(HTMLPurifier_Config*)config
{
    host = (NSString*)[config get:@"URI.Host"];
    NSString* base_uri = (NSString*)[config get:@"URI.Base"];
    if (base_uri)
    {
        HTMLPurifier_URIParser* parser = [HTMLPurifier_URIParser new];
        base = [parser parse:base_uri];
        defaultScheme = [base scheme];
        if (!host)
            host = [base host];
    }
    if (!defaultScheme)
        defaultScheme = (NSString*)[config get:@"URI.DefaultScheme"];
}

-(HTMLPurifier_URIScheme*) getDefaultScheme:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    return [[context URISchemeRegistryInstance:nil] getScheme:defaultScheme config:config context:context];
}

-(BOOL) filter:(HTMLPurifier_URI**)uri config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    for (NSString* name in self.filters.allKeys)
    {
        HTMLPurifier_URIFilter* f = [self.filters objectForKey:name];
        BOOL result = [f filter:uri config:config context:context];
        if (!result) return NO;
    }
    return YES;
}

-(BOOL) postFilter:(HTMLPurifier_URI**)uri config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    for (NSString* name in self.postFilters.allKeys)
    {
        HTMLPurifier_URIFilter* f = [self.filters objectForKey:name];
        BOOL result = [f filter:uri config:config context:context];
        if (!result)
            return NO;
    }
    return YES;
}



@end
