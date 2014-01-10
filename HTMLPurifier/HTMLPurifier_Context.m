//
//  HTMLPurifier_Context.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Context.h"

@implementation HTMLPurifier_Context

- (void)registerName:(NSString*)name  ref:(NSObject*)ref
{
    if([_storage objectForKey:name])
    {
        TRIGGER_ERROR(@"ERROR: Name %@ produces collision, cannot re-register", name);
        return;
    }
    [_storage setObject:ref forKey:name];
}

- (NSObject*)getName:(NSString*)name
{
    return [self getName:name ignoreError:NO];
}

- (NSObject*)getName:(NSString*)name ignoreError:(BOOL)ignoreError
{
    if([_storage objectForKey:name])
    {
        if(!ignoreError)
            TRIGGER_ERROR(@"ERROR: Attempted to retrieve non-existent variable name %@", name);
        return nil;
    }
    return [_storage objectForKey:name];
}

- (BOOL)existsName:(NSString *)name
{
    return [_storage objectForKey:name]!=nil;
}

- (void)loadArrayContextArray:(NSDictionary *)contextArray
{
    for(NSString* key in contextArray.allKeys)
    {
        [self registerName:key ref:[contextArray objectForKey:key]];
    }
}

@end
