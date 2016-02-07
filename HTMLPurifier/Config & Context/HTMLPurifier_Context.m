//
//   HTMLPurifier_Context.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.


#import "HTMLPurifier_Context.h"
#import "HTMLPurifier.h"
#import "BasicPHP.h"
#import "HTMLPurifier_URISchemeRegistry.h"

@implementation HTMLPurifier_Context


- (id)init
{
    self = [super init];
    if (self) {
        _storage = [NSMutableDictionary new];
    }
    return self;
}


- (void)registerWithName:(NSString*)name  ref:(NSObject*)ref
{
    if(name && [_storage objectForKey:name] && ![[_storage objectForKey:name] isEqual:@NO])
    {
        TRIGGER_ERROR(@"ERROR: Name %@ produces collision, cannot re-register", name);
        return;
    }
    if (ref && name)
        [_storage setObject:ref forKey:name];
}

- (NSObject*)getWithName:(NSString*)name
{
    return [self getWithName:name ignoreError:NO];
}

- (NSObject*)getWithName:(NSString*)name ignoreError:(BOOL)ignoreError
{
    if(![_storage objectForKey:name])
    {
        if(!ignoreError)
            TRIGGER_ERROR(@"ERROR: Attempted to retrieve non-existent variable name %@", name);
        return nil;
    }
    return [_storage objectForKey:name];
}

- (BOOL)existsWithName:(NSString *)name
{
    return [_storage objectForKey:name]!=nil;
}

- (void)loadArrayWithContextArray:(NSDictionary *)contextArray
{
    for(NSString* key in contextArray.allKeys)
    {
        [self registerWithName:key ref:[contextArray objectForKey:key]];
    }
}

/**
 * Destroys a variable in the context.
 * @param string $name String name
 */
-(void)destroy:(NSString*)name
{
    if (![_storage objectForKey:name])
    {
        TRIGGER_ERROR(@"ERROR: Attempted to destroy non-existent variable %@",name);
        return;
    }
    [_storage removeObjectForKey:name];
    return;
}


/**
 * Retrieve sole instance of the registry.
 * @param HTMLPurifier_URISchemeRegistry $prototype Optional prototype to overload sole instance with,
 *                   or bool true to reset to default registry.
 * @return HTMLPurifier_URISchemeRegistry
 * @note Pass a registry object $prototype with a compatible interface and
 *       the function will copy it and return it all further times.
 */
- (HTMLPurifier_URISchemeRegistry*)URISchemeRegistryInstance:(HTMLPurifier_URISchemeRegistry*)prototype // = null)
{
    if (prototype)
    {
        theInstance = prototype;
    }
    else if (!theInstance || [prototype isEqual:@YES])
    {
        theInstance = [HTMLPurifier_URISchemeRegistry new];
    }
    return theInstance;
}

@end
