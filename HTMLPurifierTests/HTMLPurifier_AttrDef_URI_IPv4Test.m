//
//   HTMLPurifier_AttrDef_URI_IPv4Test.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 18.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_URI_IPv4.h"

@interface HTMLPurifier_AttrDef_URI_IPv4Test : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_Config* config;
    HTMLPurifier_Context* context;
    HTMLPurifier_AttrDef_URI_IPv4* def;
}
@end

@implementation HTMLPurifier_AttrDef_URI_IPv4Test

- (void)setUp
{
    [super setUp];
    config = [HTMLPurifier_Config createDefault];
    context = [HTMLPurifier_Context new];
    def = [HTMLPurifier_AttrDef_URI_IPv4 new];
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
    [self assertDef:@"127.0.0.1" expect:@"127.0.0.1"]; // standard IPv4, loopback, non-routable
    [self assertDef:@"0.0.0.0" expect:@"0.0.0.0"]; // standard IPv4, unspecified, non-routable
    [self assertDef:@"255.255.255.255" expect:@"255.255.255.255"]; // standard IPv4
    
    [self assertDef:@"300.0.0.0" expect:nil]; // standard IPv4, out of range
    [self assertDef:@"124.15.6.89/60" expect:nil]; // standard IPv4, prefix not allowed
    
    [self assertDef:@"" expect:nil]; // nothing
}

@end
