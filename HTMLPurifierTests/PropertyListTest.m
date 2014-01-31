//
//  PropertyListTest.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 15.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_PropertyList.h"

@interface PropertyListTest : XCTestCase

@end

@implementation PropertyListTest

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

- (void)testBasic
{
    HTMLPurifier_PropertyList* plist = [HTMLPurifier_PropertyList new];
    [plist set:@"key" value:@"value"];
    XCTAssertEqualObjects([plist get:@"key"], @"value");
}

- (void)testNotFound
{
    HTMLPurifier_PropertyList* plist = [HTMLPurifier_PropertyList new];
    BOOL gotException = NO;
    @try{
        [plist get:@"key"];
    }
    @catch (NSException* e) {
        gotException = YES;
    }
    XCTAssert(gotException);
}


- (void)testRecursion
{
    HTMLPurifier_PropertyList* parent_plist = [HTMLPurifier_PropertyList new];
    [parent_plist set:@"key" value:@"value"];
    HTMLPurifier_PropertyList* plist = [HTMLPurifier_PropertyList new];
    [plist setParent:parent_plist];
    XCTAssertEqualObjects([plist get:@"key"], @"value");
}

- (void)testOverride
{
    HTMLPurifier_PropertyList* parent_plist = [HTMLPurifier_PropertyList new];
    [parent_plist set:@"key" value:@"value"];
    HTMLPurifier_PropertyList* plist = [HTMLPurifier_PropertyList new];
    [plist setParent:parent_plist];
    [plist set:@"key" value:@"value2"];
    XCTAssertEqualObjects([plist get:@"key"], @"value2");
}

- (void)testRecursionNotFound
{
    BOOL gotException = NO;
    HTMLPurifier_PropertyList* parent_plist = [HTMLPurifier_PropertyList new];
    HTMLPurifier_PropertyList* plist = [HTMLPurifier_PropertyList new];
    [plist setParent:parent_plist];
    @try
    {
        [plist get:@"key"];
        gotException = YES;
    }
    @catch (NSException* e)
    {
        gotException = YES;
    }
    XCTAssert(gotException);
}


- (void)testHas
{
    HTMLPurifier_PropertyList* plist = [HTMLPurifier_PropertyList new];
    XCTAssertFalse([plist has:@"key"]);
    [plist set:@"key" value:@"value"];
    XCTAssertTrue([plist has:@"key"]);
}

- (void)testReset
{
    HTMLPurifier_PropertyList* plist = [HTMLPurifier_PropertyList new];
    [plist set:@"key1" value:@"value"];
    [plist set:@"key2" value:@"value"];
    [plist set:@"key3" value:@"value"];

    XCTAssertEqual([plist has:@"key1"], YES);
    XCTAssertEqual([plist has:@"key2"], YES);
    XCTAssertEqual([plist has:@"key3"], YES);

    [plist reset:@"key2"];

    XCTAssertEqual([plist has:@"key1"], YES);
    XCTAssertEqual([plist has:@"key2"], NO);
    XCTAssertEqual([plist has:@"key3"], YES);

    [plist reset];

    XCTAssertEqual([plist has:@"key1"], NO);
    XCTAssertEqual([plist has:@"key2"], NO);
    XCTAssertEqual([plist has:@"key3"], NO);
    }

- (void)testSquash
{
    HTMLPurifier_PropertyList* parent = [HTMLPurifier_PropertyList new];
    [parent reset];
    [parent set:@"key1" value:@"hidden"];
    [parent set:@"key2" value:@2];
    HTMLPurifier_PropertyList* plist = [[HTMLPurifier_PropertyList alloc] initWithParent:parent];
    [plist reset];
    [plist set:@"key1" value:@1];
    [plist set:@"key3" value:@3];

    NSMutableDictionary* expected = [@{@"key1" : @1, @"key2" : @2, @"key3" : @3} mutableCopy];
    XCTAssertEqualObjects([plist squash], expected);

        // updates don't show up...
    [plist set:@"key2" value:@22];

    XCTAssertEqualObjects([plist squash], expected);
        // until you force

    [expected setObject:@22 forKey:@"key2"];

    XCTAssertEqualObjects([plist squash:YES], expected);
    }



@end
