//
//  HTMLPurifier_LinkifyTest.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 20.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.m"

@interface HTMLPurifier_LinkifyTest : HTMLPurifier_Harness

@end

@implementation HTMLPurifier_LinkifyTest

- (void)setUp
{
    [super createCommon];
    [super setUp];
    [super.config setString:@"AutoFormat.Linkify" object:@YES];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


/*

- (void)testLinkifyURLInRootNode
{
    NSString* before = @"http://example.com";
    NSString* after = self
    XCTAssertEqualObjects(',
                        '<a href="http://example.com">http://example.com</a>'
                        );
}

function testLinkifyURLInInlineNode() {
    $this->assertResult(
                        '<b>http://example.com</b>',
                        '<b><a href="http://example.com">http://example.com</a></b>'
                        );
}

function testBasicUsageCase() {
    $this->assertResult(
                        'This URL http://example.com is what you need',
                        'This URL <a href="http://example.com">http://example.com</a> is what you need'
                        );
}

function testIgnoreURLInATag() {
    $this->assertResult(
                        '<a>http://example.com/</a>'
                        );
}

function testNeeded() {
    $this->config->set('HTML.Allowed', 'b');
    $this->expectError('Cannot enable Linkify injector because a is not allowed');
    $this->assertResult('http://example.com/');
}

function testExcludes() {
    $this->assertResult('<a><span>http://example.com</span></a>');
}

*/


@end
