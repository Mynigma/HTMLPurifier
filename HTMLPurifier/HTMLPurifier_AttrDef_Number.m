//
//  HTMLPurifier_AttrDef_Number.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_Number.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_Number

- (id)init
{
    return [self initWithNonNegative:NO];
}

- (id)initWithNonNegative:(BOOL)newNonNegative
{
    self = [super init];
    if (self) {
        nonNegative = newNonNegative;
    }
    return self;
}
    /**
     * @param string $number
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return string|bool
     * @warning Some contexts do not pass $config, $context. These
     *          variables should not be used without checking HTMLPurifier_Length
     */
- (NSString*)validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
    {
        string = [self parseCDATAWithString:string];

        if ([string isEqualTo:@""]) {
            return nil;
        }
        if ([string isEqualTo:@"0"]) {
            return @"0";
        }

        NSMutableString* sign = [@"" mutableCopy];
        switch ([string characterAtIndex:0])
        {
            case '-':
                if (self->nonNegative) {
                    return nil;
                }
                sign = [@"-" mutableCopy];
            case '+':
                string = substr(string, 1);
        }

        if (ctype_digit(string)) {
            string = ltrim(string, '0');
            return string ? [sign appendString:string] : @"0";
        }

        // Period is the only non-numeric character allowed
        if (strpos($number, '.') === false) {
            return false;
        }

        list($left, $right) = explode('.', $number, 2);

        if ($left === '' && $right === '') {
            return false;
        }
        if ($left !== '' && !ctype_digit($left)) {
            return false;
        }

        $left = ltrim($left, '0');
        $right = rtrim($right, '0');

        if ($right === '') {
            return $left ? $sign . $left : '0';
        } elseif (!ctype_digit($right)) {
            return false;
        }
        return $sign . $left . '.' . $right;
    }
}

@end
