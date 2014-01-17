//
//  HTMLPurifier_Context.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Context.h"
#import "HTMLPurifier.h"
#import "BasicPHP.h"

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
    if([_storage objectForKey:name])
    {
        TRIGGER_ERROR(@"ERROR: Name %@ produces collision, cannot re-register", name);
        return;
    }
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

@end
