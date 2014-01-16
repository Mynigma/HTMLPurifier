//
//  HTMLPurifier_URI.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

/**
 * HTML Purifier's internal representation of a URI.
 * @note
 *      Internal data-structures are completely escaped. If the data needs
 *      to be used in a non-URI context (which is very unlikely), be sure
 *      to decode it first. The URI may not necessarily be well-formed until
 *      validate() is called.
 */

#import "HTMLPurifier_URI.h"

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

///**
// * Retrieves a scheme object corresponding to the URI's scheme/default
// * @param HTMLPurifier_Config $config
// * @param HTMLPurifier_Context $context
// * @return HTMLPurifier_URIScheme Scheme object appropriate for validating this URI
// */
//public function getSchemeObj($config, $context)
//{
//    $registry = HTMLPurifier_URISchemeRegistry::instance();
//    if ($this->scheme !== null) {
//        $scheme_obj = $registry->getScheme($this->scheme, $config, $context);
//        if (!$scheme_obj) {
//            return false;
//        } // invalid scheme, clean it out
//    } else {
//        // no scheme: retrieve the default one
//        $def = $config->getDefinition('URI');
//        $scheme_obj = $def->getDefaultScheme($config, $context);
//        if (!$scheme_obj) {
//            // something funky happened to the default scheme object
//            trigger_error(
//                          'Default scheme object "' . $def->defaultScheme . '" was not readable',
//                          E_USER_WARNING
//                          );
//            return false;
//        }
//    }
//    return $scheme_obj;
//}
//
///**
// * Generic validation method applicable for all schemes. May modify
// * this URI in order to get it into a compliant form.
// * @param HTMLPurifier_Config $config
// * @param HTMLPurifier_Context $context
// * @return bool True if validation/filtering succeeds, false if failure
// */
//public function validate($config, $context)
//{
//    // ABNF definitions from RFC 3986
//    $chars_sub_delims = '!$&\'()*+,;=';
//    $chars_gen_delims = ':/?#[]@';
//    $chars_pchar = $chars_sub_delims . ':@';
//    
//    // validate host
//    if (!is_null($this->host)) {
//        $host_def = new HTMLPurifier_AttrDef_URI_Host();
//        $this->host = $host_def->validate($this->host, $config, $context);
//        if ($this->host === false) {
//            $this->host = null;
//        }
//    }
//    
//    // validate scheme
//    // NOTE: It's not appropriate to check whether or not this
//    // scheme is in our registry, since a URIFilter may convert a
//    // URI that we don't allow into one we do.  So instead, we just
//    // check if the scheme can be dropped because there is no host
//    // and it is our default scheme.
//    if (!is_null($this->scheme) && is_null($this->host) || $this->host === '') {
//        // support for relative paths is pretty abysmal when the
//        // scheme is present, so axe it when possible
//        $def = $config->getDefinition('URI');
//        if ($def->defaultScheme === $this->scheme) {
//            $this->scheme = null;
//        }
//    }
//    
//    // validate username
//    if (!is_null($this->userinfo)) {
//        $encoder = new HTMLPurifier_PercentEncoder($chars_sub_delims . ':');
//        $this->userinfo = $encoder->encode($this->userinfo);
//    }
//    
//    // validate port
//    if (!is_null($this->port)) {
//        if ($this->port < 1 || $this->port > 65535) {
//            $this->port = null;
//        }
//    }
//    
//    // validate path
//    $segments_encoder = new HTMLPurifier_PercentEncoder($chars_pchar . '/');
//    if (!is_null($this->host)) { // this catches $this->host === ''
//        // path-abempty (hier and relative)
//        // http://www.example.com/my/path
//        // //www.example.com/my/path (looks odd, but works, and
//        //                            recognized by most browsers)
//        // (this set is valid or invalid on a scheme by scheme
//        // basis, so we'll deal with it later)
//        // file:///my/path
//        // ///my/path
//        $this->path = $segments_encoder->encode($this->path);
//    } elseif ($this->path !== '') {
//        if ($this->path[0] === '/') {
//            // path-absolute (hier and relative)
//            // http:/my/path
//            // /my/path
//            if (strlen($this->path) >= 2 && $this->path[1] === '/') {
//                // This could happen if both the host gets stripped
//                // out
//                // http://my/path
//                // //my/path
//                $this->path = '';
//            } else {
//                $this->path = $segments_encoder->encode($this->path);
//            }
//        } elseif (!is_null($this->scheme)) {
//            // path-rootless (hier)
//            // http:my/path
//            // Short circuit evaluation means we don't need to check nz
//            $this->path = $segments_encoder->encode($this->path);
//        } else {
//            // path-noscheme (relative)
//            // my/path
//            // (once again, not checking nz)
//            $segment_nc_encoder = new HTMLPurifier_PercentEncoder($chars_sub_delims . '@');
//            $c = strpos($this->path, '/');
//            if ($c !== false) {
//                $this->path =
//                $segment_nc_encoder->encode(substr($this->path, 0, $c)) .
//                $segments_encoder->encode(substr($this->path, $c));
//            } else {
//                $this->path = $segment_nc_encoder->encode($this->path);
//            }
//        }
//    } else {
//        // path-empty (hier and relative)
//        $this->path = ''; // just to be safe
//    }
//    
//    // qf = query and fragment
//    $qf_encoder = new HTMLPurifier_PercentEncoder($chars_pchar . '/?');
//    
//    if (!is_null($this->query)) {
//        $this->query = $qf_encoder->encode($this->query);
//    }
//    
//    if (!is_null($this->fragment)) {
//        $this->fragment = $qf_encoder->encode($this->fragment);
//    }
//    return true;
//}
//
///**
// * Convert URI back to string
// * @return string URI appropriate for output
// */
//public function toString()
//{
//    // reconstruct authority
//    $authority = null;
//    // there is a rendering difference between a null authority
//    // (http:foo-bar) and an empty string authority
//    // (http:///foo-bar).
//    if (!is_null($this->host)) {
//        $authority = '';
//        if (!is_null($this->userinfo)) {
//            $authority .= $this->userinfo . '@';
//        }
//        $authority .= $this->host;
//        if (!is_null($this->port)) {
//            $authority .= ':' . $this->port;
//        }
//    }
//    
//    // Reconstruct the result
//    // One might wonder about parsing quirks from browsers after
//    // this reconstruction.  Unfortunately, parsing behavior depends
//    // on what *scheme* was employed (file:///foo is handled *very*
//    // differently than http:///foo), so unfortunately we have to
//    // defer to the schemes to do the right thing.
//    $result = '';
//    if (!is_null($this->scheme)) {
//        $result .= $this->scheme . ':';
//    }
//    if (!is_null($authority)) {
//        $result .= '//' . $authority;
//    }
//    $result .= $this->path;
//    if (!is_null($this->query)) {
//        $result .= '?' . $this->query;
//    }
//    if (!is_null($this->fragment)) {
//        $result .= '#' . $this->fragment;
//    }
//    
//    return $result;
//}
//
///**
// * Returns true if this URL might be considered a 'local' URL given
// * the current context.  This is true when the host is null, or
// * when it matches the host supplied to the configuration.
// *
// * Note that this does not do any scheme checking, so it is mostly
// * only appropriate for metadata that doesn't care about protocol
// * security.  isBenign is probably what you actually want.
// * @param HTMLPurifier_Config $config
// * @param HTMLPurifier_Context $context
// * @return bool
// */
//public function isLocal($config, $context)
//{
//    if ($this->host === null) {
//        return true;
//    }
//    $uri_def = $config->getDefinition('URI');
//    if ($uri_def->host === $this->host) {
//        return true;
//    }
//    return false;
//}
//
///**
// * Returns true if this URL should be considered a 'benign' URL,
// * that is:
// *
// *      - It is a local URL (isLocal), and
// *      - It has a equal or better level of security
// * @param HTMLPurifier_Config $config
// * @param HTMLPurifier_Context $context
// * @return bool
// */
//public function isBenign($config, $context)
//{
//    if (!$this->isLocal($config, $context)) {
//        return false;
//    }
//    
//    $scheme_obj = $this->getSchemeObj($config, $context);
//    if (!$scheme_obj) {
//        return false;
//    } // conservative approach
//    
//    $current_scheme_obj = $config->getDefinition('URI')->getDefaultScheme($config, $context);
//    if ($current_scheme_obj->secure) {
//        if (!$scheme_obj->secure) {
//            return false;
//        }
//    }
//    return true;
//}


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

@end
