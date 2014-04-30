//
//  HTMLPurifieriOSTests.m
//  HTMLPurifieriOSTests
//
//  Created by Roman Priebe on 03.04.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier.h"

@interface HTMLPurifieriOSTests : XCTestCase

@end

@implementation HTMLPurifieriOSTests

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

- (void)testExample
{
    NSString* testHTML = @"<img src=\"http://www.google.com\" width=\"1\" height=\"1\" border=\"0\" alt=\"\">";

    NSString* cleanedHTML = [HTMLPurifier cleanHTML:testHTML];

    NSLog(@"Output: %@", cleanedHTML);
}

@end
