//
//   HTMLPurifier_AttrDef_CSS_AlphaValue.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.


#import "HTMLPurifier_AttrDef_CSS_AlphaValue.h"

@implementation HTMLPurifier_AttrDef_CSS_AlphaValue

- (id)init
{
    self = [super initWithNonNegative:@NO]; // opacity is non-negative, but we will clamp it

    if (self) {

    }
    return self;
}


- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    
    if (![super isEqual:other])
        return NO;
    
    if(![other isKindOfClass:[HTMLPurifier_AttrDef_CSS_AlphaValue class]])
        return NO;
    
    return YES;
}


/**
     * @param string $number
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return string
     */
- (NSString*)validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
    {
        NSString* result = [super validateWithString:string config:config context:context];
        if (!result) {
            return nil;
        }
        float floatResult  = result.floatValue;
        if (floatResult < 0.0) {
            result = @"0";
        }
        if (floatResult > 1.0) {
            result = @"1";
        }
        return result;
    }


@end
