//
//  HTMLPurifier_Length.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Length.h"
#import "BasicPHP.h"


@implementation HTMLPurifier_Length

- (id)initWithN:(NSString*)newN u:(NSString*)newU
{
    self = [super init];
    if (self) {
        allowedUnits = [HTMLPurifier_Length allowedUnits];
        n = newN;
        unit = newU;
    }
    return self;
}

- (id)initWithN:(NSString*)newN
{
    return [self initWithN:newN u:nil];
}

- (id)init
{
    return [self initWithN:nil u:nil];
}

+ (NSDictionary*)allowedUnits
{
    return @{@"em":@YES, @"ex":@YES, @"px":@YES, @"in":@YES, @"cm":@YES, @"mm":@YES, @"pt":@YES, @"pc":@YES};
}

/**
 * @param string $s Unit string, like '2em' or '3.4in'
 * @return HTMLPurifier_Length
 * @warning Does not perform validation.
 */
+ (HTMLPurifier_Length*)makeWithS:(NSObject*)s
{
    if ([s isKindOfClass:[HTMLPurifier_Length class]])
        return  (HTMLPurifier_Length*)s;


    if([s isKindOfClass:[NSString class]])
    {

        NSInteger n_length = php_strspn((NSString*)s, @"1234567890.+-");
        NSString* newN = [(NSString*)s substringWithRange:NSMakeRange(0, n_length)];

        NSString* newUnit = [(NSString*)s substringWithRange:NSMakeRange(0, n_length)];
        if ([newUnit isEqualTo:@""]) {
            newUnit = nil;
        }
        return [[HTMLPurifier_Length alloc] initWithN:newN u:newUnit];
    }

    return nil;
}

/**
 * Validates the number and unit.
 * @return bool
 */
- (BOOL)validate
{
    // Special case:
    if ([n isEqual:@"+0"] || [n isEqual:@"-0"])
    {
        n = @"0";
    }
    if ([n isEqual:@"0"] && unit==nil)
    {
        return YES;
    }
    unit = [unit lowercaseString];

    if (![[HTMLPurifier_Length allowedUnits] objectForKey:unit])
    {
        return NO;
    }
    // Hack:
    HTMLPurifier_AttrDer_CSS_Number* def = [[HTMLPurifier_AttrDef_CSS_Number alloc] init];
    NSString* result = [def validateW:n, false, false];
    if ($result === false) {
        return false;
    }
    n = result;
    return true;
}

/**
 * Returns string representation of number.
 * @return string
 */
- (NSString*)toString
{
    if (![self isValid]) {
        return false;
    }
    return [NSString stringWithFormat:@"%@%@", n, unit];
}

/**
 * Retrieves string numeric magnitude.
 * @return string
 */
-(NSString*)getN
{
    return n;
}

/**
 * Retrieves string unit.
 * @return string
 */
-(NSString*)getUnit
{
    return unit;
}

/**
 * Returns true if this length unit is valid.
 * @return bool
 */
- (BOOL)isValid
{
    if (!self.isValid) {
        isValid = [self validate];
    }
    return self.isValid;
}

/**
 * Compares two lengths, and returns 1 if greater, -1 if less and 0 if equal.
 * @param HTMLPurifier_Length $l
 * @return int
 * @warning If both values are too large or small, this calculation will
 *          not work properly
 */
- (NSNumber*)compareTo:(HTMLPurifier_Length*)l
{
    if (!l) {
        return nil;
    }
    if(l.unit !== self.unit)
    {
        HTMLPurifier_UnitConverter* converter = [HTMLPurifier_UnitConverter new];
        l = [converter convert:$l, $this->unit);
             if(!l)
             {
                 return nil;
             }
             }
             return self.n - l.n;
             }

             @end
