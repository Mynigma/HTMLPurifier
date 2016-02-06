//
//   HTMLPurifier_PropertyList.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 15.01.14.


#import "HTMLPurifier_PropertyList.h"
#import "BasicPHP.h"


#define BUNDLE (NSClassFromString(@"HTMLPurifierTests")!=nil)?[NSBundle bundleForClass:[NSClassFromString(@"HTMLPurifierTests") class]]:[NSBundle bundleForClass:[NSClassFromString(@"HTMLPurifier") class]]




//
//  XPathQuery.m
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//


@implementation HTMLPurifier_PropertyList


- (id)initWithParent:(HTMLPurifier_PropertyList*)parentPlist
{
    self = [super init];
    if (self) {
        parent = parentPlist;
        [self actuallyReadPlist];
    }
    return self;
}

- (void)actuallyReadPlist
{
    //check for a user-defined config first
    NSURL* configPlistPath = [[NSBundle mainBundle] URLForResource:@"HTMLPurifierCustomConfig" withExtension:@"plist"];
    if(!configPlistPath)
        configPlistPath = [BUNDLE URLForResource:@"HTMLPurifierConfig" withExtension:@"plist"];
    
    if(!configPlistPath)
    {
        NSLog(@"Error opening config plist file!!! Please include either 'HTMLPurifierCustomConfig.plist' in main bundle or 'HTMLPurifierConfig.plist' in bundle: %@", [NSBundle bundleForClass:[self class]]);
        return;
    }

    data = [[[NSDictionary dictionaryWithContentsOfURL:configPlistPath] objectForKey:@"defaultPlist"] mutableCopy];
}


- (id)init
{
    return [self initWithParent:nil];
}

/**
 * Recursively retrieves the value for a key
 * @param string $name
 * @throws HTMLPurifier_Exception
 */
- (NSObject*)get:(NSString*)name
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
- (void)set:(NSString*)name value:(NSObject*)value
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
        cache = [dict_merge_2([parent squash:force], data) mutableCopy];
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
