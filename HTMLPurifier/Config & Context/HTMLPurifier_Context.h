//
//   HTMLPurifier_Context.h
//   HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.


#import <Foundation/Foundation.h>


@class HTMLPurifier_URISchemeRegistry;

@interface HTMLPurifier_Context : NSObject
{
    NSMutableDictionary* _storage;
    
    HTMLPurifier_URISchemeRegistry* theInstance;
}

- (void)registerWithName:(NSString*)name ref:(NSObject*)ref;
- (NSObject*)getWithName:(NSString*)name;
- (NSObject*)getWithName:(NSString*)name ignoreError:(BOOL)ignoreError;
- (BOOL)existsWithName:(NSString*)name;
- (void)loadArrayWithContextArray:(NSDictionary*)contextArray;
/**
 * Destroys a variable in the context.
 * @param string $name String name
 */
-(void) destroy:(NSString*)name;


/**
 * Retrieve sole instance of the registry.
 * @param HTMLPurifier_URISchemeRegistry $prototype Optional prototype to overload sole instance with,
 *                   or bool true to reset to default registry.
 * @return HTMLPurifier_URISchemeRegistry
 * @note Pass a registry object $prototype with a compatible interface and
 *       the function will copy it and return it all further times.
 */
- (HTMLPurifier_URISchemeRegistry*)URISchemeRegistryInstance:(HTMLPurifier_URISchemeRegistry*)prototype; // = null)

@end
