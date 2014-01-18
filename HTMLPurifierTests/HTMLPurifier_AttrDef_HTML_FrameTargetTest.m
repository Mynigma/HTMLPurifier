//
//  HTMLPurifier_AttrDef_HTML_FrameTargetTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 16.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_HTML_FrameTarget.h"

@interface HTMLPurifier_AttrDef_HTML_FrameTargetTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_Config* config;
    HTMLPurifier_Context* context;
    HTMLPurifier_AttrDef_HTML_FrameTarget* def;
}
@end

@implementation HTMLPurifier_AttrDef_HTML_FrameTargetTest

- (void)setUp
{
    [super setUp];
    config = [HTMLPurifier_Config createDefault];
    context = [HTMLPurifier_Context new];
    def = [HTMLPurifier_AttrDef_HTML_FrameTarget new];
}

- (void) assertDef:(NSString*) string expect:(NSString*)expect
{
    // $expect can be a string or bool
    NSString* result = [def validateWithString:string config:config context:context];
    
    XCTAssertEqualObjects(expect, result, @"");
    
}


- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNoneAllowed
{
    [self assertDef:@"" expect: nil];
    [self assertDef:@"foo" expect: nil];
    [self assertDef:@"_blank" expect: nil];
    [self assertDef:@"baz" expect: nil];
}


-(void)test
{
    [config setString:@"Attr.AllowedFrameTargets" object:@[@"foo",@"_blank"]];

    [self assertDef:@"" expect: nil];
    [self assertDef:@"foo" expect: @"foo"];
    [self assertDef:@"_blank" expect: @"_blank"];
    [self assertDef:@"baz" expect: nil];
}

@end
