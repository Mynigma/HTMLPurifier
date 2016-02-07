//
//   HTMLPurifier_AttrDef.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.


#import "HTMLPurifier_AttrDef.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Encoder.h"

@implementation HTMLPurifier_AttrDef


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

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _minimized = [[coder decodeObjectForKey:@"minimized"] boolValue];
        _required = [[coder decodeObjectForKey:@"required"] boolValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:@(_minimized) forKey:@"minimized"];
    [coder encodeObject:@(_required) forKey:@"required"];
}


- (BOOL)isEqual:(HTMLPurifier_AttrDef*)other
{
    if (other == self)
        return YES;
    
    if(![other isKindOfClass:[HTMLPurifier_AttrDef class]])
        return NO;
    
    BOOL minimizedEqual = (self.minimized == [other minimized]);
    BOOL requiredEqual = (self.required == [other required]);
    
    return minimizedEqual && requiredEqual;
}

- (NSUInteger)hash
{
    return self.minimized?0:1 ^ self.required?0:2 ^ [super hash];
}








- (NSString*)parseCDATAWithString:(NSString*)string
{
    string = trim(string);
    string = (NSString*)str_replace(@[@"\n", @"\t", @"\r"], @" ", string);
    return string;
}


/**
 * Factory method for creating this class from a string.
 * @param string $string String construction info
 * @return HTMLPurifier_AttrDef Created AttrDef object corresponding to $string
 */
- (HTMLPurifier_AttrDef*)make:(NSString*)string
{
    // default implementation, return a flyweight of this object.
    // If $string has an effect on the returned object (i.e. you
    // need to overload this method), it is best
    // to clone or instantiate new copies. (Instantiation is safer.)
    return self;
}


- (NSString*) validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    //NSLOG"Calling validateWithString on HTMLPurifier_AttrDef!!");
    return nil;
}



/**
 * Removes spaces from rgb(0, 0, 0) so that shorthand CSS properties work
 * properly. THIS IS A HACK!
 * @param string $string a CSS colour definition
 * @return string
 */
- (NSString*)mungeRgbWithString:(NSString*)string
{
    return preg_replace_3(@"rgb\\((\\d+)\\s*,\\s*(\\d+)\\s*,\\s*(\\d+)\\)", @"rgb(\\1,\\2,\\3)", string);
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
                NSString* characterString = [HTMLPurifier_Encoder unichr:(int)hexdec(code)];
                characterString = [HTMLPurifier_Encoder cleanUTF8:characterString];
                if (!characterString || [characterString isEqual:@""])
                {
                    continue;
                }
                [ret appendString:characterString];
                if (i < c && ![trim([string substringWithRange:NSMakeRange(i, 1)]) isEqual:@""]) {
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

- (id)copyWithZone:(NSZone *)zone
{
    HTMLPurifier_AttrDef* newAttrDef = [[[self class] allocWithZone:zone] init];

    [newAttrDef setMinimized:self.minimized];
    [newAttrDef setRequired:self.required];

    return newAttrDef;
}

@end
