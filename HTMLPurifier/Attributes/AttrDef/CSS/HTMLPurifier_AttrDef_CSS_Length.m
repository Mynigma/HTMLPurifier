//
//   HTMLPurifier_AttrDef_CSS_Length.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.


#import "HTMLPurifier_AttrDef_CSS_Length.h"
#import "HTMLPurifier_Length.h"

@implementation HTMLPurifier_AttrDef_CSS_Length


/**
 * @param HTMLPurifier_Length|string $min Minimum length, or null for no bound. String is also acceptable.
 * @param HTMLPurifier_Length|string $max Maximum length, or null for no bound. String is also acceptable.
 */

- (id)initWithMin:(NSString*)newMin max:(NSString*)newMax
{
    self = [super init];
    if (self) {
        _min = (HTMLPurifier_Length*)([newMin isKindOfClass:[HTMLPurifier_Length class]] ? newMin : (newMin ? [HTMLPurifier_Length makeWithS:(NSString*)newMin] : nil));
        _max = (HTMLPurifier_Length*)([newMax isKindOfClass:[HTMLPurifier_Length class]] ? newMax : (newMax ? [HTMLPurifier_Length makeWithS:(NSString*)newMax] : nil));
    }
    return self;
}

- (id)initWithMin:(NSObject*)newMin
{
    return [self initWithMin:newMin max:nil];
}



- (id)init
{
    return [self initWithMin:nil max:nil];
}




- (instancetype)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _min = [coder decodeObjectForKey:@"min"];
        _max = [coder decodeObjectForKey:@"max"];
    }
    return self;
}



- (void)encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_min forKey:@"min"];
    [encoder encodeObject:_max forKey:@"max"];
}


- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else if(![other isKindOfClass:[HTMLPurifier_AttrDef_CSS_Length class]])
    {
        return NO;
    }
    else
    {
        return ((!self.min && ![(HTMLPurifier_AttrDef_CSS_Length*)other min]) || [self.min isEqual:[(HTMLPurifier_AttrDef_CSS_Length*)other min]]) && ((!self.max && ![(HTMLPurifier_AttrDef_CSS_Length*)other max]) || [self.max isEqual:[(HTMLPurifier_AttrDef_CSS_Length*)other max]]);
    }
}

- (NSUInteger)hash
{
    return [_min hash] ^ [_max hash] ^ [super hash];
}














/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
- (NSString*)validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    string = [self parseCDATAWithString:string];

    // Optimizations
    if ([string isEqual:@""]) {
        return nil;
    }
    if ([string isEqual:@"0"]) {
        return @"0";
    }
    if (string.length == 1) {
        return nil;
    }

    HTMLPurifier_Length* length = [HTMLPurifier_Length makeWithS:string];
    if (![length isValid])
    {
        return nil;
    }

    if (self.min) {
        NSNumber* c = [length compareTo:self.min];
        if (!c) {
            return nil;
        }
        if (c.floatValue < 0) {
            return nil;
        }
    }
    if (self.max) {
        NSNumber* c = [length compareTo:self.max];
        if (!c) {
            return nil;
        }
        if (c.floatValue > 0) {
            return nil;
        }
    }
    return [length toString];
}


@end
