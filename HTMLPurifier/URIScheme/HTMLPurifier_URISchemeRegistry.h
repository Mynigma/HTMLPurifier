//
//   HTMLPurifier_URISchemeRegistry.h
//   HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.



/**
 * Registry for retrieving specific URI scheme validator objects.
 */

#import <Foundation/Foundation.h>

@class HTMLPurifier_Context,HTMLPurifier_Config,HTMLPurifier_URIScheme;

@interface HTMLPurifier_URISchemeRegistry : NSObject

/**
 * Cache of retrieved schemes.
 * @type HTMLPurifier_URIScheme[]
 */
@property NSMutableDictionary* schemes;


/**
 * Retrieves a scheme validator object
 * @param string $scheme String scheme name like http or mailto
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return HTMLPurifier_URIScheme
 */
-(HTMLPurifier_URIScheme*) getScheme:(NSString*)scheme config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;

/**
 * Registers a custom scheme to the cache, bypassing reflection.
 * @param string $scheme Scheme name
 * @param HTMLPurifier_URIScheme $scheme_obj
 */
-(void) registerScheme:(NSString*)scheme object:(HTMLPurifier_URIScheme*)scheme_obj;

@end
