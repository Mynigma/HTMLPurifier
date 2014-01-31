//
//  HTMLPurifier_TokenTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 21.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Token_Start.h"
#import "HTMLPurifier_Token.h"

@interface HTMLPurifier_TokenTest : HTMLPurifier_Harness

@end

@implementation HTMLPurifier_TokenTest

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

-(void) assertTokenConstruction:(NSString*)name attr:(NSDictionary*)attr expect_name:(NSString*)expect_name expect_attr:(NSDictionary*)expect_attr
{
    if (!expect_name) expect_name = name;
    if (!expect_attr) expect_attr = attr;
    
    NSArray* keys = attr.allKeys;
    
    HTMLPurifier_Token* token = [[HTMLPurifier_Token_Start alloc] initWithName:name attr:attr sortedAttrKeys:keys];
    
    XCTAssertEqualObjects(expect_name, [token name]);
    XCTAssertEqualObjects(expect_attr, [token attr]);
}

-(void) testConstruct
{
    // standard case
    [self assertTokenConstruction:@"a" attr:@{@"href" : @"about:blank"} expect_name:nil expect_attr:nil];
    
    // lowercase the tag's name
    [self assertTokenConstruction:@"A" attr:@{@"href" : @"about:blank"} expect_name:@"a" expect_attr:nil];
    
    // lowercase attributes
    [self assertTokenConstruction:@"a"  attr:@{@"HREF" : @"about:blank"} expect_name:@"a"
                      expect_attr:@{@"href" : @"about:blank"}];
    
}


@end
