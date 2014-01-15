//
//  HTMLPurifier_Harness.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_ConfigSchema.h"
#import "HTMLPurifier.h"
#import "BasicPHP.h"


static HTMLPurifier_Config* config;
static HTMLPurifier_Context* context;
static HTMLPurifier* purifier;

@implementation HTMLPurifier_Harness

/**
 * Generates easily accessible default config/context, as well as
 * a convenience purifier for integration testing.
 */

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [config setString:@"Output.Newline" object:@"\n"];
    purifier = [HTMLPurifier new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
}

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


/**
 * Asserts a purification. Good for integration testing.
 */
- (void)assertPurification:(NSString*)input except:(NSObject*)expect
{
    if (!expect)
        expect = input;
    NSObject* result = [purifier purify:input config:config];
    [self assertIdentical:expect to:result];
}


/**
 * Accepts config and context and prepares them into a valid state
 * @param &$config Reference to config variable
 * @param &$context Reference to context variable
 */
- (void)prepareCommon:(HTMLPurifier_Config**)config context:context
{
    *config = [HTMLPurifier_Config createWithConfig:*config schema:nil];
    if (!context)
        context = [HTMLPurifier_Context new];
}

/**
 * Generates default configuration and context objects
 * @return Defaults in form of array($config, $context)
 */
- (void)createCommon
{
    config = [HTMLPurifier_Config createDefault];
    context = [HTMLPurifier_Context new];
}

/**
 * Normalizes a string to Unix (\n) endings
 */
- (void)normalize:(NSMutableString*)string
{
    str_replace(@[@"\r\n", @"\r"], @"\n", string);
}

- (void)assertEqual:(NSObject*)expect to:(NSObject*)result
{
    XCTAssertEqual(expect, result, @"Expected result %@ and got %@", expect, result);
}

- (void)assertIdentical:(NSObject*)expect to:(NSObject*)result
{
    XCTAssertEqual(expect, result, @"Expected result %@ and got %@", expect, result);
}



/**
 * If $expect is false, ignore $result and check if status failed.
 * Otherwise, check if $status if true and $result === $expect.
 * @param $status Boolean status
 * @param $result Mixed result from processing
 * @param $expect Mixed expectation for result
 */
- (void)assertEitherFailOrIdentical:(BOOL)status result:(NSObject*)result expect:(NSObject*)expect
{
    if (![expect isKindOfClass:[NSNumber class]] || [(NSNumber*)expect boolValue] == NO)
    {
        XCTAssertFalse(status, @"Expected false result, got true");
    }
    else
    {
        XCTAssertTrue(status, @"Expected true result, got false");
        XCTAssertEqual(result, expect, @"Expected status %@ to be equal to %@", status?@"YES":@"NO", expect);
    }
}
// vim: et sw=4 sts=4

@end
