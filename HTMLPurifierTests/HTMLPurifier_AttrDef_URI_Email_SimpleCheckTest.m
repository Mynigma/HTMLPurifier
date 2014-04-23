//
//   HTMLPurifier_AttrDef_URI_Email_SimpleCheckTest.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 18.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_URI_Email_SimpleCheck.h"

@interface HTMLPurifier_AttrDef_URI_Email_SimpleCheckTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_Config* config;
    HTMLPurifier_Context* context;
    HTMLPurifier_AttrDef_URI_Email_SimpleCheck* def;
}
@end

@implementation HTMLPurifier_AttrDef_URI_Email_SimpleCheckTest

- (void)setUp
{
    [super setUp];
    config = [HTMLPurifier_Config createDefault];
    context = [HTMLPurifier_Context new];
    def = [HTMLPurifier_AttrDef_URI_Email_SimpleCheck  new];
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

- (void)testCore
{
        [self assertDef:@"bob@example.com" expect:@"bob@example.com"];
        [self assertDef:@"  bob@example.com  " expect:@"bob@example.com"];
        [self assertDef:@"bob.thebuilder@example.net" expect:@"bob.thebuilder@example.net"];
        [self assertDef:@"Bob_the_Builder-the-2nd@example.org" expect:@"Bob_the_Builder-the-2nd@example.org"];
        [self assertDef:@"Bob%20the%20Builder@white-space.test" expect:@"Bob%20the%20Builder@white-space.test"];
        
        // extended format, with real name
        //[self assertDef:@"Bob%20Builder%20%3Cbobby.bob.bob@it.is.example.com%3E');
        //[self assertDef:@"Bob Builder <bobby.bob.bob@it.is.example.com>');
        
        // time to fail
        [self assertDef:@"bob" expect:nil];
        [self assertDef:@"bob@home@work" expect:nil];
        [self assertDef:@"@example.com" expect:nil];
        [self assertDef:@"bob@" expect:nil];
        [self assertDef:@"" expect:nil];
        
}

@end
