//
//  HTMLPurifier_AttrDef.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef

- (NSString*)parseCDATAWithString:(NSString*)string
{
    string = trim(string);
    string = str_replace(@[@"\n", @"\t", @"\r"], @" ", string);
    return string;
}

-(HTMLPurifier_AttrDef*)initWithString:(NSString*)string
{
    // default implementation, return a flyweight of this object.
    // If $string has an effect on the returned object (i.e. you
    // need to overload this method), it is best
    // to clone or instantiate new copies. (Instantiation is safer.)
    self = [super init];
    if (self) {
    }
    return self;
}


/**
 * Removes spaces from rgb(0, 0, 0) so that shorthand CSS properties work
 * properly. THIS IS A HACK!
 * @param string $string a CSS colour definition
 * @return string
 */
- (NSString*)mungeRgbWithString:(NSString*)string
{
    return preg_replace(@"/rgb\\((\\d+)\\s*,\\s*(\\d+)\\s*,\\s*(\\d+)\\)/", @"rgb(\\1,\\2,\\3)", string);
}

- (NSString*)expandCSSEscapeWithString:(NSString*)string
{
    // flexibly parse it
    NSMutableString* ret = [@"" mutableCopy];
    NSInteger c = string.length;
    for (NSInteger i = 0; i < c; i++)
    {
        if ([string characterAtIndex:i] == '\\') {
            i++;
            if (i >= c) {
                [ret appendString:@"\\"];
                break;
            }
            if (ctype_xdigit([string substringWithRange:NSMakeRange(i, 1)])) {
                NSMutableString* code = [[string substringWithRange:NSMakeRange(i, 1)] mutableCopy];
                i++;
                for (NSInteger a = 1; i < c && a < 6; i++, a++) {
                    if (!ctype_xdigit([string substringWithRange:NSMakeRange(i, 1)])) {
                        break;
                    }
                    [code appendString:[string substringWithRange:NSMakeRange(i, 1)]];
                }
                // We have to be extremely careful when adding
                // new characters, to make sure we're not breaking
                // the encoding.
                unichar character = [HTMLPurifier_Encoder unichrWith(hexdec($code));
                if ([HTMLPurifier_Encoder cleanUTF8Wit($char) === '') {
                    continue;
                }
                [ret appendFormat:@"%c", character];
                if (i < c && ![trim([string substringWithRange:NSMakeRange(i, 1)]) isEqualTo:@""]) {
                    i--;
                }
                continue;
            }
            if ([[string substringWithRange:NSMakeRange(i, 1)] isEqual:@"\n"]) {
                continue;
            }
        }
        [ret appendString:[string substringWithRange:NSMakeRange(i, 1)]];
    }
    return ret;
}


@end
