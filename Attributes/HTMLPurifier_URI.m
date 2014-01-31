//
//  HTMLPurifier_URI.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 13.01.14.


/**
 * HTML Purifier's internal representation of a URI.
 * @note
 *      Internal data-structures are completely escaped. If the data needs
 *      to be used in a non-URI context (which is very unlikely), be sure
 *      to decode it first. The URI may not necessarily be well-formed until
 *      validate() is called.
 */

#import "HTMLPurifier_URI.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_URIScheme.h"
#import "HTMLPurifier_URIDefinition.h"
#import "HTMLPurifier_URISchemeRegistry.h"
#import "HTMLPurifier_AttrDef_URI_Host.h"
#import "HTMLPurifier_PercentEncoder.h"
#import "BasicPHP.h"


@implementation HTMLPurifier_URI

/**
 * @param string $scheme
 * @param string $userinfo
 * @param string $host
 * @param int $port
 * @param string $path
 * @param string $query
 * @param string $fragment
 * @note Automatically normalizes scheme and port
 */
- (id)initWithScheme:(NSString*)scheme userinfo:(NSString*)userinfo host:(NSString*)host port:(NSNumber*)port path:(NSString*)path query:(NSString*)query fragment:(NSString*)fragment
{
    self = [super init];
    if (self) {
        _scheme = [scheme lowercaseString];
        _userinfo = userinfo;
        _host = host;
        _port = port;
        _path = path;
        _query = query;
        _fragment = fragment;
    }
    return self;
}

/**
 * Retrieves a scheme object corresponding to the URI's scheme/default
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return HTMLPurifier_URIScheme Scheme object appropriate for validating this URI
 */
-(HTMLPurifier_URIScheme*) getSchemeObj:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    HTMLPurifier_URISchemeRegistry* registry = [HTMLPurifier_URISchemeRegistry instance:nil];
    HTMLPurifier_URIScheme* scheme_obj = nil;
    if (self.scheme)
    {
        scheme_obj = [registry getScheme:self.scheme config:config context:context];
        if (!scheme_obj) {
            return nil;
        } // invalid scheme, clean it out
    }
    else
    {
        // no scheme: retrieve the default one
        HTMLPurifier_URIDefinition* def = (HTMLPurifier_URIDefinition*)[config getDefinition:@"URI"];
        scheme_obj = [def getDefaultScheme:config context:context];
        if (!scheme_obj) {
            // something funky happened to the default scheme object
            NSLog(@"Default scheme object %@ was not readable",def.defaultScheme);
            return nil;
        }
    }
    return scheme_obj;
}


/**
 * Generic validation method applicable for all schemes. May modify
 * this URI in order to get it into a compliant form.
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool True if validation/filtering succeeds, false if failure
 */
