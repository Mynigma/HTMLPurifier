//
//  HTMLPurifier_PercentEncoder.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 14.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_PercentEncoder.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_PercentEncoder



/**
 * String of characters that should be preserved while using encode().
 * @param bool $preserve
 */

- (id)init
{
    self = [super init];
    if (self) {



    }
    return self;
}

- (id)initWithPreservedChars:(NSString*)preservedCharacters
{
    self = [super init];
    if (self) {
        preservedChars = preservedChars ? [NSCharacterSet characterSetWithCharactersInString:preservedCharacters] : nil;
    }
    return self;
}

    /**
     * Our replacement for urlencode, it encodes all non-reserved characters,
     * as well as any extra characters that were instructed to be preserved.
     * @note
     *      Assumes that the string has already been normalized, making any
     *      and all percent escape sequences valid. Percents will not be
     *      re-escaped, regardless of their status in $preserve
     * @param string $string String to be encoded
     * @return string Encoded string.
     */
- (NSString*)encode:(NSString*)string
    {
        if(preservedChars)
            return [string stringByAddingPercentEncodingWithAllowedCharacters:preservedChars];
        else
            return [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
     }

    /**
     * Fix up percent-encoding by decoding unreserved characters and normalizing.
     * @warning This function is affected by $preserve, even though the
     *          usual desired behavior is for this not to preserve those
     *          characters. Be careful when reusing instances of PercentEncoder!
     * @param string $string String to normalize
     * @return string
     */
- (NSString*)normalize:(NSString*)string
    {
        if (string.length==0) {
            return @"";
        }
        NSArray* parts = explode(@"\%", string);
        NSMutableString* ret = array_shift(parts);
        for(NSString* part in parts)
        {
           NSInteger length = part.length;
            if (length < 2) {
                [ret appendFormat:@"%%25%@", part];
                continue;
            }
            NSString* encoding = [part substringWithRange:NSMakeRange(0, 2)];
            NSString* text  = substr(part, 2);
            if (!ctype_xdigit(encoding)) {
                [ret appendFormat:@"%%25%@", part];
                continue;
            }
            NSScanner *scanner = [NSScanner scannerWithString:encoding];
            unsigned int intCode = 0;
            [scanner scanHexInt:&intCode];
            if ([preservedChars characterIsMember:(unichar)intCode]) {
                [ret appendFormat:@"%c%@", intCode, text];
                continue;
            }
            encoding = [encoding uppercaseString];
            [ret appendFormat:@"%%%@%@", encoding, text];
        }
        return ret;
    }



@end
