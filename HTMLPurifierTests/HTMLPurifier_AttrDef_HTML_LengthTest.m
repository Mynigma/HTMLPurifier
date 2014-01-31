//
//   HTMLPurifier_AttrDef_HTML_LengthTest.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 18.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_HTML_Length.h"

@interface HTMLPurifier_AttrDef_HTML_LengthTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_Config* config;
    HTMLPurifier_Context* context;
    HTMLPurifier_AttrDef_HTML_Length* def;
}
@end

@implementation HTMLPurifier_AttrDef_HTML_LengthTest

- (void)setUp
{
    [super setUp];
    config = [HTMLPurifier_Config createDefault];
    context = [HTMLPurifier_Context new];
    def = [HTMLPurifier_AttrDef_HTML_Length new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) assertDef:(NSString*) string expect:(NSString*)expect
{
    // $expect can be a string or bool
    NSString* result = [def validateWithString:string config:config context:context];
    
    XCTAssertEqualObjects(expect, result, @"");
}

- (void)test
{
    
    // percent check
    [self assertDef:@"25%" expect:@"25%"];
    
    // Firefox maintains percent, so will we
    [self assertDef:@"0%" expect:@"0%"];
    
    // 0% <= percent <= 100%
    [self assertDef:@"-15%" expect:@"0%"];
    [self assertDef:@"120%" expect:@"100%"];
    
    // fractional percents, apparently, aren't allowed
    [self assertDef:@"56.5%" expect:@"56%"];
}

@end
