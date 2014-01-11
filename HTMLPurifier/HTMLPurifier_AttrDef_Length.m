//
//  HTMLPurifier_AttrDef_Length.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_Length.h"
#import "HTMLPurifier_Length.h"

@implementation HTMLPurifier_AttrDef_Length

    /**
     * @param HTMLPurifier_Length|string $min Minimum length, or null for no bound. String is also acceptable.
     * @param HTMLPurifier_Length|string $max Maximum length, or null for no bound. String is also acceptable.
     */

- (id)initWithMin:(HTMLPurifier_Length*)newMin max:(HTMLPurifier_Length*)newMax
{
    self = [super init];
    if (self) {

        min = newMin ? [HTMLPurifier_Length makeWithMin:newMin] : nil;
        max = newMax ? [HTMLPurifier_Length makeWithMax:newMax] : nil;
    }
    }
    return self;
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

        HTMLPurifier_Length* length = [HTMLPurifier_Length makeWithString:string];
        if (![length isValid])
        {
            return nil;
        }

        if (min) {
            c = [length compareTo:($this->min)];
            if ($c === false) {
                return false;
            }
            if ($c < 0) {
                return false;
            }
        }
        if ($this->max) {
            $c = $length->compareTo($this->max);
            if ($c === false) {
                return false;
            }
            if ($c > 0) {
                return false;
            }
        }
        return $length->toString();
    }
}

@end
