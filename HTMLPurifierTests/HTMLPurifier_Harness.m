//
//  HTMLPurifier_Harness.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier.h"
#import "BasicPHP.h"

@interface HTMLPurifier_Harness : XCTestCase

@end

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
- (void)assertPurification:()input except:()expect
{
    if (!expect)
        expect = input;
    result = [purifier purify:input config:config];
    [self assertIdentical:expect result:result];
}


                           /**
                            * Accepts config and context and prepares them into a valid state
                            * @param &$config Reference to config variable
                            * @param &$context Reference to context variable
                            */
- (void)prepareCommon:(HTMLPurifier_Config**)config context:context
{
    config* = [HTMLPurifier_Config create:config];
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

                           /**
                            * If $expect is false, ignore $result and check if status failed.
                            * Otherwise, check if $status if true and $result === $expect.
                            * @param $status Boolean status
                            * @param $result Mixed result from processing
                            * @param $expect Mixed expectation for result
                            */
- (void)assertEitherFailOrIdentical:(BOOL)status result:(NSObject*)result expect:(NSObject*)expect)
{
    if(
    XCTAssertEqual(status, [expect boolValue], @"Expected status %b to be equal to %@", status, expect);
                        }
                           
                           public function getTests() {
                               // __onlytest makes only one test get triggered
                               foreach (get_class_methods(get_class($this)) as $method) {
                                   if (strtolower(substr($method, 0, 10)) == '__onlytest') {
                                       $this->reporter->paintSkip('All test methods besides ' . $method);
                                       return array($method);
                                   }
                               }
                               return parent::getTests();
                           }
                           
                           }
                           
                           // vim: et sw=4 sts=4

@end
