//
//   HTMLPurifier_ElementDefTest.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 15.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_ElementDef.h"
#import "HTMLPurifier_Harness.h"


@interface HTMLPurifier_ElementDefTest : HTMLPurifier_Harness

@end

@implementation HTMLPurifier_ElementDefTest

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

- (void)test_mergeIn
{
    HTMLPurifier_ElementDef* def1 = [HTMLPurifier_ElementDef new];
    HTMLPurifier_ElementDef* def2 = [HTMLPurifier_ElementDef new];
    HTMLPurifier_ElementDef* def3 = [HTMLPurifier_ElementDef new];


        NSNumber* old = @1;
        NSNumber* new = @2;
        NSString* overloaded_old = @"3";
        NSString* overloaded_new = @"4";
        NSNumber* removed = @5;

        def1.standalone = YES;
    def1.attr = [@{@0 : @[@"old-include"],
                            @"old-attr" : old,
                            @"overloaded-attr" : overloaded_old,
                            @"removed-attr" : removed
                  } mutableCopy];
    def1.attr_transform_post = [@{@"old-transform" : old,
                                           @"overloaded-transform" : overloaded_old,
                                           @"removed-transform" : removed
                                  } mutableCopy];
    def1.attr_transform_pre = def1.attr_transform_post;

    def1.child = (HTMLPurifier_ChildDef*)overloaded_old;
        def1.content_model = @"old";
        def1.content_model_type = overloaded_old;
        def1.descendants_are_inline = NO;
        def1.excludes = [@{
                               @"old" : @YES,
                               @"removed-old" : @YES
                                } mutableCopy];

        def2.standalone = false;
        def2.attr = [@{
                            @0 : @[@"new-include"],
                           @"new-attr" : new,
                           @"overloaded-attr" : overloaded_new,
                           @"removed-attr" : @NO
                            } mutableCopy];
        def2.attr_transform_post = [@{
                                          @"new-transform" : new,
                                          @"overloaded-transform" : overloaded_new,
                                          @"removed-transform" : @NO
                                           } mutableCopy];
    def2.attr_transform_pre = def2.attr_transform_post;

        def2.child = (HTMLPurifier_ChildDef*)new;
        def2.content_model = @"#SUPER | new";
        def2.content_model_type = overloaded_new;
        def2.descendants_are_inline = YES;
        def2.excludes = [@{
                               @"new" : @YES,
                               @"removed-old" : @NO
                                } mutableCopy];

        [def1 mergeIn:def2];
        [def1 mergeIn:def3]; // empty, has no effect

    XCTAssertEqual(def1.standalone, YES);
    NSDictionary* expectedDict = @{ @0 : @[@"old-include", @"new-include"],
                                    @"old-attr" : old,
                                    @"overloaded-attr" : overloaded_new,
                                    @"new-attr" : new };
    XCTAssertEqualObjects(def1.attr, expectedDict, @"");

    XCTAssertEqualObjects(def1.attr_transform_pre, def1.attr_transform_post, @"");





    expectedDict = @{ @"old-transform" : old,
                      @"overloaded-transform" : overloaded_new,
                      @"new-transform" : new };
    XCTAssertEqualObjects(def1.attr_transform_pre, expectedDict);

    XCTAssertEqualObjects(def1.child, new);

    XCTAssertEqualObjects(def1.content_model, @"old | new");
    XCTAssertEqualObjects(def1.content_model_type, overloaded_new);
    XCTAssertEqual(def1.descendants_are_inline, YES);
    expectedDict = @{@"old" : @YES, @"new" : @YES};

    expectedDict = @{ @"old" : @YES,
                      @"new" : @YES };

    XCTAssertEqualObjects(def1.excludes, expectedDict);
        
    }


@end
