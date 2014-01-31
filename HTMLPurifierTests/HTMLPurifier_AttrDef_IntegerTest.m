//
//  HTMLPurifier_AttrDef_IntegerTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 22.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_Integer.h"

@interface HTMLPurifier_AttrDef_IntegerTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_AttrDef_Integer* def;
}
@end

@implementation HTMLPurifier_AttrDef_IntegerTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) assertDef:(NSString*) string expect:(NSObject*)expect
{
    // expect can be a string or bool
    if ([expect isEqual:@YES])
        expect = string;
    
    NSString* result = [def validateWithString:string config:[super config] context:[super context]];
    XCTAssertEqualObjects(expect, result, @"");
}


-(void) test
{
    def = [HTMLPurifier_AttrDef_Integer new];
    
    [self assertDef:@"0" expect:@YES];
    [self assertDef:@"1" expect:@YES];
    [self assertDef:@"-1" expect:@YES];
    [self assertDef:@"-10" expect:@YES];
    [self assertDef:@"14" expect:@YES];
    [self assertDef:@"+24" expect:@"24"];
    [self assertDef:@" 14 " expect:@"14"];
    [self assertDef:@"-0" expect:@"0"];
    
    [self assertDef:@"-1.4" expect:nil];
    [self assertDef:@"3.4" expect:nil];
    [self assertDef:@"asdf" expect:nil]; // must not return zero
    [self assertDef:@"2in" expect:nil]; // must not return zero
    
}

-(void) assertRangeNeg:(NSNumber*)negative zer:(NSNumber*)zero pos:(NSNumber*)positive
{
    [self assertDef:@"-100" expect:negative];
    [self assertDef:@"-1" expect:negative];
    [self assertDef:@"0" expect:zero];
    [self assertDef:@"1" expect:positive];
    [self assertDef:@"42" expect:positive];
}

-(void) testRange
{
    def = [[HTMLPurifier_AttrDef_Integer alloc] initWithNegative:@NO Zero:nil Positive:nil];
    [self assertRangeNeg:nil zer:@YES pos:@YES]; // non-negative
    
    def = [[HTMLPurifier_AttrDef_Integer alloc] initWithNegative:@NO Zero:@NO Positive:nil];
    [self assertRangeNeg:nil zer:nil pos:@YES]; // positive
    
    
    // fringe cases
    
    def = [[HTMLPurifier_AttrDef_Integer alloc] initWithNegative:@NO Zero:@NO Positive:@NO];
    [self assertRangeNeg:nil zer:nil pos:nil]; // allow none
    
     def = [[HTMLPurifier_AttrDef_Integer alloc] initWithNegative:@YES Zero:@NO Positive:@NO];
    [self assertRangeNeg:@YES zer:nil pos:nil]; // negative
    
     def = [[HTMLPurifier_AttrDef_Integer alloc] initWithNegative:@NO Zero:@YES Positive:@NO];
    [self assertRangeNeg:nil zer:@YES pos:nil]; // zero
    
     def = [[HTMLPurifier_AttrDef_Integer alloc] initWithNegative:@YES Zero:@YES Positive:@NO];
    [self assertRangeNeg:@YES zer:@YES pos:nil]; // non-positive
    
}

@end
