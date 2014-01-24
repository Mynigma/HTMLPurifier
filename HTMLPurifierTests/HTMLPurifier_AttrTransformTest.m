//
//  HTMLPurifier_AttrTransformTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 24.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_AttrTransform.h"

@interface HTMLPurifier_AttrTransformTest : HTMLPurifier_Harness

@end

@implementation HTMLPurifier_AttrTransformTest

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

-(void) test_prependCSS
{
    //MOCK
    HTMLPurifier_AttrTransform* t = [HTMLPurifier_AttrTransform new];
    
    //One should test also if the "sorted Keys" are the same, but it will be tested in subtest anyway...
    
    NSMutableDictionary* attr = [@{} mutableCopy];
    [t prependCSS:attr sortedKeys:[@[@"style"] mutableCopy]  css:@"style:new;"];
    XCTAssertEqualObjects(@{@"style" : @"style:new;"}, attr);
    
    attr = [@{@"style" : @"style:original;"} mutableCopy];
    [t prependCSS:attr sortedKeys:[@[@"style"] mutableCopy] css:@"style:new;"];
    XCTAssertEqualObjects(@{@"style" : @"style:new;style:original;"}, attr);
    
    attr = [@{@"style" : @"style:original;", @"misc" : @"un-related"} mutableCopy];
    [t prependCSS:attr sortedKeys:[@[@"style",@"misc"] mutableCopy] css:@"style:new;"];
    NSDictionary* dic = @{@"style" : @"style:new;style:original;", @"misc" : @"un-related"};
    XCTAssertEqualObjects(dic, attr);

}

-(void) test_confiscateAttr
{
    
    //MOCK
    HTMLPurifier_AttrTransform* t = [HTMLPurifier_AttrTransform new];
    
    NSMutableDictionary* attr = [@{@"flavor" : @"sweet"} mutableCopy];
    NSMutableArray* sortedKeys = [@[@"flavor"] mutableCopy];
    
    XCTAssertEqualObjects(@"sweet",[t confiscateAttr:attr sortedKeys:sortedKeys key:@"flavor"]);
    XCTAssertEqualObjects(@{}, attr);
    
    attr = [@{@"flavor" : @"sweet"} mutableCopy];
    sortedKeys = [@[@"flavor"] mutableCopy];
    XCTAssertEqualObjects(nil, [t confiscateAttr:attr sortedKeys:sortedKeys key:@"color"]);
    XCTAssertEqualObjects(@{@"flavor" : @"sweet"}, attr);
    
}

@end
