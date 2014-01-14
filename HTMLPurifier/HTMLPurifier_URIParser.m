//
//  HTMLPurifier_URIParser.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 14.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_URIParser.h"
#import "BasicPHP.h"
#import "HTMLPurifier_URI.h"
#import "HTMLPurifier_PercentEncoder.h"

@implementation HTMLPurifier_URIParser

- (id)init
{
    self = [super init];
    if (self) {
        percentEncoder = [HTMLPurifier_PercentEncoder new];
    }
    return self;
}

- (HTMLPurifier_URI*)parse:(NSString*)theUri;
{
    NSString* uri = [percentEncoder normalize:theUri];

    // Regexp is as per Appendix B.
    // Note that ["<>] are an addition to the RFC's recommended
    // characters, because they represent external delimeters.
    NSString* r_URI = @"!(([a-zA-Z0-9\\.\\+\\-]+):)?(//([^/?#\"<>]*))?([^?#\"<>]*)(\\?([^#\"<>]*))?(#([^\"<>]*))?!";

    NSMutableArray* matches = [NSMutableArray new];
    NSMutableArray* result = preg_match(r_URI, uri, matches);

    if (!result) return nil; // *really* invalid URI

    // seperate out parts
    NSString* scheme     = [matches[1] length]>0 ? matches[2] : nil;
    NSString* authority  = [matches[3] length]>0 ? matches[4] : nil;
    NSString* path       = matches[5]; // always present, can be empty
    NSString* query      = [matches[6] length]>0 ? matches[7] : nil;
    NSString* fragment   = [matches[8] length]>0 ? matches[9] : nil;

    NSString* userinfo   = nil;
    NSString* host       = nil;
    NSNumber* port = nil;

    // further parse authority
    if (authority) {
        NSString* r_authority = @"/^((.+?)@)?(\\[[^\\]]+\\]|[^:]*)(:(\\d*))?/";
        NSMutableArray* matches = [NSMutableArray new];
        preg_match(r_authority, authority, matches);
        userinfo   = [matches[1] length]>0 ? matches[2] : nil;
        host       = [matches[3] length]>0 ? matches[3] : @"";
        NSString* portString       = [matches[4] length]>0 ? matches[5] : nil;
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        port = [f numberFromString:portString];
    }

    return [[HTMLPurifier_URI alloc] initWithScheme:scheme userinfo:userinfo host:host port:port path:path query:query fragment:fragment];
}




@end
