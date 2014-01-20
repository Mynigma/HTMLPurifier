//
//  HTMLPurifier_InjectorHarness.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 20.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import "HTMLPurifier_StrategyHarness.m"
#import "HTMLPurifier_Strategy_MakeWellFormed.h"
#import "HTMLPurifier_Harness.h"

@interface HTMLPurifier_InjectorHarness : HTMLPurifier_Harness

@end

@implementation HTMLPurifier_InjectorHarness

- (void)setUp
{
    [super setUp];
    //self->obj = [HTMLPurifier_Strategy_MakeWellFormed new];
// Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
