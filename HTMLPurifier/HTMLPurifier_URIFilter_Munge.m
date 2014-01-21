//
//  HTMLPurifier_URIFilter_Munge.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_URIFilter_Munge.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_URIParser.h"
#import "HTMLPurifier_URI.h"
#import "HTMLPurifier_URIScheme.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Token.h"

@implementation HTMLPurifier_URIFilter_Munge

/**
 * @type string
 */
//public $name = 'Munge';

/**
 * @type bool
 */
//public $post = true;

/**
 * @type string
 */
@synthesize target;

/**
 * @type HTMLPurifier_URIParser
 */
@synthesize parser;

/**
 * @type bool
 */
@synthesize doEmbed;

/**
 * @type string
 */
@synthesize secretKey;

/**
 * @type array
 */
@synthesize replace; // = array();

-(id) init
{
    self = [super init];
    
    super.name = @"Munge";
    super.post = YES;
    
    self.replace = [NSMutableDictionary new];
    
    return self;
}

/**
 * @param HTMLPurifier_Config $config
 * @return bool
 */
-(BOOL) prepare:(HTMLPurifier_Config*)config
{
    target = (NSString*)[config get:[@"URI." stringByAppendingString:super.name]];
    parser = [HTMLPurifier_URIParser new];
    doEmbed = (BOOL)[(NSNumber*)[config get:@"URI.MungeResources"] boolValue];
    secretKey = (NSString*)[config get:@"URI.MungeSecretKey"];
    return YES;
}

/**
 * @param HTMLPurifier_URI $uri
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool
 */
-(BOOL) filter:(HTMLPurifier_URI**)uri config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if ([context getWithName:@"EmbeddedURI" ignoreError:YES] && !doEmbed)
    {
        return YES;
    }
    
    HTMLPurifier_URIScheme* scheme_obj = [*uri getSchemeObj:config context:context];
    if (!scheme_obj)
    {
        return YES;
        // ignore unknown schemes, maybe another postfilter did it
    }
    if (![scheme_obj browsable])
    {
        return true;
        // ignore non-browseable schemes, since we can't munge those in a reasonable way
    }
    if ([*uri isBenign:config context:context])
    {
        return TRUE;
        // don't redirect if a benign URL
    }
    
    [self makeReplace:*uri config:config context:context];
    
    NSString* new_uri_string = target.mutableCopy;

    for (NSString* tmp in replace.allKeys) {
        
        //array_map(@"rawurlencode",replace)
        //strtr(target,replace);
       [new_uri_string stringByReplacingOccurrencesOfString:tmp withString:[replace[tmp] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    HTMLPurifier_URI* new_uri = [parser parse:new_uri_string];
    // don't redirect if the target host is the same as the
    // starting host
    if ([[*uri host] isEqual:[new_uri host]])
    {
        return YES;
    }
    *uri = new_uri; // overwrite
    return YES;
}

/**
 * @param HTMLPurifier_URI $uri
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 */
-(void) makeReplace:(HTMLPurifier_URI*)uri config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    NSString* string = [uri toString];
    // always available
    [replace setObject:string forKey:@"%s"];
    [replace setObject:(NSString*)[context getWithName:@"EmbeddedURI" ignoreError:YES] forKey:@"%r"];
    HTMLPurifier_Token* token = (HTMLPurifier_Token*) [context getWithName:@"CurrentToken" ignoreError:YES];
    [replace setObject:(token ? [token name] :nil) forKey:@"%n"];
    [replace setObject:(NSString*)[context getWithName:@"CurrentAttr" ignoreError:YES] forKey:@"%m"];
    [replace setObject:(NSString*)[context getWithName:@"CurrentCSSProperty" ignoreError:YES] forKey:@"%p"];
    // not always available
    if (secretKey) {
        [replace setObject:hash_hmac(@"sha256",string,secretKey) forKey:@"%t"];
    }
}

@end
