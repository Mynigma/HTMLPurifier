//
//  HTMLPurifier_AttrDef_URI.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//


/**
 * Validates a URI as defined by RFC 3986.
 * @note Scheme-specific mechanics deferred to HTMLPurifier_URIScheme
 */
#import "HTMLPurifier_AttrDef_URI.h"
#import "HTMLPurifier_URI.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_URI

/**
 * @type HTMLPurifier_URIParser
 */
@synthesize parser;

/**
 * @type bool
 */
@synthesize embedsResource;

/**
 * @param bool $embeds_resource Does the URI here result in an extra HTTP request?
 */
-(id)initWithNumber:(NSNumber*)new_embeds_resource
{
    self = [super init];
    parser = [HTMLPurifier_URIParser new];
    if (new_embeds_resource)
    {
        embedsResource = new_embeds_resource;
    }
    else
    {
        embedsResource = NO;
    }
    return self;
}

/**
 * @param string $string
 * @return HTMLPurifier_AttrDef_URI
 */
-(HTMLPurifier_AttrDef_URI*) make:(NSString*)string
{
    NSNumber* embeds = ([NSNumber numberWithBool:[string isEqual:@"embedded"]]);
    HTMLPurifier_AttrDef_URI* copy = [HTMLPurifier_AttrDef_URI alloc];
    return [copy initWithNumber:embeds];
}

/**
 * @param string $uri
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithUri:(NSString *)uri config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    if ([config get:@"URI.Disable"])
    {
        return nil;
    }
    
    uri = [super parseCDATAWithString:uri];
    
    // parse the URI
    HTMLPurifier_URI* newUri = [parser parseWithString:uri];
    if (!newUri)
    {
        return nil;
    }
    
    // add embedded flag to context for validators
    [context registerWithName:@"EmbeddedURI" ref:embedsResource];
    
    BOOL ok = NO;
    do {
        
        // generic validation
        $result = $uri->validate($config, $context);
        if (!$result) {
            break;
        }
        
        // chained filtering
        $uri_def = $config->getDefinition('URI');
        $result = $uri_def->filter($uri, $config, $context);
        if (!$result) {
            break;
        }
        
        // scheme-specific validation
        $scheme_obj = $uri->getSchemeObj($config, $context);
        if (!$scheme_obj) {
            break;
        }
        if ($this->embedsResource && !$scheme_obj->browsable) {
            break;
        }
        $result = $scheme_obj->validate($uri, $config, $context);
        if (!$result) {
            break;
        }
        
        // Post chained filtering
        $result = $uri_def->postFilter($uri, $config, $context);
        if (!$result) {
            break;
        }
        
        // survived gauntlet
        $ok = true;
        
    } while (false);
    
    $context->destroy('EmbeddedURI');
    if (!$ok) {
        return false;
    }
    // back to string
    return $uri->toString();
}

@end
