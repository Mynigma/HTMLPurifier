//
//   HTMLPurifier_AttrDef_URI_IPv6Test.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 18.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_URI_IPv6.h"

@interface HTMLPurifier_AttrDef_URI_IPv6Test : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_Config* config;
    HTMLPurifier_Context* context;
    HTMLPurifier_AttrDef_URI_IPv6* def;
}

@end


@implementation HTMLPurifier_AttrDef_URI_IPv6Test

- (void)setUp
{
    [super setUp];
    config = [HTMLPurifier_Config createDefault];
    context = [HTMLPurifier_Context new];
    def = [HTMLPurifier_AttrDef_URI_IPv6 new];
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
    [self assertDef:@"2001:DB8:0:0:8:800:200C:417A" expect:@"2001:DB8:0:0:8:800:200C:417A"]; // unicast, full
    [self assertDef:@"FF01:0:0:0:0:0:0:101" expect:@"FF01:0:0:0:0:0:0:101"]; // multicast, full
    [self assertDef:@"0:0:0:0:0:0:0:1" expect:@"0:0:0:0:0:0:0:1"]; // loopback, full
    [self assertDef:@"0:0:0:0:0:0:0:0" expect:@"0:0:0:0:0:0:0:0"]; // unspecified, full
    [self assertDef:@"2001:DB8::8:800:200C:417A" expect:@"2001:DB8::8:800:200C:417A"]; // unicast, compressed
    [self assertDef:@"FF01::101" expect:@"FF01::101"]; // multicast, compressed
    
    [self assertDef:@"::1" expect:@"::1"]; // loopback, compressed, non-routable
    [self assertDef:@"::" expect:@"::"]; // unspecified, compressed, non-routable
    [self assertDef:@"0:0:0:0:0:0:13.1.68.3" expect:@"0:0:0:0:0:0:13.1.68.3"]; // IPv4-compatible IPv6 address, full, deprecated
    [self assertDef:@"0:0:0:0:0:FFFF:129.144.52.38" expect:@"0:0:0:0:0:FFFF:129.144.52.38"]; // IPv4-mapped IPv6 address, full
    [self assertDef:@"::13.1.68.3" expect:@"::13.1.68.3"]; // IPv4-compatible IPv6 address, compressed, deprecated
    [self assertDef:@"::FFFF:129.144.52.38" expect:@"::FFFF:129.144.52.38"]; // IPv4-mapped IPv6 address, compressed
    [self assertDef:@"2001:0DB8:0000:CD30:0000:0000:0000:0000/60" expect:@"2001:0DB8:0000:CD30:0000:0000:0000:0000/60"]; // full, with prefix
    [self assertDef:@"2001:0DB8::CD30:0:0:0:0/60" expect:@"2001:0DB8::CD30:0:0:0:0/60"]; // compressed, with prefix
    [self assertDef:@"2001:0DB8:0:CD30::/60" expect:@"2001:0DB8:0:CD30::/60"]; // compressed, with prefix #2
    [self assertDef:@"::/128" expect:@"::/128"]; // compressed, unspecified address type, non-routable
    [self assertDef:@"::1/128" expect:@"::1/128"]; // compressed, loopback address type, non-routable
    [self assertDef:@"FF00::/8" expect:@"FF00::/8"]; // compressed, multicast address type
    [self assertDef:@"FE80::/10" expect:@"FE80::/10"]; // compressed, link-local unicast, non-routable
    [self assertDef:@"FEC0::/10" expect:@"FEC0::/10"]; // compressed, site-local unicast, deprecated
    
    [self assertDef:@"2001:DB8:0:0:8:800:200C:417A:221" expect:nil]; // unicast, full
    [self assertDef:@"FF01::101::2" expect:nil]; //multicast, compressed
    [self assertDef:@"" expect:nil]; // nothing
}

@end
