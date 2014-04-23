//
//  UnitConverterTest.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.


#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_Length.h"
#import "HTMLPurifier_UnitConverter.h"


@interface UnitConverterTest : HTMLPurifier_Harness

@end


@implementation UnitConverterTest


- (void)assertConversion:(NSString*)input expect:(NSString*)expect
{
    [self assertConversion:input expect:expect unit:nil testNegative:YES];

}

- (void)assertConversion:(NSString*)input expect:(NSString*)expect unit:(NSString*)unit
{
    [self assertConversion:input expect:expect unit:unit testNegative:YES];
}


- (void)assertConversion:(NSString*)input expect:(NSString*)expect unit:(NSString*)unit testNegative:(BOOL)test_negative
{
    HTMLPurifier_Length* length = [HTMLPurifier_Length makeWithS:input];
    HTMLPurifier_Length* expectl = nil;
    if (expect)
        expectl = [HTMLPurifier_Length makeWithS:expect];
    else
        expectl = nil;

    NSString* to_unit = unit != nil ? unit : [expectl getUnit];

    HTMLPurifier_UnitConverter* converter = [[HTMLPurifier_UnitConverter alloc] initWithOutputPrecision:4 internalPrecision:10];

    NSObject* result = [converter convert:length unit:to_unit];
    if ([result isKindOfClass:[HTMLPurifier_Length class]])
        result = [(HTMLPurifier_Length*)result toString];

    XCTAssertEqualObjects(result, [expectl toString]);

    if (test_negative) {
        [self assertConversion:[NSString stringWithFormat:@"-%@", input] expect:expect==nil ? nil : [NSString stringWithFormat:@"-%@", expect] unit:unit testNegative:NO];
    }
}

- (void)testFail
{
    [self assertConversion:@"1in" expect:nil unit:@"foo"];
    [self assertConversion:@"1foo" expect:nil unit:@"in"];
}

- (void) testZero {
    [self assertConversion:@"0" expect:@"0" unit:@"in" testNegative:NO];
}

- (void)testMore
{
    [self assertConversion:@"-0" expect:@"0" unit:@"in" testNegative:NO];
    [self assertConversion:@"0in" expect:@"0" unit:@"in" testNegative:NO];
    [self assertConversion:@"-0in" expect:@"0" unit:@"in" testNegative:NO];
    [self assertConversion:@"0in" expect:@"0" unit:@"pt" testNegative:NO];
    [self assertConversion:@"-0in" expect:@"0" unit:@"pt" testNegative:NO];
}

- (void) testEnglish {
    [self assertConversion:@"1in" expect:@"6pc"];
    [self assertConversion:@"6pc" expect:@"1in"];

    [self assertConversion:@"1in" expect:@"72pt"];
    [self assertConversion:@"72pt" expect:@"1in"];

    [self assertConversion:@"1pc" expect:@"12pt"];
    [self assertConversion:@"12pt" expect:@"1pc"];

    [self assertConversion:@"1pt" expect:@"0.01389in"];
    [self assertConversion:@"1.000pt" expect:@"0.01389in"];
    [self assertConversion:@"100000pt" expect:@"1389in"];

    [self assertConversion:@"1in" expect:@"96px"];
    [self assertConversion:@"96px" expect:@"1in"];
}

- (void) testMetric {
    [self assertConversion:@"1cm" expect:@"10mm"];
    [self assertConversion:@"10mm" expect:@"1cm"];
    [self assertConversion:@"1mm" expect:@"0.1cm"];
    [self assertConversion:@"100mm" expect:@"10cm"];
}

- (void) testEnglishMetricPtToMm
{
    [self assertConversion:@"2.835pt" expect:@"1mm"];
}

- (void) testEnglishMetricMmToPt
{
    [self assertConversion:@"1mm" expect:@"2.835pt"];
}

- (void) testEnglishMetricInToCm
{
    [self assertConversion:@"0.3937in" expect:@"1cm"];
}

- (void) testRoundingMinPrecision {
    // One sig-fig, modified to be four, conversion rounds up
    [self assertConversion:@"100pt" expect:@"1.389in"];
    [self assertConversion:@"1000pt" expect:@"13.89in"];
    [self assertConversion:@"10000pt" expect:@"138.9in"];
    [self assertConversion:@"100000pt" expect:@"1389in"];
    [self assertConversion:@"1000000pt" expect:@"13890in"];
}

- (void) testRoundingUserPrecision {
    // Five sig-figs, conversion rounds down
    [self assertConversion:@"11112000pt" expect:@"154330in"];
    [self assertConversion:@"1111200pt" expect:@"15433in"];
    [self assertConversion:@"111120pt" expect:@"1543.3in"];
    [self assertConversion:@"11112pt" expect:@"154.33in"];
    [self assertConversion:@"1111.2pt" expect:@"15.433in"];
    [self assertConversion:@"111.12pt" expect:@"1.5433in"];
    [self assertConversion:@"11.112pt" expect:@"0.15433in"];
}


- (void) testRoundingBigNumber {
    [self assertConversion:@"444400000000000000in" expect:@"42660000000000000000px"];
}

- (void) assertSigFig:(NSString*)n sigfigs:(NSInteger)sigfigs
{
    HTMLPurifier_UnitConverter* converter = [HTMLPurifier_UnitConverter new];
    NSInteger result = [converter getSigFigs:n];
    XCTAssertEqual(result, sigfigs);
}

- (void) test_getSigFigs {
    [self assertSigFig:@"0" sigfigs:0];
    [self assertSigFig:@"1" sigfigs:1];
    [self assertSigFig:@"-1" sigfigs:1];
    [self assertSigFig:@"+1" sigfigs:1];
    [self assertSigFig:@"01" sigfigs:1];
    [self assertSigFig:@"001" sigfigs:1];
    [self assertSigFig:@"12" sigfigs:2];
    [self assertSigFig:@"012" sigfigs:2];
    [self assertSigFig:@"10" sigfigs:1];
    [self assertSigFig:@"10." sigfigs:2];
    [self assertSigFig:@"100." sigfigs:3];
    [self assertSigFig:@"103" sigfigs:3];
    [self assertSigFig:@"130" sigfigs:2];
    [self assertSigFig:@".1" sigfigs:1];
    [self assertSigFig:@"0.1" sigfigs:1];
    [self assertSigFig:@"00.1" sigfigs:1];
    [self assertSigFig:@"0.01" sigfigs:1];
    [self assertSigFig:@"0.010" sigfigs:2];
    [self assertSigFig:@"0.012" sigfigs:2];
}



@end
