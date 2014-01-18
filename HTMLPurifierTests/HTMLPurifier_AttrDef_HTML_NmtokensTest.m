//
//  HTMLPurifier_AttrDef_HTML_NmtokensTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_HTML_Nmtokens.h"

@interface HTMLPurifier_AttrDef_HTML_NmtokensTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_Config* config;
    HTMLPurifier_Context* context;
    HTMLPurifier_AttrDef_HTML_Nmtokens* def;
}
@end

@implementation HTMLPurifier_AttrDef_HTML_NmtokensTest

- (void)setUp
{
    [super setUp];
    config = [HTMLPurifier_Config createDefault];
    context = [HTMLPurifier_Context new];
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

- (void)testDefault
{
    def = [HTMLPurifier_AttrDef_HTML_Nmtokens new];
    
    [self  assertDef:@"valid" expect:@"valid"];
    [self  assertDef:@"a0-_" expect:@"a0-_"];
    [self  assertDef:@"-valid" expect:@"-valid"];
    [self  assertDef:@"_valid" expect:@"_valid"];
    [self  assertDef:@"double valid" expect:@"double valid"];
    
    [self  assertDef:@"0invalid"  expect: nil];
    [self  assertDef:@"-0"  expect: nil];
    
    // test conditional replacement
    [self  assertDef:@"validassoc 0invalid"  expect: @"validassoc"];
    
    // test whitespace leniency
    [self  assertDef:@" double\nvalid\r"  expect:@"double valid"];
    
    // test case sensitivity
    [self  assertDef:@"VALID"  expect: @"VALID"];
}

@end
