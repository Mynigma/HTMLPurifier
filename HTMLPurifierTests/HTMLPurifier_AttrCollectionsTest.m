//
//   HTMLPurifier_AttrCollectionsTest.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 22.01.14.


#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_AttrTypes.h"
#import "HTMLPurifier_AttrCollections.h"
#import "HTMLPurifier_HTMLModule.h"
#import "HTMLPurifier_AttrDef_HTML_Color.h"
#import "HTMLPurifier_AttrDef_URI.h"
#import "HTMLPurifier_AttrCollections_TestForConstruct.h"


@interface HTMLPurifier_AttrCollectionsTest : HTMLPurifier_Harness

@end

@implementation HTMLPurifier_AttrCollectionsTest

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



- (void)testConstruction
{
    id attrTypesMock = [OCMockObject mockForClass:[HTMLPurifier_AttrTypes class]];

    //$collections = new HTMLPurifier_AttrCollections_TestForConstruct();

    [[[attrTypesMock stub] andReturn:nil] get:[OCMArg any]];

    NSMutableDictionary* modules = [NSMutableDictionary new];

    modules[@"Module1"] = [HTMLPurifier_HTMLModule new];
    [(HTMLPurifier_HTMLModule*)modules[@"Module1"] setAttr_collections:[@{
                                                    @"Core" : @{
                                                      @0 : @[ @"Soup", @"Undefined"],
                                                                  @"attribute" : @"Type",
                                                                  @"attribute-2" : @"Type2",
                                                      },  @"Soup" : @{ @"attribute-3" : @"Type3-old" // overwritten
                                                                       }
                                                  } mutableCopy]];

    modules[@"Module2"] = [HTMLPurifier_HTMLModule new];

    [(HTMLPurifier_HTMLModule*)modules[@"Module2"] setAttr_collections:[@{@"Core" : @{ @0 : @[@"Brocolli"] }, @"Soup" : @{ @"attribute-3" : @"Type3" }, @"Brocolli" : @{} } mutableCopy]];

    HTMLPurifier_AttrCollections* collections = [[HTMLPurifier_AttrCollections_TestForConstruct alloc] initWithAttrTypes:attrTypesMock modules:modules];

    // this is without identifier expansion or inclusions
    NSDictionary* expected = @{@"Core" : @{ @0 : @[@"Soup", @"Undefined", @"Brocolli"],
                                            @"attribute" : @"Type",
                                            @"attribute-2" : @"Type2"
                                            },
                               @"Soup" : @{
                                       @"attribute-3" : @"Type3"
                                       },
                               @"Brocolli" : @{}
                               };
    XCTAssertEqualObjects([collections info], expected);

}

- (void)test_performInclusions
{
    id attrTypesMock = [OCMockObject mockForClass:[HTMLPurifier_AttrTypes class]];

    HTMLPurifier_AttrCollections* collections = [[HTMLPurifier_AttrCollections alloc] initWithAttrTypes:attrTypesMock modules:@{}];
    collections.info = [@{
                         @"Core" : [@{ @0 : @[@"Inclusion", @"Undefined"], @"attr-original" : @"Type" } mutableCopy],
                         @"Inclusion" : @{ @0 : @[@"SubInclusion"], @"attr" : @"Type"},
                         @"SubInclusion" : @{@"attr2" : @"Type"}
                         } mutableCopy];

    [collections performInclusions:collections.info[@"Core"]];
    NSDictionary* expect = @{ @"attr-original" : @"Type", @"attr" : @"Type", @"attr2" : @"Type"};
    XCTAssertEqualObjects(collections.info[@"Core"], expect);

    // test recursive
    collections.info = [@{ @"One" : [@{ @0 : @[@"Two"], @"one" : @"Type" } mutableCopy],
                          @"Two" : [@{ @0 : @[@"One"], @"two" : @"Type"} mutableCopy]
                          } mutableCopy];
    [collections performInclusions:collections.info[@"One"]];

    expect = @{ @"one" : @"Type", @"two" : @"Type" };
    XCTAssertEqualObjects(collections.info[@"One"], expect);

}

- (void)test_expandIdentifiers
{
    id attrTypesMock = [OCMockObject mockForClass:[HTMLPurifier_AttrTypes class]];

    HTMLPurifier_AttrCollections* collections = [[HTMLPurifier_AttrCollections alloc] initWithAttrTypes:attrTypesMock modules:@{}];

    NSMutableDictionary* attr = [@{
                  @"attr1" : @"Color",
                  @"attr2*" : @"URI"
                  } mutableCopy];
    HTMLPurifier_AttrDef_HTML_Color* c_object = [HTMLPurifier_AttrDef_HTML_Color new];
    HTMLPurifier_AttrDef_URI* u_object = [HTMLPurifier_AttrDef_URI new];

    [[[attrTypesMock stub] andReturn:c_object] get:@"Color"];
    [[[attrTypesMock stub] andReturn:u_object] get:@"URI"];

    [collections expandIdentifiers:attr attrTypes:attrTypesMock];

    u_object.required = YES;

    NSDictionary* expect = @{ @"attr1" : c_object, @"attr2" : u_object };
    XCTAssertEqualObjects(attr, expect);
}


@end
