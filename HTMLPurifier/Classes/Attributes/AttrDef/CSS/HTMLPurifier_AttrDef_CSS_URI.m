//
//   HTMLPurifier_AttrDef_CSS_URI.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.


#import "HTMLPurifier_AttrDef_CSS_URI.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_CSS_URI

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

/**
 * @param string $uri_string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
- (NSString*)validateWithString:(NSString *)uri_string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context    {
    // parse the URI out of the string and then pass it onto
    // the parent object

    uri_string = [self parseCDATAWithString:uri_string];
    if (strpos(uri_string, @"url(") != 0) {
        return nil;
    }
    if ([uri_string length] > 4) {
        uri_string = [uri_string substringFromIndex:4];
    }
    else {
        return nil;
    }
    NSInteger new_length = uri_string.length - 1;
    if ([uri_string characterAtIndex:new_length] != ')') {
        return nil;
    }
    NSString* uri = trim([uri_string substringWithRange:NSMakeRange(0, new_length)]);

    if (uri.length>0 && ([uri characterAtIndex:0] == '\'' || [uri characterAtIndex:0] == '"')) {
        unichar quote = [uri characterAtIndex:0];
        new_length = uri.length - 1;
        if ([uri characterAtIndex:new_length] != quote) {
            return nil;
        }
        uri = [uri substringWithRange:NSMakeRange(1, new_length - 1)];
    }

    uri = [self expandCSSEscapeWithString:uri];

    NSString* result = [super validateWithString:uri config:config context:context];

    if (!result) {
        return nil;
    }

    // extra sanity check; should have been done by URI
    result = (NSString*)str_replace(@[@"\"", @"\\", @"\n", @"\x0c", @"\r"], @"", result);

    // suspicious characters are ()'; we're going to percent encode
    // them for safety.
    result = (NSString*)str_replace(@[@"(", @")", @"'"], @[@"%28", @"%29", @"%27"], result);

    // there's an extra bug where ampersands lose their escaping on
    // an innerHTML cycle, so a very unlucky query parameter could
    // then change the meaning of the URL.  Unfortunately, there's
    // not much we can do about that...
    return [NSString stringWithFormat:@"url(\"%@\")", result];
}


@end
