//
//  HTMLPurifier_AttrDef_TextTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 22.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_Text.h"

@interface HTMLPurifier_AttrDef_TextTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_AttrDef_Text* def;
}
@end

@implementation HTMLPurifier_AttrDef_TextTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) assertDef:(NSString*)string expect:(NSObject*)expect
{
    // expect can be a string or bool
    if ([expect isEqual:@YES])
        expect = string;
    
    NSString* result = [def validateWithString:string config:[super config] context:[super context]];
    XCTAssertEqualObjects(expect, result, @"");
}

- (void)testExample
{
    def = [HTMLPurifier_AttrDef_Text new];
    
    [self assertDef:@"This is spiffy text!" expect:@YES];
    [self assertDef:@" Casual\tCDATA parse\ncheck. " expect:@"Casual CDATA parse check."];
}

@end
