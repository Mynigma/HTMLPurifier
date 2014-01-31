//
//  HTMLPurifier_AttrTransform_NameSyncTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 25.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrTransformHarness.h"
#import "HTMLPurifier_AttrTransform_NameSync.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_IDAccumulator.h"

@interface HTMLPurifier_AttrTransform_NameSyncTest : HTMLPurifier_AttrTransformHarness
{
    HTMLPurifier_AttrTransform_NameSync* obj;
    HTMLPurifier_IDAccumulator* accumulator;
    HTMLPurifier_Config* config;
}
@end

@implementation HTMLPurifier_AttrTransform_NameSyncTest

- (void)setUp
{
    [super setUp];
    obj = [HTMLPurifier_AttrTransform_NameSync new];
    accumulator = [HTMLPurifier_IDAccumulator new];
    [[super context] registerWithName:@"IDAccumulator" ref:accumulator];
   // Well, we dont want this, but for testing reasons... Implementet a local config, so it should run through
    config = [HTMLPurifier_Config new];
    [config setString:@"Attr.EnableID" object:@YES];
}

- (void)tearDown
{
    [super tearDown];
}

-(void) assertResult:(NSDictionary*)input expect:(NSDictionary*)expect
{
    
    //keyarray
    NSMutableArray* sortedKeys = [input.allKeys mutableCopy];
    
    // call the function
    NSDictionary* result = [obj transform:input sortedKeys:sortedKeys config:config context:[super context]];
    
    XCTAssertEqualObjects(expect, result);
    XCTAssertEqualObjects(expect.allKeys, sortedKeys);
}

/*** Tests ***/

-(void) testEmpty
{
    [self assertResult:@{} expect:@{}];
}

-(void) testAllowSame
{
    [self assertResult:@{@"name":@"free", @"id":@"free"} expect:@{@"name":@"free", @"id":@"free"}];
}

-(void) testAllowDifferent
{
    [self assertResult:@{@"name":@"tryit", @"id":@"thisgood"} expect:@{@"name":@"tryit", @"id":@"thisgood"}];
}

-(void) testCheckName
{
    [accumulator addWithID:@"notok"];
    [self assertResult:@{@"name":@"notok", @"id":@"ok"} expect:@{@"id":@"ok"}];
}

@end
