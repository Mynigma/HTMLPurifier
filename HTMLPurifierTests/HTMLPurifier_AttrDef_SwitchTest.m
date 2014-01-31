//
//   HTMLPurifier_AttrDef_SwitchTest.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 22.01.14.


#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_Switch.h"
#import "HTMLPurifier_Token_Start.h"

@interface HTMLPurifier_AttrDef_SwitchTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_AttrDef_Switch* def;
    id withMock;
    id withoutMock;
}
@end

@implementation HTMLPurifier_AttrDef_SwitchTest

- (void)setUp
{
    [super setUp];
    withMock = [OCMockObject mockForClass:[HTMLPurifier_AttrDef class]];
    withoutMock = [OCMockObject mockForClass:[HTMLPurifier_AttrDef class]];
    def = [[HTMLPurifier_AttrDef_Switch alloc] initWithTag:@"tag" withTag:withMock withoutTag:withoutMock];
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

-(void) testWith
{
    HTMLPurifier_Token_Start* token = [[HTMLPurifier_Token_Start alloc] initWithName:@"tag"];
    [[super context] registerWithName:@"CurrentToken" ref:token];
    [[[withMock expect] andReturn:@"foo"] validateWithString:[OCMArg any] config:[OCMArg any] context:[OCMArg any]];
    [self assertDef:@"bar2" expect:@"foo"];
    [withMock verify];
}

-(void) testWithout
{
    HTMLPurifier_Token_Start* token = [[HTMLPurifier_Token_Start alloc] initWithName:@"other-tag"];
    [[super context] registerWithName:@"CurrentToken" ref:token];
    [[[withoutMock expect] andReturn:@"foo"] validateWithString:[OCMArg any] config:[OCMArg any] context:[OCMArg any]];
    [self assertDef:@"bar" expect:@"foo"];
    [withMock verify];
}

@end
