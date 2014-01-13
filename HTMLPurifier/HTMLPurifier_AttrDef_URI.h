//
//  HTMLPurifier_AttrDef_URI.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//


/**
 * Validates a URI as defined by RFC 3986.
 * @note Scheme-specific mechanics deferred to HTMLPurifier_URIScheme
 */

#import "HTMLPurifier_AttrDef.h"
#import "HTMLPurifier_URIParser.h"

@interface HTMLPurifier_AttrDef_URI : HTMLPurifier_AttrDef

/**
 * @type HTMLPurifier_URIParser
 */
@property HTMLPurifier_URIParser* parser;

/**
 * @type bool
 */
@property NSNumber* embedsResource;

/**
 * @param bool $embeds_resource Does the URI here result in an extra HTTP request?
 */
-(id)initWithNumber:(NSNumber*)new_embeds_resource;


@end
