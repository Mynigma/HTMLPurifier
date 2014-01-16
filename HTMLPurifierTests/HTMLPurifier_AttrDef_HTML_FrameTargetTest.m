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
    HTMLPurifier_AttrDef_HTML_FrameTarget* def;
    HTMLPurifier_Config* config;
    HTMLPurifier_Context* context;
}
@end

@implementation HTMLPurifier_AttrDef_HTML_FrameTargetTest

- (void)setUp
{
    [super setUp];
    
    
    config = [HTMLPurifier_Config createDefault];
    context = [HTMLPurifier_Context new];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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
    $this->assertDef('', false);
    $this->assertDef('foo', false);
    $this->assertDef('_blank', false);
    $this->assertDef('baz', false);
}

-(void) test
{
    $this->config->set('Attr.AllowedFrameTargets', 'foo,_blank');
    $this->assertDef('', false);
    $this->assertDef('foo');
    $this->assertDef('_blank');
    $this->assertDef('baz', false);
}

@end
