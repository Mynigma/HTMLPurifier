//
//  HTMLPurifier_AttrDef_CSS_Length.m
//  HTMLPurifier
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

        min = (HTMLPurifier_Length*)([newMin isKindOfClass:[HTMLPurifier_Length class]] ? newMin : (newMin ? [[HTMLPurifier_Length alloc] initWithN:(NSString*)newMin] : nil));
        max = (HTMLPurifier_Length*)([newMax isKindOfClass:[HTMLPurifier_Length class]] ? newMax : (newMax ? [[HTMLPurifier_Length alloc] initWithN:(NSString*)newMax] : nil));
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
    if ([string isEqualTo:@""]) {
        return nil;
    }
    if ([string isEqualTo:@"0"]) {
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

    if (min) {
        NSNumber* c = [length compareTo:min];
        if (!c) {
            return nil;
        }
        if (c.floatValue < 0) {
            return nil;
        }
    }
    if (max) {
        NSNumber* c = [length compareTo:max];
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
