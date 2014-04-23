//
//   HTMLPurifier_AttrTransform_BdoDirTest.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 25.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrTransformHarness.h"
#import "HTMLPurifier_AttrTransform_BdoDir.h"
#import "HTMLPurifier_Config.h"

@interface HTMLPurifier_AttrTransform_BdoDirTest : HTMLPurifier_AttrTransformHarness
{
    HTMLPurifier_AttrTransform_BdoDir* obj;
}
@end

@implementation HTMLPurifier_AttrTransform_BdoDirTest

- (void)setUp
{
    [super setUp];
    obj = [HTMLPurifier_AttrTransform_BdoDir new];
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
    NSDictionary* result = [obj transform:input sortedKeys:sortedKeys config:[super config] context:[super context]];
    
    XCTAssertEqualObjects(expect, result);
    XCTAssertEqualObjects(expect.allKeys, sortedKeys);
}

/*** Tests ***/

-(void) testAddDefaultDir
{
    [self assertResult:@{} expect:@{@"dir":@"ltr"}];
}

-(void) testPreserveExistingDir
{
    [self assertResult:@{@"dir":@"rtl"} expect:@{@"dir":@"rtl"}];
}

-(void) disabled_testAlternateDefault
{
    [[super config] setString:@"Attr.DefaultTextDir" object:@"rtl"];
    [self assertResult:@{} expect:@{@"dir":@"rtl"}];
}

@end
