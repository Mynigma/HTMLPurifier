//
//   HTMLPurifier_Length.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.


#import "HTMLPurifier_Length.h"
#import "BasicPHP.h"
#import "HTMLPurifier_AttrDef_CSS_Number.h"
#import "HTMLPurifier_UnitConverter.h"

@implementation HTMLPurifier_Length

- (id)initWithN:(NSString*)newN u:(NSString*)newU
{
    self = [super init];
    if (self) {
        self.allowedUnits = [HTMLPurifier_Length allowedUnits];
        self.n = newN;
        self.unit = newU;
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


- (instancetype)initWithCoder:(NSCoder*)coder
{
    self = [super init];
    if (self) {
        self.allowedUnits = [coder decodeObjectForKey:@"allowedUnits"];
        self.n = [coder decodeObjectForKey:@"n"];
        self.unit = [coder decodeObjectForKey:@"unit"];
        self.valid = [coder decodeObjectForKey:@"valid"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:self.allowedUnits forKey:@"allowedUnits"];
    [encoder encodeObject:self.n forKey:@"n"];
    [encoder encodeObject:self.unit forKey:@"unit"];
    [encoder encodeObject:self.valid forKey:@"valid"];
}


- (BOOL)isEqual:(HTMLPurifier_Length*)other
{
    if (other == self)
        return YES;
      
    if(![other isKindOfClass:[HTMLPurifier_Length class]])
        return NO;

    BOOL allowedUnitsEqual = (!self.allowedUnits && ![(HTMLPurifier_Length*)other allowedUnits]) || [self.allowedUnits isEqual:[(HTMLPurifier_Length*)other allowedUnits]];
    BOOL nEqual = (!self.n && ![(HTMLPurifier_Length*)other n]) || [self.n isEqual:[(HTMLPurifier_Length*)other n]];
    BOOL unitEqual = (!self.unit && ![(HTMLPurifier_Length*)other unit]) || [self.unit isEqual:[(HTMLPurifier_Length*)other unit]];
    BOOL validEqual = (!self.valid && ![(HTMLPurifier_Length*)other valid]) || [self.valid isEqual:[(HTMLPurifier_Length*)other valid]];
    
    return allowedUnitsEqual && nEqual && unitEqual && validEqual;
}

- (NSUInteger)hash
{
    return [_allowedUnits hash] ^ [_n hash] ^ [_unit hash] ^ [_valid hash] ^ [super hash];
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

        NSString* newUnit = [(NSString*)s substringWithRange:NSMakeRange(n_length, [(NSString*)s length] - n_length)];
        if ([newUnit isEqual:@""]) {
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
    if ([_n isEqual:@"+0"] || [_n isEqual:@"-0"])
    {
        _n = @"0";
    }
    if ([_n isEqual:@"0"] && _unit==nil)
    {
        return YES;
    }
    _unit = [_unit lowercaseString];

    if (![[HTMLPurifier_Length allowedUnits] objectForKey:_unit])
    {
        return NO;
    }
    // Hack:
    HTMLPurifier_AttrDef_CSS_Number* def = [[HTMLPurifier_AttrDef_CSS_Number alloc] init];
    NSString* result = [def validateWithString:_n config:nil context:nil];
    if (!result) {
        return NO;
    }
    _n = result;
    return YES;
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
    return [NSString stringWithFormat:@"%@%@", _n, _unit];
}

/**
 * Retrieves string numeric magnitude.
 * @return string
 */
-(NSString*)getN
{
    return _n;
}

/**
 * Retrieves string unit.
 * @return string
 */
-(NSString*)getUnit
{
    return _unit;
}

/**
 * Returns true if this length unit is valid.
 * @return bool
 */
- (BOOL)isValid
{
    if (!_valid.boolValue) {
        _valid = @([self validate]);
    }
    return _valid.boolValue;
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
    if(![[l getUnit] isEqual:self.unit])
    {
        HTMLPurifier_UnitConverter* converter = [HTMLPurifier_UnitConverter new];
        l = [converter convert:l unit:self.unit];
        if(!l)
        {
            return nil;
        }
    }
    return @(_n.floatValue - [l getN].floatValue);
}

@end
