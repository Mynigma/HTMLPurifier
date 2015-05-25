//
//   HTMLPurifier_AttrDef_Integer.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 13.01.14.



/**
 * Validates an integer.
 * @note While this class was modeled off the CSS definition, no currently
 *       allowed CSS uses this type.  The properties that do are: widows,
 *       orphans, z-index, counter-increment, counter-reset.  Some of the
 *       HTML attributes, however, find use for a non-negative version of this.
 */

#import "HTMLPurifier_AttrDef_Integer.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_Integer

/**
 * Whether or not negative values are allowed.
 * @type bool
 */
@synthesize negative;

/**
 * Whether or not zero is allowed.
 * @type bool
 */
@synthesize zero;

/**
 * Whether or not positive values are allowed.
 * @type bool
 */
@synthesize positive;


-(id) init
{
    self = [super init];
    negative = @YES;
    zero = @YES;
    positive = @YES;
    
    return self;
}

/**
 * @param $negative Bool indicating whether or not negative values are allowed
 * @param $zero Bool indicating whether or not zero is allowed
 * @param $positive Bool indicating whether or not positive values are allowed
 */
-(id) initWithNegative:(NSNumber*)nnegative Zero:(NSNumber*)nzero Positive:(NSNumber*)npositive
{
    
    // If nil set it to @YES
    self = [super init];

    if (nnegative)
        negative = nnegative;
    else
        negative = @YES;
    if (nzero)
        zero = nzero;
    else
        zero = @YES;
    if (npositive)
        positive = npositive;
    else
        positive = @YES;
    
    return self;
}

/**
 * @param string $integer
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString*)integer config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    integer = [super parseCDATAWithString:integer];
    if ([integer isEqual:@""])
    {
        return nil;
    }
    
    // we could possibly simply typecast it to integer, but there are
    // certain fringe cases that must not return an integer.
    
    // clip leading sign
    NSString* digits = nil;
    if (negative.boolValue && ([integer characterAtIndex:0] == '-'))
    {
        digits = substr(integer, 1);
        if ([digits isEqual:@"0"])
        {
            integer = @"0";
        } // rm minus sign for zero
    }
    else if (positive.boolValue && ([integer characterAtIndex:0] == '+'))
    {
        integer = substr(integer, 1); // rm unnecessary plus
        digits = integer;
    }
    else
    {
        digits = integer;
    }
    
    // test if it's numeric
    if (!ctype_digit(digits))
    {
        return nil;
    }
    
    // perform scope tests
    if (!zero.boolValue && ([integer integerValue] == 0))
    {
        return nil;
    }
    if (!positive.boolValue && ([integer integerValue] > 0))
    {
        return nil;
    }
    if (!negative.boolValue && ([integer integerValue] < 0))
    {
        return nil;
    }
    
    return integer;
}

- (id)copyWithZone:(NSZone *)zone
{
    HTMLPurifier_AttrDef_Integer* newAttrDef = [[[self class] allocWithZone:zone] init];

    [newAttrDef setNegative:self.negative];
    [newAttrDef setPositive:self.positive];
    [newAttrDef setZero:self.zero];

    return newAttrDef;
}

@end
