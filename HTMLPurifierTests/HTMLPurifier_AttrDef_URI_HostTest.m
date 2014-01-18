//
//  HTMLPurifier_AttrDef_URI_HostTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_URI_Host.h"

@interface HTMLPurifier_AttrDef_URI_HostTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_Config* config;
    HTMLPurifier_Context* context;
    HTMLPurifier_AttrDef_URI_Host* def;
}
@end

@implementation HTMLPurifier_AttrDef_URI_HostTest

- (void)setUp
{
    [super setUp];
    config = [HTMLPurifier_Config createDefault];
    context = [HTMLPurifier_Context new];
    def = [HTMLPurifier_AttrDef_URI_Host new];
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
    [self assertDef:@"[2001:DB8:0:0:8:800:200C:417A]" expect:@"[2001:DB8:0:0:8:800:200C:417A]"]; // IPv6
    [self assertDef:@"124.15.6.89" expect:@"124.15.6.89"]; // IPv4
    [self assertDef:@"www.google.com" expect:@"www.google.com"]; // reg-name
    
    // more domain name tests
    [self assertDef:@"test." expect:@"test."];
    [self assertDef:@"sub.test." expect:@"sub.test."];
    [self assertDef:@".test" expect:nil];
    [self assertDef:@"ff" expect:@"ff"];
    [self assertDef:@"1f" expect:nil];
    [self assertDef:@"-f" expect:nil];
    [self assertDef:@"f1" expect:@"f1"];
    [self assertDef:@"f-" expect:nil];
    [self assertDef:@"sub.ff" expect:@"sub.ff"];
    [self assertDef:@"sub.1f"expect:nil];
    [self assertDef:@"sub.-f" expect: nil];
    [self assertDef:@"sub.f1" expect:@"sub.f1"];
    [self assertDef:@"sub.f-" expect: nil];
    [self assertDef:@"ff.top" expect:@"ff.top"];
    [self assertDef:@"1f.top" expect:@"1f.top"];
    [self assertDef:@"-f.top" expect: nil];
    [self assertDef:@"ff.top"expect:@"ff.top"];
    [self assertDef:@"f1.top"expect:@"f1.top"];
    [self assertDef:@"f1_f2.ex.top" expect: nil];
    [self assertDef:@"f-.top" expect: nil];
    
    [self assertDef:@"\xE4\xB8\xAD\xE6\x96\x87.com.cn" expect:nil];
}

- (void) disabled_testIDNA
{
//    if (!$GLOBALS['HTMLPurifierTest']['Net_IDNA2']) {
//        return false;
//    }
    [config setString:@"Core.EnableIDNA" object:@YES];
    [self assertDef:@"\xE4\xB8\xAD\xE6\x96\x87.com.cn" expect:@"xn--fiq228c.com.cn"];
     [self assertDef:@"\xe2\x80\x85.com" expect:nil]; // rejected
}

- (void) testAllowUnderscore
{
    [config setString:@"Core.AllowHostnameUnderscore" object: @YES];
    [self assertDef:@"foo_bar.example.com" expect:@"foo_bar.example.com"];
    [self assertDef:@"foo_.example.com" expect:nil];
}

@end
