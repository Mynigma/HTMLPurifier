//
//   HTMLPurifier_LinkifyTest.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 20.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.m"
#import "HTMLPurifier_Injector_Linkify.h"
#import "HTMLPurifier_Token_Text.h"

@interface HTMLPurifier_LinkifyTest : HTMLPurifier_Harness
{
    HTMLPurifier_Injector_Linkify* injector;
}

@end

@implementation HTMLPurifier_LinkifyTest

- (HTMLPurifier_Token*)turnIntoToken:(NSString*)string
{
    HTMLPurifier_Token_Text* token = [[HTMLPurifier_Token_Text alloc] initWithData:string];
    return token;
}



- (void)setUp {
    [super createCommon];
    [super setUp];
    [super.config setString:@"AutoFormat.Linkify" object:@YES];
    injector = [HTMLPurifier_Injector_Linkify new];
}

- (void)tearDown {
    [super tearDown];
}




- (void)testLinkifyURLInRootNode
{
    NSString* before = @"http://forum.golem.de/read.php?93325,4185103,4185150#msg-4185150";
    HTMLPurifier_Token* token = [self turnIntoToken:before];
    [injector handleText:&token];
    // TODO: turn token into string
    // NSString* after = token.toNode;
    XCTAssertEqualObjects(after,@"<a href=\"http://forum.golem.de/read.php?93325,4185103,4185150#msg-4185150\">http://forum.golem.de/read.php?93325,4185103,4185150#msg-4185150</a>");
}

//- (void)testLinkifyURLWithComma
//{
//    NSString* before = @"http://example.com";
//    NSString* after = [injector handleText:before];
//    XCTAssertEqualObjects(after,@"<a href=\"http://example.com\">http://example.com</a>");
//}

/*
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