- (BOOL) validateWithConfig:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    // ABNF definitions from RFC 3986
    NSString* chars_sub_delims = @"!$&\'()*+,;=";
    //NSString* chars_gen_delims = @":/?#[]@";
    NSString* chars_pchar = [chars_sub_delims stringByAppendingString:@":@"];
    
    // validate host
    if (self.host) {
        HTMLPurifier_AttrDef_URI_Host* host_def = [HTMLPurifier_AttrDef_URI_Host new];
        // will be nil if validation fails
        self.host = [host_def validateWithString:self.host config:config context:context];
    }
    
    // validate scheme
    // NOTE: It's not appropriate to check whether or not this
    // scheme is in our registry, since a URIFilter may convert a
    // URI that we don't allow into one we do.  So instead, we just
    // check if the scheme can be dropped because there is no host
    // and it is our default scheme.
    if ((self.scheme && !self.host) || [self.host isEqual:@""])
    {
        // support for relative paths is pretty abysmal when the
        // scheme is present, so axe it when possible
        HTMLPurifier_URIDefinition* def = (HTMLPurifier_URIDefinition*)[config getDefinition:@"URI"];
        if ([[def defaultScheme] isEqual:self.scheme])
        {
            self.scheme = nil;
        }
    }
    
    // validate username
    if (self.userinfo)
    {
        HTMLPurifier_PercentEncoder* encoder = [[HTMLPurifier_PercentEncoder alloc] initWithPreservedChars:[chars_sub_delims stringByAppendingString:@":"]];
        self.userinfo = [encoder encode:self.userinfo];
    }
    
    // validate port
    if (self.port)
    {
        if ((self.port.intValue < 1) || (self.port.intValue > 65535))
        {
            self.port = nil;
        }
    }
    
    // validate path
    HTMLPurifier_PercentEncoder* segments_encoder = [[HTMLPurifier_PercentEncoder alloc] initWithPreservedChars:[chars_pchar stringByAppendingString:@"/"]];
    if (self.host)
    {   // this catches $this->host === ''
        // path-abempty (hier and relative)
        // http://www.example.com/my/path
        // //www.example.com/my/path (looks odd, but works, and
        //                            recognized by most browsers)
        // (this set is valid or invalid on a scheme by scheme
        // basis, so we'll deal with it later)
        // file:///my/path
        // ///my/path
        self.path = [segments_encoder encode:self.path];
    }
    else if (![self.path isEqual:@""])
    {
        if ([self.path characterAtIndex:0] == '/')
        {
            // path-absolute (hier and relative)
            // http:/my/path
            // /my/path
            if (self.path.length >= 2 && [self.path characterAtIndex:1] == '/')
            {
                // This could happen if both the host gets stripped
                // out
                // http://my/path
                // //my/path
                self.path = @"";
            }
            else
            {
                self.path = [segments_encoder encode:self.path];
            }
        }
        else if (self.scheme)
        {
            // path-rootless (hier)
            // http:my/path
            // Short circuit evaluation means we don't need to check nz
            self.path = [segments_encoder encode:self.path];
        }
        else
        {
            // path-noscheme (relative)
            // my/path
            // (once again, not checking nz)
            HTMLPurifier_PercentEncoder* segment_nc_encoder = [[HTMLPurifier_PercentEncoder alloc] initWithPreservedChars: [chars_sub_delims stringByAppendingString:@"@"]];
            NSInteger c = strpos(self.path, @"/");
            if (c != NSNotFound)
            {
                self.path = [[segment_nc_encoder encode:[self.path substringToIndex:c]]
                             stringByAppendingString: [segments_encoder encode:substr(self.path,c)]];
            }
            else
            {
                self.path = [segment_nc_encoder encode:self.path];
            }
        }
    }
    else
    {
        // path-empty (hier and relative)
        self.path = @""; // just to be safe
    }
    
    // qf = query and fragment
    HTMLPurifier_PercentEncoder* qf_encoder = [[HTMLPurifier_PercentEncoder alloc] initWithPreservedChars:
                                               [chars_pchar stringByAppendingString:@"/?"]];
    
    if (self.query)
    {
        self.query = [qf_encoder encode:self.query];
    }
    
    if (self.fragment)
    {
        self.fragment = [qf_encoder encode:self.fragment];
    }
    return YES;
}

/**
 * Convert URI back to string
 * @return string URI appropriate for output
 */
-(NSString*) toString
{
    // reconstruct authority
    NSString* authority = nil;
    // there is a rendering difference between a null authority
    // (http:foo-bar) and an empty string authority
    // (http:///foo-bar).
    if (self.host)
    {
        authority = @"";
        if (self.userinfo)
        {
            authority = [NSString stringWithFormat:@"%@%@@",authority,self.userinfo];
        }
        authority = [authority stringByAppendingString:self.host];
        if (self.port)
        {
            authority = [NSString stringWithFormat:@"%@:%@",authority,self.port];
        }
    }
    
    // Reconstruct the result
    // One might wonder about parsing quirks from browsers after
    // this reconstruction.  Unfortunately, parsing behavior depends
    // on what *scheme* was employed (file:///foo is handled *very*
    // differently than http:///foo), so unfortunately we have to
    // defer to the schemes to do the right thing.
    NSString* result = @"";
    if (self.scheme)
    {
        result = [NSString stringWithFormat:@"%@%@:",result,self.scheme];
    }
    if (authority)
    {
        result = [NSString stringWithFormat:@"%@//%@",result,authority];
    }
    result = [result stringByAppendingString:self.path];
    if (self.query)
    {
        result = [NSString stringWithFormat:@"%@?%@",result,self.query];
    }
    if (self.fragment)
    {
        result =[NSString stringWithFormat:@"%@#%@",result,self.fragment];
    }

    return result;
}

