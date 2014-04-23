//
//  Smoketest.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 24.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier.h"
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_Config.h"


#define BUNDLE (NSClassFromString(@"HTMLPurifierTests")!=nil)?[NSBundle bundleForClass:[NSClassFromString(@"HTMLPurifierTests") class]]:[NSBundle bundleForClass:[NSClassFromString(@"HTMLPurifier") class]]



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

//- (void)testExample
//{
//
//    NSString* before = @"<IMG SRC=java";
//    NSLog(@"%@", [before dataUsingEncoding:NSUTF8StringEncoding]);
//    NSString* after = [purifier purify:before];
//    NSString* expect = @"";
//    XCTAssertEqualObjects(after, expect, @"Example");
//}
//
//- (void)testBla
//{
//    NSString* before = @"&apos;&apos;;!--&quot;&lt;XSS&gt;=&amp;{()}";
//    NSLog(@"%@", [before dataUsingEncoding:NSUTF8StringEncoding]);
//    NSString* after = [purifier purify:before];
//    NSString* expect = @"&amp;lt;XSS&gt;=&amp;{()}";
//    XCTAssertEqualObjects(after, expect, @"Example");
//}


- (void)d_testIt
{
    NSString* key = @"STYLEw/Comment";
    
    [self.config setString:@"URI.HostBlacklist" object:@[@"google.com"]];

    NSData* beforeData = [[NSData alloc] initWithBase64EncodedString:@"PElNRyBTUkM9YGphdmFzY3JpcHQ6YWxlcnQoIlJTbmFrZSBzYXlzLCAnWFNTJyIpYD4=" options:0];

    NSString* before = [[NSString alloc] initWithData:beforeData encoding:NSUTF8StringEncoding];

    NSString* after = [purifier purify:before config:self.config];

    NSData* expectData = [[NSData alloc] initWithBase64EncodedString:@"PGltZyBzcmM9IiU2MGphdmFzY3JpcHQlM0FhbGVydCgiIGFsdD0iYGphdmFzY3JpcHQ6YWxlcnQoJnF1b3Q7UlNuYWtlIiAvPg==" options:0];

    NSString* expect = [[NSString alloc] initWithData:expectData encoding:NSUTF8StringEncoding];

    XCTAssertNotNil(before, @"%@", key);

    XCTAssertEqualObjects(after, expect, @"%@", key);
    
}


- (void)d_testXSSAttacks
{
    NSURL* smoketestsPlistPath = [BUNDLE URLForResource:@"xssAttacks" withExtension:@"plist"];
    if(!smoketestsPlistPath)
    {
        //NSLOG"Error opening config plist file!");
        return;
    }

    [self.config setString:@"URI.HostBlacklist" object:@[@"google.com"]];

    NSDictionary* plistDict = [NSDictionary dictionaryWithContentsOfURL:smoketestsPlistPath];

    for(NSString* key in plistDict)
    {
        if([plistDict[key] count]>1)
        {
            NSData* beforeBase64Data = plistDict[key][0];

            NSData* beforeData = [[NSData alloc] initWithBase64EncodedData:beforeBase64Data options:0];

            NSString* before = [[NSString alloc] initWithData:beforeData encoding:NSUTF8StringEncoding];

            NSString* after = [purifier purify:before config:self.config];

            NSData* expectBase64Data = plistDict[key][1];

            NSData* expectData = [[NSData alloc] initWithBase64EncodedData:expectBase64Data options:0];

            NSString* expect = [[NSString alloc] initWithData:expectData encoding:NSUTF8StringEncoding];

            XCTAssertNotNil(before, @"%@", key);

            XCTAssertEqualObjects(after, expect, @"%@", key);
        }
        else
            XCTFail(@"Too few items in dictionary for key %@", key);
    }
}

- (void)d_testEmailSamples
{
    [[super config] setString:@"Output.Newline" object:@""];

    NSURL* configPlistPath = [BUNDLE URLForResource:@"test_Emails" withExtension:@"plist"];
    if(!configPlistPath)
    {
        //NSLOG"Error opening config plist file!");
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
