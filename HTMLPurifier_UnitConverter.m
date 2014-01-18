//
//  HTMLPurifier_UnitConverter.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_UnitConverter.h"
#import "HTMLPurifier_Length.h"
#import "BasicPHP.h"

#define ENGLISH @1
#define METRIC @2
#define DIGITAL @3


/**
 * Units information array. Units are grouped into measuring systems
 * (English, Metric), and are assigned an integer representing
 * the conversion factor between that unit and the smallest unit in
 * the system. Numeric indexes are actually magical constants that
 * encode conversion data from one system to the next, with a O(n^2)
 * constraint on memory (this is generally not a problem, since
 * the number of measuring systems is small.)
 */
#define units @{ENGLISH:@{@"px":@"3",@"pt":@"4",@"pc":@"48",@"in":@"288",METRIC:@[@"pt",@"0.352777778",@"mm"]},METRIC:@{@"mm":@"1",@"cm":@"10",ENGLISH:@[@"mm",@"2.83464567",@"pt"]}}

/**
 * Class for converting between different unit-lengths as specified by
 * CSS.
 */
@implementation HTMLPurifier_UnitConverter

- (id)init
{
    return [self initWithOutputPrecision:4 internalPrecision:10];
}

- (id)initWithOutputPrecision:(NSInteger)output_precision internalPrecision:(NSInteger)internal_precision
{
    self = [super init];
    if (self) {
        outputPrecision = output_precision;
        internalPrecision = internal_precision;
    }
    return self;
}


    /**
     * Converts a length object of one unit into another unit.
     * @param HTMLPurifier_Length $length
     *      Instance of HTMLPurifier_Length to convert. You must validate()
     *      it before passing it here!
     * @param string $to_unit
     *      Unit to convert to.
     * @return HTMLPurifier_Length|bool
     * @note
     *      About precision: This conversion function pays very special
     *      attention to the incoming precision of values and attempts
     *      to maintain a number of significant figure. Results are
     *      fairly accurate up to nine digits. Some caveats:
     *          - If a number is zero-padded as a result of this significant
     *            figure tracking, the zeroes will be eliminated.
     *          - If a number contains less than four sigfigs ($outputPrecision)
     *            and this causes some decimals to be excluded, those
     *            decimals will be added on.
     */
- (HTMLPurifier_Length*)convert:(HTMLPurifier_Length*)length unit:(NSString*)to_unit
    {
        if (![length isValid])
        {
            return false;
        }

        NSString* n = [length getN];
        NSString* unit = [length getUnit];

        if ([n isEqualToString:@"0"] || !unit) {
            return [[HTMLPurifier_Length alloc] initWithN:@"0" u:nil];
        }

        NSNumber* state = nil;
        NSNumber* dest_state = nil;
        for(NSNumber* k in units.allKeys)
        {
            NSDictionary* x = units[k];
            if (x[unit])
            {
                state = k;
            }
            if (x[to_unit])
            {
                dest_state = k;
            }
        }
        if(!state || !dest_state)
        {
            return nil;
        }

        // Some calculations about the initial precision of the number;
        // this will be useful when we need to do final rounding.
        NSInteger sigfigs = [self getSigFigs:n];
        if (sigfigs < outputPrecision)
        {
            sigfigs = outputPrecision;
        }

        // BCMath's internal precision deals only with decimals. Use
        // our default if the initial number has no decimals, or increase
        // it by how ever many decimals, thus, the number of guard digits
        // will always be greater than or equal to internalPrecision.

        NSString* dest_unit = nil;

        NSInteger log = (NSInteger)floor(log10f(fabs(n.doubleValue)));
        NSInteger cp = (log < 0) ? internalPrecision - log : internalPrecision; // internal precision

        for (NSInteger i = 0; i < 2; i++) {

            // Determine what unit IN THIS SYSTEM we need to convert to
            if ([dest_state isEqual:state]) {
                // Simple conversion
                dest_unit = to_unit;
            }
            else
            {
                // Convert to the smallest unit, pending a system shift
                dest_unit = units[state][dest_state][0];
            }

            // Do the conversion if necessary
            if (![dest_unit isEqual:unit])
            {
                NSString* unit1 = units[state][unit];
                NSString* unit2 = units[state][dest_unit];
                NSString* factor = [self div:unit1 byString:unit2 scale: cp];
                n = [self mul:n with:factor scale:cp];
                unit = dest_unit;
            }

            // Output was zero, so bail out early. Shouldn't ever happen.
            if ([n isEqualToString:@""])
                {
                n = @"0";
                unit = to_unit;
                break;
            }

            // It was a simple conversion, so bail out
            if ([dest_state isEqual:state])
                {
                break;
            }

            if (i != 0) {
                // Conversion failed! Apparently, the system we forwarded
                // to didn't have this unit. This should never happen!
                return nil;
            }

            // Pre-condition: $i == 0

            // Perform conversion to next system of units
            n = [self mul:n with:units[state][dest_state][1] scale:cp];
            unit = units[state][dest_state][2];
            state = dest_state;

            // One more loop around to convert the unit in the new system.

        }

        // Post-condition: $unit == $to_unit
        if (![unit isEqual:to_unit])
                {
            return nil;
        }

        // Useful for debugging:
        //echo "<pre>n";
        //echo "$n\nsigfigs = $sigfigs\nnew_log = $new_log\nlog = $log\nrp = $rp\n</pre>\n";

        n = [self round:n sigfigs:sigfigs];
        if ([n rangeOfString:@"."].location != NSNotFound)
        {
            n = rtrim_2(n, @"0");
        }
        n = rtrim_2(n, @".");

        return [[HTMLPurifier_Length alloc] initWithN:n u:unit];
    }

    /**
     * Returns the number of significant figures in a string number.
     * @param string $n Decimal number
     * @return int number of sigfigs
     */
