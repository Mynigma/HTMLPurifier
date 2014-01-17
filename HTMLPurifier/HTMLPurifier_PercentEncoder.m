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
    return [self initWithPreservedChars:nil];
}

- (id)initWithPreservedChars:(NSString*)preservedCharacters
{
    self = [super init];
    if (self) {
        NSMutableCharacterSet* newPreservedCharacters = [NSMutableCharacterSet new];

        [newPreservedCharacters addCharactersInString:@"-_~."];
        [newPreservedCharacters addCharactersInRange:NSMakeRange('a', 'z'-'a' + 1)];
        [newPreservedCharacters addCharactersInRange:NSMakeRange('A', 'Z'-'A' + 1)];
        [newPreservedCharacters addCharactersInRange:NSMakeRange('0', '9'-'0' + 1)];
        //[newPreservedCharacters addCharactersInRange:NSMakeRange(0x80, 0xFF - 0x80)];
        if(preservedCharacters)
            [newPreservedCharacters formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:preservedCharacters]];

        preservedChars = newPreservedCharacters;

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
        NSMutableString* ret = [NSMutableString new];
        NSInteger c = string.length;
        for (NSInteger i = 0; i < c; i++)
        {
            unichar character = [string characterAtIndex:i];
            if (character != '%' && ![preservedChars characterIsMember:character])
            {
                [ret appendFormat: @"%%%02X", character];
            }
            else
            {
                [ret appendFormat: @"%c", character];
            }
        }
        return ret;
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
        NSMutableArray* parts = [explode(@"%", string) mutableCopy];
        NSMutableString* ret = [array_shift(parts) mutableCopy];
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
            if (([preservedChars characterIsMember:(unichar)intCode]) && (intCode<0x80))
            {
                [ret appendFormat:@"%c%@", intCode, text];
                continue;
            }
            encoding = [encoding uppercaseString];
            [ret appendFormat:@"%%%@%@", encoding, text];
        }
        return ret;
    }



@end
