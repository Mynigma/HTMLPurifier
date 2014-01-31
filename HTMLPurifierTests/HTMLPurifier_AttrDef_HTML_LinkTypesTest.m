//
//   HTMLPurifier_AttrDef_HTML_LinkTypesTest.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 18.01.14.



#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_HTML_LinkTypes.h"

@interface HTMLPurifier_AttrDef_HTML_LinkTypesTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_Config* config;
    HTMLPurifier_Context* context;
    HTMLPurifier_AttrDef_HTML_LinkTypes* def;
}
@end

@implementation HTMLPurifier_AttrDef_HTML_LinkTypesTest

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

- (void)disabled_testNull
{
    def = [[HTMLPurifier_AttrDef_HTML_LinkTypes alloc] initWithName:@"rel"];
    [config setString:@"Attr.AllowedRel" object:@[@"nofollow",@"foo"]];
    
    [self assertDef:@"" expect:nil];
    [self assertDef:@"nofollow" expect:@"nofollow"];
    [self assertDef:@"nofollow foo" expect:@"nofollow foo"];
    [self assertDef:@"nofollow bar" expect:@"nofollow"];
    [self assertDef:@"bar" expect:nil];
}

@end