/**
 * Returns true if this URL might be considered a 'local' URL given
 * the current context.  This is true when the host is null, or
 * when it matches the host supplied to the configuration.
 *
 * Note that this does not do any scheme checking, so it is mostly
 * only appropriate for metadata that doesn't care about protocol
 * security.  isBenign is probably what you actually want.
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool
 */
-(BOOL) isLocal:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (!self.host) {
        return YES;
    }
    HTMLPurifier_URIDefinition* uri_def = (HTMLPurifier_URIDefinition*)[config getDefinition:@"URI"];
    if ([[uri_def host] isEqual:self.host])
    {
        return YES;
    }
    return NO;
}

/**
 * Returns true if this URL should be considered a 'benign' URL,
 * that is:
 *
 *      - It is a local URL (isLocal), and
 *      - It has a equal or better level of security
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool
 */
-(BOOL) isBenign:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (![self isLocal:config context:context])
    {
        return NO;
    }
    
    HTMLPurifier_URIScheme* scheme_obj = [self getSchemeObj:config context:context];
    if (!scheme_obj) {
        // conservative approach
        return NO;
    }
    HTMLPurifier_URIScheme* current_scheme_obj = [(HTMLPurifier_URIDefinition*)[config getDefinition:@"URI"] getDefaultScheme:config context:context];
    if ([current_scheme_obj secure])
    {
        if (![scheme_obj secure])
        {
            return NO;
        }
    }
    return YES;
}


- (NSString*)description
{
    return [NSString stringWithFormat:@"HTMLPurifier_URI: %@://%@:%@%@%@?%@#%@", _scheme, _host, _userinfo, _port, _path, _query, _fragment];
}

- (BOOL)isEqual:(HTMLPurifier_URI*)object
{
    if([object isKindOfClass:[HTMLPurifier_URI class]])
    {
        if(object.scheme)
        {
            if(![object.scheme isEqual:self.scheme])
                return NO;
        }
        else if(self.scheme)
            return NO;

        if(object.userinfo)
        {
            if(![object.userinfo isEqual:self.userinfo])
                return NO;
        }
        else if(self.userinfo)
            return NO;

        if(object.host)
        {
            if(![object.host isEqual:self.host])
                return NO;
        }
        else if(self.host)
            return NO;

        if(object.port)
        {
            if(![object.port isEqual:self.port])
                return NO;
        }
        else if(self.port)
            return NO;

        if(object.path)
        {
            if(![object.path isEqual:self.path])
                return NO;
        }
        else if(self.path)
            return NO;

        if(object.query)
        {
            if(![object.query isEqual:self.query])
                return NO;
        }
        else if(self.query)
            return NO;

        if(object.fragment)
        {
            if(![object.fragment isEqual:self.fragment])
                return NO;
        }
        else if(self.fragment)
            return NO;

        return YES;
    }

    return NO;
}

- (NSUInteger)hash
{
    return [self.scheme hash] + [self.userinfo hash] + [self.host hash] + [self.port hash] + [self.path hash] + [self.query hash] + [self.fragment hash];
}

- (id)copyWithZone:(NSZone *)zone
{
    HTMLPurifier_URI* newURI = [[[self class] allocWithZone:zone] init];

    [newURI setFragment:self.fragment];
    [newURI setHost:self.host];
    [newURI setPath:self.path];
    [newURI setPort:self.port];
    [newURI setQuery:self.query];
    [newURI setScheme:self.scheme];

    return newURI;
}

@end
