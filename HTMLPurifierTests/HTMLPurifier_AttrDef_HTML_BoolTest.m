//
//  HTMLPurifier_AttrDef_HTML_BoolTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 16.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_HTML_Bool.h"

@interface HTMLPurifier_AttrDef_HTML_BoolTest : HTMLPurifier_AttrDefHarness
{

HTMLPurifier_Config* config;
HTMLPurifier_Context* context;
HTMLPurifier_AttrDef_HTML_Bool* def;
}
@end

@implementation HTMLPurifier_AttrDef_HTML_BoolTest

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

- (void) assertDef:(NSString*) string Expect:(NSString*)expect
{
    // $expect can be a string or bool
    NSString* result = [def validateWithString:string config:config context:context];
    
    XCTAssertEqualObjects(expect, result, @"");
    
}

- (void)test
{
    def = [[HTMLPurifier_AttrDef_HTML_Bool  alloc] initWithName:@"foo"];
    
    [self assertDef:@"foo" Expect:@"foo"];
    [self assertDef:@"" Expect:nil];
    [self assertDef:@"bar" Expect:@"foo"];
}

-(void)testMake
{
    HTMLPurifier_AttrDef_HTML_Bool* factory = [HTMLPurifier_AttrDef_HTML_Bool new];
    
    def = [factory makeWithString:@"foo"];

    HTMLPurifier_AttrDef_HTML_Bool* def2 = [[HTMLPurifier_AttrDef_HTML_Bool alloc] initWithName:@"foo"];
    XCTAssertEqualObjects(def.name,def2.name,@"");
}


@end
