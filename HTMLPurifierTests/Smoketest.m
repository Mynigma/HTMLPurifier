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
#define BUNDLE (NSClassFromString(@"HTMLPurifierTests")!=nil)?[NSBundle bundleForClass:[NSClassFromString(@"HTMLPurifierTests") class]]:[NSBundle mainBundle]



@interface Smoketest : HTMLPurifier_Harness
{
    HTMLPurifier* purifier;
}

@end

@implementation Smoketest

- (void)setUp
{
    [super setUp];
    purifier = [HTMLPurifier new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testFromPlist
{
    NSURL* configPlistPath = [BUNDLE URLForResource:@"xssSmoketests" withExtension:@"plist"];
    if(!configPlistPath)
    {
        NSLog(@"Error opening config plist file!");
        return;
    }

    NSDictionary* plistDict = [NSDictionary dictionaryWithContentsOfURL:configPlistPath];

    for(NSString* key in plistDict)
    {
        if([plistDict[key] count]>1)
        {
            NSString* before = plistDict[key][0];
            NSString* after = [purifier purify:before];
            NSString* expect = plistDict[key][1];
            XCTAssertEqualObjects(after, expect, @"%@", key);
        }
        else
            XCTFail(@"Too few items in dictionary for key %@", key);
    }
}

@end
