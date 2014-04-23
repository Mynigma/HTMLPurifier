//
//   HTMLPurifier_AttrDef_HTML_ClassTest.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 18.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_HTML_Class.h"

@interface HTMLPurifier_AttrDef_HTML_ClassTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_Config* config;
    HTMLPurifier_Context* context;
    HTMLPurifier_AttrDef_HTML_Class* def;
}

@end

@implementation HTMLPurifier_AttrDef_HTML_ClassTest

- (void)setUp
{
    [super setUp];
    config = [HTMLPurifier_Config createDefault];
    context = [HTMLPurifier_Context new];
    def = [HTMLPurifier_AttrDef_HTML_Class new];
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

- (void) disabled_testAllowedClasses
{
    [config setString:@"Attr.AllowedClasses" object:@[@"foo"]];
    [self assertDef:@"foo" expect:@"foo"];
    [self assertDef:@"bar" expect:nil];
    [self assertDef:@"foo bar" expect:@"foo"];
}

- (void) disabled_testForbiddenClasses
{
    [config setString:@"Attr.ForbiddenClasses" object:@[@"bar"]];
    [self assertDef:@"foo" expect:@"foo"];
    [self assertDef:@"bar" expect:nil];
    [self assertDef:@"foo bar" expect:@"foo"];
}

- (void) testDefault
{
    [self assertDef:@"valid" expect:@"valid"];
    [self assertDef:@"a0-_" expect:@"a0-_"];
    [self assertDef:@"-valid" expect:@"-valid"];
    [self assertDef:@"_valid" expect:@"_valid"];
    [self assertDef:@"double valid" expect:@"double valid"];
    
    [self assertDef:@"0stillvalid" expect:@"0stillvalid"];
    [self assertDef:@"-0" expect:@"-0"];
    
    // test conditional replacement
    [self assertDef:@"validassoc 0valid" expect:@"validassoc 0valid"];
    
    // test whitespace leniency
    [self assertDef:@" double\nvalid\r" expect:@"double valid"];
    
    // test case sensitivity
    [self assertDef:@"VALID"  expect:@"VALID"];
    
    // test duplicate removal
    [self assertDef:@"valid valid" expect:@"valid"];
}

- (void) disabled_testXHTML11Behavior
{
    [config setString:@"HTML.Doctype" object:@"XHTML 1.1"];
    [self assertDef:@"0invalid"  expect:nil];
    [self assertDef:@"valid valid" expect:@"valid"];
}

@end
