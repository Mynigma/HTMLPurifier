//
//  Smoketest.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 24.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier.h"
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_Config.h"


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


- (void)testXSSAttacks
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
            XCTAssertNotNil(before, @"%@", key);
            XCTAssertEqualObjects(after, expect, @"%@", key);
        }
        else
            XCTFail(@"Too few items in dictionary for key %@", key);
    }
}

- (void)testEmailSamples
{
    [[super config] setString:@"Output.Newline" object:@""];

    NSURL* configPlistPath = [BUNDLE URLForResource:@"test_Emails" withExtension:@"plist"];
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

            NSData* beforeData = [[NSData alloc] initWithBase64EncodedString:before options:0];

            NSString* beforeString = [[NSString alloc] initWithData:beforeData encoding:NSUTF8StringEncoding];

            NSString* expect = plistDict[key][1];

            NSData* expectData = [[NSData alloc] initWithBase64EncodedString:expect options:0];

            NSString* expectString = [[NSString alloc] initWithData:expectData encoding:NSUTF8StringEncoding];


            XCTAssertNotNil(beforeString, @"%@", key);

            NSString* afterString = [purifier purify:beforeString];

            XCTAssertEqualObjects(afterString, expectString, @"%@", key);
        }
        else
            XCTFail(@"Too few items in dictionary for key %@", key);
    }
}


@end
