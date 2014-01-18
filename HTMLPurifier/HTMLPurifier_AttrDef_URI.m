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
#import "HTMLPurifier_URIDefinition.h"
#import "BasicPHP.h"
#import "HTMLPurifier_URIParser.h"
//#import "HTMLPurifier_URIScheme.h"


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
    if (new_embeds_resource.boolValue)
    {
        embedsResource = new_embeds_resource;
    }
    else
    {
        embedsResource = @NO;
    }
    return self;
}

/**
 * @param string $string
 * @return HTMLPurifier_AttrDef_URI
 */
-(HTMLPurifier_AttrDef_URI*) make:(NSString*)string
{
    NSNumber* embeds = @([string isEqual:@"embedded"]);
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
    return nil;
//    if ([config get:@"URI.Disable"])
//    {
//        return nil;
//    }
//    
//    uri = [super parseCDATAWithString:uri];
//    
//    // parse the URI
//    HTMLPurifier_URI* newUri = [parser parse:uri];
//    if (!newUri)
//    {
//        return nil;
//    }
//    
//    // add embedded flag to context for validators
//    [context registerWithName:@"EmbeddedURI" ref:embedsResource];
//    
//    BOOL ok = NO;
//    do {
//        
//        // generic validation
//        NSString* result = [newUri validateWithConfig:config context:context];
//        if (!result)
//        {
//            break;
//        }
//        
//        // chained filtering
//        HTMLPurifier_URIDefinition* uri_def = (HTMLPurifier_URIDefinition*)[config getDefinition:@"URI"];
//        BOOL result_bool = [uri_def filterWithUri:newUri config:config context:context];
//        if (!result_bool)
//        {
//            break;
//        }
//        
//        // scheme-specific validation
//        HTMLPurifier_URIScheme* scheme_obj = [newUri getSchemeObjWithConfig:config Context:context];
//        if (!scheme_obj)
//        {
//            break;
//        }
//        if (embedsResource && ![scheme_obj browsable])
//        {
//            break;
//        }
//        result = [scheme_obj validateWithString:newUri Config:config Context:context];
//        if (!result)
//        {
//            break;
//        }
//        
//        // Post chained filtering
//        result_bool = [uri_def postFilterWithUri:uri Config:config Context:context];
//        if (!result)
//        {
//            break;
//        }
//        
//        // survived gauntlet
//        ok = YES;
//        
//    } while (NO);
//    
//    [context destroy:@"EmbeddedURI"];
//    if (!ok)
//    {
//        return nil;
//    }
//    // back to string
//    return [newUri toString];
}

@end
