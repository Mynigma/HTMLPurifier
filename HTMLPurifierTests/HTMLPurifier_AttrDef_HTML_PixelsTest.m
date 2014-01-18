//
//  HTMLPurifier_AttrDef_HTML_PixelsTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_HTML_Pixels.h"

@interface HTMLPurifier_AttrDef_HTML_PixelsTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_AttrDef_HTML_Pixels* def;
    HTMLPurifier_Config* config;
    HTMLPurifier_Context* context;
}
@end

@implementation HTMLPurifier_AttrDef_HTML_PixelsTest

- (void)setUp
{
    [super setUp];
    config = [HTMLPurifier_Config createDefault];
    context = [HTMLPurifier_Context new];

    // Put setup code here. This method is called before the invocation of each test method in the class.
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
    def = [HTMLPurifier_AttrDef_HTML_Pixels new];

    [self assertDef:@"1" expect:@"1"];
    [self assertDef:@"0" expect:@"0"];
    
    [self assertDef:@"2px" expect:@"2"]; // rm px suffix
    
    [self assertDef:@"dfs" expect:nil]; // totally invalid value
    
    // conceivably we could repair this value, but we won't for now
    [self assertDef:@"9in" expect:nil];
    
    // test trim
    [self assertDef:@" 45 " expect:@"45"];
    
    // no negatives
    [self assertDef:@"-2" expect:@"0"];
    
    // remove empty
    [self assertDef:@"" expect:nil];
    
    // round down
    [self assertDef:@"4.9" expect:@"4"];
}

- (void)test_make
{
    HTMLPurifier_AttrDef_HTML_Pixels* factory = [HTMLPurifier_AttrDef_HTML_Pixels new];
    def = (HTMLPurifier_AttrDef_HTML_Pixels*)[factory makeWithString:@"30"];
    [self assertDef:@"25" expect:@"25"];
    [self assertDef:@"35" expect:@"30"];
}

@end
