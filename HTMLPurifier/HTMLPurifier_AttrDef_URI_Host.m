//
//  HTMLPurifier_AttrDef_URI_Host.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

/**
 * Validates a host according to the IPv4, IPv6 and DNS (future) specifications.
 */
#import "HTMLPurifier_AttrDef_URI_Host.h"
#import "HTMLPurifier_Config.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_URI_Host

/**
 * IPv4 sub-validator.
 * @type HTMLPurifier_AttrDef_URI_IPv4
 */
@synthesize ipv4;

/**
 * IPv6 sub-validator.
 * @type HTMLPurifier_AttrDef_URI_IPv6
 */
@synthesize ipv6;

-(id) init
{
    self = [super init];
    ipv4 = [HTMLPurifier_AttrDef_URI_IPv4 new];
    ipv6 = [HTMLPurifier_AttrDef_URI_IPv6 new];
    return self;
}

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    NSUInteger length = [string length];
    // empty hostname is OK; it's usually semantically equivalent:
    // the default host as defined by a URI scheme is used:
    //
    //      If the URI scheme defines a default for host, then that
    //      default applies when the host subcomponent is undefined
    //      or when the registered name is empty (zero length).
    if ([string isEqual:@""])
    {
        return @"";
    }
    if (length > 1 && ([string characterAtIndex:0] == '[') &&
        ([string characterAtIndex:length - 1]== ']'))
    {
        //IPv6
        NSString* ip = [string substringWithRange:NSMakeRange(1, length-2)];
        NSString* valid = [ipv6 validateWithString:ip config:config context:context];
        if (!valid)
        {
            return nil;
        }
        return [NSString stringWithFormat:@"[%@]",valid];
    }
    
    // need to do checks on unusual encodings too
    NSString* checke_ipv4 = [ipv4 validateWithString:string config:config context:context];
    if (checke_ipv4)
    {
        return checke_ipv4;
    }
    
    // A regular domain name.
    
    // This doesn't match I18N domain names, but we don't have proper IRI support,
    // so force users to insert Punycode.
    
    // There is not a good sense in which underscores should be
    // allowed, since it's technically not! (And if you go as
    // far to allow everything as specified by the DNS spec...
    // well, that's literally everything, modulo some space limits
    // for the components and the overall name (which, by the way,
    // we are NOT checking!).  So we (arbitrarily) decide this:
    // let's allow underscores wherever we would have allowed
    // hyphens, if they are enabled.  This is a pretty good match
    // for browser behavior, for example, a large number of browsers
    // cannot handle foo_.example.com, but foo_bar.example.com is
    // fairly well supported.
    unichar underscore = [(NSNumber*)[config get:@"Core.AllowHostnameUnderscore"] boolValue]?'_':'';
    
    // The productions describing this are:
    NSString* a   = @"[a-z]";     // alpha
    NSString* an  = @"[a-z0-9]";  // alphanum
    NSString* and = [NSString stringWithFormat:@"[a-z0-9-%c]",underscore]; // alphanum | "-"
    // domainlabel = alphanum | alphanum *( alphanum | "-" ) alphanum
    NSString* domainlabel = [NSString stringWithFormat:@"%@(%@*%@)?",an,and,an];
    // toplabel    = alpha | alpha *( alphanum | "-" ) alphanum
    NSString* toplabel = [NSString stringWithFormat:@"%@(%@*%@)?",a,and,an];
    // hostname    = *( domainlabel "." ) toplabel [ "." ]
    if (preg_match_2([NSString stringWithFormat:@"^(%@\\.)*%@\\.?$",domainlabel,toplabel],string))
    {
        return string;
    }
    
    // If we have Net_IDNA2 support, we can support IRIs by
    // punycoding them. (This is the most portable thing to do,
    // since otherwise we have to assume browsers support
    /*
    if ($config->get('Core.EnableIDNA')) {
        $idna = new Net_IDNA2(array('encoding' => 'utf8', 'overlong' => false, 'strict' => true));
        // we need to encode each period separately
        $parts = explode('.', $string);
        try {
            $new_parts = array();
            foreach ($parts as $part) {
                $encodable = false;
                for ($i = 0, $c = strlen($part); $i < $c; $i++) {
                    if (ord($part[$i]) > 0x7a) {
                        $encodable = true;
                        break;
                    }
                }
                if (!$encodable) {
                    $new_parts[] = $part;
                } else {
                    $new_parts[] = $idna->encode($part);
                }
            }
            $string = implode('.', $new_parts);
            if (preg_match("/^($domainlabel\.)*$toplabel\.?$/i", $string)) {
                return $string;
            }
        } catch (Exception $e) {
            // XXX error reporting
        }
    }
     */
    return nil;
}

@end
