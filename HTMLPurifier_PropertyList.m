//
//  HTMLPurifier_PropertyList.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 15.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_PropertyList.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_PropertyList


- (id)initWithParent:(HTMLPurifier_PropertyList*)parentPlist
{
    self = [super init];
    if (self) {
        parent = parentPlist;
        data = [NSMutableDictionary new];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        data = [NSMutableDictionary new];
    }
    return self;
}

/**
 * Recursively retrieves the value for a key
 * @param string $name
 * @throws HTMLPurifier_Exception
 */
- (NSString*)get:(NSString*)name
{
    if ([self has:name])
    {
        return data[name];
    }
    // possible performance bottleneck, convert to iterative if necessary
    if (parent) {
        return [parent get:name];
    }
    @throw [NSException exceptionWithName:@"PropertyList" reason:[NSString stringWithFormat:@"Key '%@' not found", name] userInfo:nil];
}

/**
 * Sets the value of a key, for this plist
 * @param string $name
 * @param mixed $value
 */
- (void)set:(NSString*)name value:(NSString*)value
{
    data[name] = value;
}

/**
 * Returns true if a given key exists
 * @param string $name
 * @return bool
 */
- (BOOL)has:(NSString*)name
{
    return data[name]!=nil;
}

/**
 * Resets a value to the value of it's parent, usually the default. If
 * no value is specified, the entire plist is reset.
 * @param string $name
 */
- (void)reset:(NSString*)name
{
    if (!name) {
        data = [NSMutableDictionary new];
    }
    else {
        [data removeObjectForKey:name];
    }
}

- (void)reset
         {
             [self reset:nil];
         }

/**
 * Squashes this property list and all of its property lists into a single
 * array, and returns the array. This value is cached by default.
 * @param bool $force If true, ignores the cache and regenerates the array.
 * @return array
 */
- (NSDictionary*)squash:(BOOL)force
{
    if (cache && !force)
    {
        return cache;
    }
    if (parent) {
        cache = dict_merge_2([parent squash:force], data);
        return cache;
    } else {
        cache = data;
        return cache;
    }
}

- (NSDictionary*)squash
{
    return [self squash:NO];
}


/**
 * Returns the parent plist.
 * @return HTMLPurifier_PropertyList
 */
- (HTMLPurifier_PropertyList*)getParent
{
    return parent;
}

/**
 * Sets the parent plist.
 * @param HTMLPurifier_PropertyList $plist Parent plist
 */
- (void)setParent:(HTMLPurifier_PropertyList*)plist
{
    parent = plist;
}


@end
