//
//   HTMLPurifier_Harness.h
//   HTMLPurifier
//
//  Created by Roman Priebe on 15.01.14.


#import <XCTest/XCTest.h>

#ifndef HTMLPurifier_HTMLPurifier_Harness_h
#define HTMLPurifier_HTMLPurifier_Harness_h

@class HTMLPurifier_Config, HTMLPurifier_Context;

@interface HTMLPurifier_Harness : XCTestCase

- (void)setUp;

- (void)tearDown;

- (void)testExample;

- (id)init;

- (HTMLPurifier_Config*)config;

- (HTMLPurifier_Context*)context;


/**
 * Asserts a purification. Good for integration testing.
 */
- (void)assertPurification:(NSString*)input expect:(NSObject*)expect;

/**
 * Accepts config and context and prepares them into a valid state
 * @param &$config Reference to config variable
 * @param &$context Reference to context variable
 */
- (void)prepareCommon:(HTMLPurifier_Config**)config context:(HTMLPurifier_Context*)context;
/**
 * Generates default configuration and context objects
 * @return Defaults in form of array($config, $context)
 */
- (void)createCommon;

/**
 * Normalizes a string to Unix (\n) endings
 */
- (void)normalize:(NSMutableString*)string;

- (void)assertEqual:(NSObject*)expect to:(NSObject*)result;

- (void)assertIdentical:(NSObject*)expect to:(NSObject*)result;
- (void)assertEitherFailOrIdentical:(BOOL)status result:(NSObject*)result expect:(NSObject*)expect;


@end


#endif
