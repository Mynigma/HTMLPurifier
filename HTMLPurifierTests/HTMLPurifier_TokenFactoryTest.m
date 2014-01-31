//
//  HTMLPurifier_TokenFactoryTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 21.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_TokenFactory.h"
#import "HTMLPurifier_Token.h"
#import "HTMLPurifier_Token_Start.h"

@interface HTMLPurifier_TokenFactoryTest : HTMLPurifier_Harness

@end

@implementation HTMLPurifier_TokenFactoryTest

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

- (void)test
{
    HTMLPurifier_TokenFactory* factory = [HTMLPurifier_TokenFactory new];
    
    HTMLPurifier_Token_Start* regular = [[HTMLPurifier_Token_Start alloc] initWithName:@"a" attr:@{@"href" : @"about:blank"} sortedAttrKeys:@[@"href"]];
    HTMLPurifier_Token_Start* generated = [factory createStartWithName:@"a" attr:@{@"href" : @"about:blank"}.mutableCopy sortedAttrKeys:@[@"href"]];
    
    XCTAssertEqualObjects(regular, generated);
}

@end
