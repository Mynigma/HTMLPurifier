//
//  HTMLPurifier_AttrDef_HTML_MultiLengthTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 18.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_HTML_MultiLength.h"

@interface HTMLPurifier_AttrDef_HTML_MultiLengthTest : HTMLPurifier_AttrDefHarness
{
HTMLPurifier_Config* config;
HTMLPurifier_Context* context;
HTMLPurifier_AttrDef_HTML_MultiLength* def;
}
@end

@implementation HTMLPurifier_AttrDef_HTML_MultiLengthTest

- (void)setUp
{
    [super setUp];
    config = [HTMLPurifier_Config createDefault];
    context = [HTMLPurifier_Context new];
    def = [HTMLPurifier_AttrDef_HTML_MultiLength new];
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
    [self assertDef:@"*" expect:@"*"];
    [self assertDef:@"1*" expect:@"*"];
    [self assertDef:@"56*" expect:@"56*"];
    
    [self assertDef:@"**" expect:nil]; // plain old bad
    
    [self assertDef:@"5.4*" expect:@"5*"]; // no decimals
    [self assertDef:@"-3*" expect:nil]; // no negatives
}

@end
