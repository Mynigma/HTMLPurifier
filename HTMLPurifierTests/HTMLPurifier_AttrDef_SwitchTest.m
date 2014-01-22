//
//  HTMLPurifier_AttrDef_SwitchTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 22.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_Switch.h"
#import "HTMLPurifier_Token_Start.h"

@interface HTMLPurifier_AttrDef_SwitchTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_AttrDef_Switch* def;
    HTMLPurifier_AttrDefMock* with;
    HTMLPurifier_AttrDefMock* without;
}
@end

@implementation HTMLPurifier_AttrDef_SwitchTest

- (void)setUp
{
    [super setUp];
    generate_mock_once(@"HTMLPurifier_AttrDef");
    with = [HTMLPurifier_AttrDefMock new];
    without = [HTMLPurifier_AttrDefMock new];
    def = [[HTMLPurifier_AttrDef_Switch alloc] initWithTag:@"tag" withTag:with withoutTag:without];
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
    [with expectOnce:@"validate"];
    [with setReturnValue:('validate', 'foo');
    [self assertDef@"bar2" expect:@"foo"];
}

-(void) testWithout
{
    HTMLPurifier_Token_Start* token = [[HTMLPurifier_Token_Start alloc] initWithName:@"other-tag"];
    [[super context] registerWithName:@"CurrentToken" ref:token];
    [without expectOnce:@"validate"];
    [without setReturnValue:('validate', 'foo');
    [self assertDef@"bar" expect:@"foo"];
}

@end
