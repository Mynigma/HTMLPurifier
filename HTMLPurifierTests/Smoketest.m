//
//  Smoketest.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 24.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier.h"
#import "HTMLPurifier_Harness.h"

@interface Smoketest : HTMLPurifier_Harness

@end

@implementation Smoketest

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

/*
- (void)testFromPlist
{
    NSURL* configPlistPath = [BUNDLE URLForResource:@"config" withExtension:@"plist"];
    if(!configPlistPath)
    {
        NSLog(@"Error opening config plist file!");
        return;
    }

    NSDictionary* configDict = [NSDictionary dictionaryWithContentsOfURL:configPlistPath];
}*/

@end
