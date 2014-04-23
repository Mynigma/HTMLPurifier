//
//   HTMLPurifier_URIFilter_Munge.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.


#import "HTMLPurifier_URIFilter_Munge.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_URIParser.h"
#import "HTMLPurifier_URI.h"
#import "HTMLPurifier_URIScheme.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Token.h"
#import "HTMLPurifier_PercentEncoder.h"

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
    
    self.name = @"Munge";
    self.post = YES;
    
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
- (BOOL)filter:(HTMLPurifier_URI**)uri config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if ([(NSNumber*)[context getWithName:@"EmbeddedURI" ignoreError:YES] boolValue] && !doEmbed)
    {
        return YES;
    }
    
    HTMLPurifier_URIScheme* scheme_obj = [*uri getSchemeObj:config context:context];
    if (!scheme_obj)
    {
        return YES;
        // ignore unknown schemes, maybe another postfilter did it
    }
    if (![[scheme_obj browsable] boolValue])
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
    
    __block NSString* new_uri_string = target.mutableCopy;

    [replace enumerateKeysAndObjectsUsingBlock:^(NSString* tmp, NSObject* value, BOOL *stop) {
        NSString* replacement = nil;
        if([value isKindOfClass:[NSString class]])
        {
            HTMLPurifier_PercentEncoder* percentEncoder = [HTMLPurifier_PercentEncoder new];
            replacement = [percentEncoder encode:(NSString*)value];
                           //stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"-_."]];
            //ReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if(replacement)
            {
                new_uri_string = [new_uri_string stringByReplacingOccurrencesOfString:tmp withString:replacement];
            }
        }
        else
            new_uri_string = [new_uri_string stringByReplacingOccurrencesOfString:tmp withString:@""];
    }];

    
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
    if (string)
        [replace setObject:string forKey:@"%s"];
    NSNumber* embeddedURI = (NSNumber*)[context getWithName:@"EmbeddedURI" ignoreError:YES];
    if (embeddedURI)
        [replace setObject:embeddedURI?embeddedURI:@"" forKey:@"%r"];
    HTMLPurifier_Token* token = (HTMLPurifier_Token*) [context getWithName:@"CurrentToken" ignoreError:YES];
    [replace setObject:(token.name ? token.name :@"") forKey:@"%n"];
    NSString* currentAttr = (NSString*)[context getWithName:@"CurrentAttr" ignoreError:YES];
    [replace setObject:currentAttr?currentAttr:@"" forKey:@"%m"];
    NSString* currentCSSProperty = (NSString*)[context getWithName:@"CurrentCSSProperty" ignoreError:YES];
    [replace setObject:currentCSSProperty?currentCSSProperty:@"" forKey:@"%p"];
    // not always available
    if (secretKey) {
        NSData * hmac = hash_hmac(@"sha256",string,secretKey);
        NSString* hmacString = lowercase_dechex(hmac);
        [replace setObject:hmacString?hmacString:@"" forKey:@"%t"];
    }
}

@end
