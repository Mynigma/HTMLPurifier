//
//  HTMLPurifier_AttrDef_HTML_ColorTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 16.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_HTML_Color.h"

@interface HTMLPurifier_AttrDef_HTML_ColorTest : HTMLPurifier_AttrDefHarness
{
HTMLPurifier_Config* config;
HTMLPurifier_Context* context;
HTMLPurifier_AttrDef_HTML_Color* def;
}
@end

@implementation HTMLPurifier_AttrDef_HTML_ColorTest

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

- (void)assertDef:(NSString*) string expect:(NSString*)expect
{
    // $expect can be a string or bool
    NSString* result = [def validateWithString:string config:config context:context];
    
    XCTAssertEqualObjects(expect, result, @"");
    
}

- (void)testColors
{
    def = [HTMLPurifier_AttrDef_HTML_Color  new];

    [self assertDef:@"" expect:nil];
    [self assertDef:@"foo" expect:nil];
    [self assertDef:@"43" expect:nil];
    [self assertDef:@"red" expect:@"#FF0000"];
    [self assertDef:@"RED" expect:@"#FF0000"];
    [self assertDef:@"#FF0000" expect:@"#FF0000"];
    [self assertDef:@"#453443" expect:@"#453443"];
    [self assertDef:@"453443" expect:@"#453443"];
    [self assertDef:@"#345" expect:@"#334455"];
    [self assertDef:@"120" expect:@"#112200"];
}

@end
