//
//  HTMLPurifier_DefinitionCache.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 15.01.14.


#import "HTMLPurifier_DefinitionCache.h"

@implementation HTMLPurifier_DefinitionCache


- (id)initWithTypeString:(NSString*)type
{
    return [self init];
}

/**
 * Generates a unique identifier for a particular configuration
 * @param HTMLPurifier_Config $config Instance of HTMLPurifier_Config
 * @return string
 */
- (NSString*)generateKey:(HTMLPurifier_Config*)config
{
    return nil;
}

/**
 * Tests whether or not a key is old with respect to the configuration's
 * version and revision number.
 * @param string $key Key to test
 * @param HTMLPurifier_Config $config Instance of HTMLPurifier_Config to test against
 * @return bool
 */
- (BOOL)isOld:(NSString*)key config:(HTMLPurifier_Config*)config
{
    return NO;

}

/**
 * Checks if a definition's type jives with the cache's type
 * @note Throws an error on failure
 * @param HTMLPurifier_Definition $def Definition object to check
 * @return bool true if good, false if not
 */
- (BOOL)checkDefType:(HTMLPurifier_Definition*)def
{
    return NO;
}

/**
 * Adds a definition object to the cache
 * @param HTMLPurifier_Definition $def
 * @param HTMLPurifier_Config $config
 */
- (void)add:(HTMLPurifier_Definition*)def config:(HTMLPurifier_Config*)config
{

}

/**
 * Unconditionally saves a definition object to the cache
 * @param HTMLPurifier_Definition $def
 * @param HTMLPurifier_Config $config
 */
- (void)set:(HTMLPurifier_Definition*)def config:(HTMLPurifier_Config*)config
{

}

/**
 * Replace an object in the cache
 * @param HTMLPurifier_Definition $def
 * @param HTMLPurifier_Config $config
 */
- (void)replace:(HTMLPurifier_Definition*)def config:(HTMLPurifier_Config*)config
{

}

/**
 * Retrieves a definition object from the cache
 * @param HTMLPurifier_Config $config
 */
- (HTMLPurifier_Definition*)get:(HTMLPurifier_Config*)config
{
    return nil;
}

/**
 * Removes a definition object to the cache
 * @param HTMLPurifier_Config $config
 */
- (void)remove:(HTMLPurifier_Config*)config
{

}

/**
 * Clears all objects from cache
 * @param HTMLPurifier_Config $config
 **/
- (void)flush:(HTMLPurifier_Config*)config
{

}

/**
 * Clears all expired (older version or revision) objects from cache
 * @note Be carefuly implementing this method as flush. Flush must
 *       not interfere with other Definition types, and cleanup()
 *       should not be repeatedly called by userland code.
 * @param HTMLPurifier_Config $config
 */
- (void)cleanup:(HTMLPurifier_Config*)config
{

}


@end
