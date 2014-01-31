//
//  HTMLPurifier_AttrTransform_BackgroundTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 24.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrTransformHarness.h"
#import "HTMLPurifier_AttrTransform_Background.h"

@interface HTMLPurifier_AttrTransform_BackgroundTest : HTMLPurifier_AttrTransformHarness
{
    HTMLPurifier_AttrTransform_Background* obj;
}
@end



@implementation HTMLPurifier_AttrTransform_BackgroundTest

- (void)setUp
{
    [super setUp];
    obj = [HTMLPurifier_AttrTransform_Background new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
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


-(void) testEmptyInput
{
    [self assertResult:@{} expect:@{}];
}

-(void) testBasicTransform
{
    [self assertResult:@{@"background" : @"logo.png"} expect:@{@"style" : @"background-image:url(logo.png);"}];
}


-(void) testPrependNewCSS
{
    [self assertResult:@{@"background" : @"logo.png", @"style" : @"font-weight:bold"}
                expect:@{@"style" : @"background-image:url(logo.png);font-weight:bold"}];
}

-(void) testLenientTreatmentOfInvalidInput
{
    // notice that we rely on the CSS validator later to fix this invalid
    // stuff
    [self assertResult:@{@"background" : @"logo.png);foo:("} expect:@{@"style" : @"background-image:url(logo.png);foo:();"}];
}


@end
