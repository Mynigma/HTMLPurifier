//
//   HTMLPurifier_ZipperTest.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 21.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Zipper.h"

@interface HTMLPurifier_ZipperTest : HTMLPurifier_Harness

@end

@implementation HTMLPurifier_ZipperTest

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

- (void)testBasicNavigation
{
    NSArray* tmp = [HTMLPurifier_Zipper fromArray:@[@0,@1,@2,@3]];
    
    HTMLPurifier_Zipper* z = tmp[0];
    NSObject* t = tmp[1];
    
    XCTAssertEqualObjects(t, @0);
    
    //next
    t = [z next:t];
    XCTAssertEqualObjects(t, @1);
    
    //prev
    t = [z prev:t];
    XCTAssertEqualObjects(t, @0);
    
    //advance
    t = [z advance:t by:2];
    XCTAssertEqualObjects(t, @2);
    
    //delete
    t = [z delete];
    XCTAssertEqualObjects(t, @3);
    
    //Insert
    [z insertBefore:@4];
    [z insertAfter:@5];
    
    NSArray* a = @[@0,@1,@4,@3,@5];
    XCTAssertEqualObjects(a,[z toArray:t]);
    
    
    tmp = (NSArray*)[z splice:t delete:2 replacement:@[@6,@7]];
    
    NSArray* old = tmp[0];
    t = tmp[1];
    
    a = @[@3,@5];
    XCTAssertEqualObjects(old, a);
    
    NSNumber* n = @6;
    XCTAssertEqualObjects(t, n);
    
    a = @[@0,@1,@4,@6,@7];
    XCTAssertEqualObjects([z toArray:t], a);
}

@end