- (NSInteger)getSigFigs:(NSString*)n
    {
        n = ltrim_2(n, @"0+-");
        NSInteger sigfigs = 0;
        NSInteger dp = strpos(n, @"."); // decimal position
        if (dp == NSNotFound) {
            sigfigs = [rtrim_2(n, @"0") length];
        } else {
            sigfigs = [ltrim_2(n, @"0.") length]; // eliminate extra decimal character
            if (dp != 0) {
                sigfigs--;
            }
        }
        return sigfigs;
    }

    /**
     * Adds two numbers, using arbitrary precision when available.
     * @param string $s1
     * @param string $s2
     * @param int $scale
     * @return string
     */
- (NSString*)add:(NSString*)s1 to:(NSString*)s2 scale:(NSInteger)scale
    {
        return [self scale:(s1.floatValue + s2.floatValue) toScale:scale];
    }

    /**
     * Multiples two numbers, using arbitrary precision when available.
     * @param string $s1
     * @param string $s2
     * @param int $scale
     * @return string
     */
- (NSString*)mul:(NSString*)s1 with:(NSString*)s2 scale:(NSInteger)scale
    {
        return [self scale:(s1.floatValue * s2.floatValue) toScale:scale];
    }

    /**
     * Divides two numbers, using arbitrary precision when available.
     * @param string $s1
     * @param string $s2
     * @param int $scale
     * @return string
     */
- (NSString*)div:(NSString*)s1 byString:(NSString*)s2 scale:(NSInteger)scale
    {
        if(s2.floatValue)
            return [self scale:(s1.floatValue / s2.floatValue) toScale:scale];
        return @"0";
    }

    /**
     * Rounds a number according to the number of sigfigs it should have,
     * using arbitrary precision when available.
     * @param float $n
     * @param int $sigfigs
     * @return string
     */
- (NSString*)round:(NSString*)n sigfigs:(NSInteger)sigfigs
    {
        NSInteger new_log = (NSInteger)floor(log10f(fabs(n.floatValue))); // Number of digits left of decimal - 1
        NSInteger rp = sigfigs - new_log - 1; // Number of decimal places needed
        long double powerOf10 = pow(10, rp);
        return [self scale:round(n.doubleValue*powerOf10)/powerOf10 toScale:rp + 1];
    }

    /**
     * Scales a float to $scale digits right of decimal point, like BCMath.
     * @param float $r
     * @param int $scale
     * @return string
     */
- (NSString*)scale:(double)r toScale:(NSInteger)scale
    {
        NSString* formatString = [NSString stringWithFormat:@"%%.%ldf", (long)scale];
        return [NSString stringWithFormat:formatString, r];
    }


@end
