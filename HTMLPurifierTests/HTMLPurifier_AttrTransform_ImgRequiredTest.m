//
//  HTMLPurifier_AttrTransform_ImgRequiredTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 25.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrTransformHarness.h"
#import "HTMLPurifier_AttrTransform_ImgRequired.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_IDAccumulator.h"

@interface HTMLPurifier_AttrTransform_ImgRequiredTest : HTMLPurifier_AttrTransformHarness
{
    HTMLPurifier_Config* config;
    HTMLPurifier_AttrTransform_ImgRequired* obj;
}
@end

@implementation HTMLPurifier_AttrTransform_ImgRequiredTest

- (void)setUp
{
    [super setUp];
    obj = [HTMLPurifier_AttrTransform_ImgRequired new];
    config = [HTMLPurifier_Config new];
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

-(void) testAddMissingAttr
{
    [config setString:@"Core.RemoveInvalidImg" object:@NO];
    [self assertResult:@{} expect:@{@"src":@"", @"alt":@"Invalid image"}];
}

-(void) testAlternateDefaults
{
    [config setString:@"Attr.DefaultInvalidImage" object:@"blank.png"];
    [config setString:@"Attr.DefaultInvalidImageAlt" object:@"Pawned!"];
    [config setString:@"Attr.DefaultImageAlt" object:@"not pawned"];
    [config setString:@"Core.RemoveInvalidImg" object:@NO];
    [self assertResult:@{} expect:@{@"src":@"blank.png", @"alt":@"Pawned!"}];
}

-(void) testGenerateAlt
{
    [self assertResult:@{@"src":@"/path/to/foobar.png"} expect:@{@"src":@"/path/to/foobar.png", @"alt":@"foobar.png"}];
}

-(void) testAddDefaultSrc
{
    [config setString:@"Core.RemoveInvalidImg" object:@NO];
    [self assertResult:@{@"alt":@"intrigue"} expect:@{@"alt":@"intrigue",@"src":@""}];
}

-(void) testAddDefaultAlt
{
    [config setString:@"Attr.DefaultImageAlt" object:@"default"];
    [self assertResult:@{@"src":@""} expect:@{@"src":@"", @"alt":@"default"}];
}


@end
