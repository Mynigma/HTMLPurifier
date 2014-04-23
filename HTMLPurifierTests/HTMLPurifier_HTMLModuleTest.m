//
//   HTMLPurifier_HTMLModuleTest.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 22.01.14.


#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_HTMLModule.h"
#import "HTMLPurifier_ElementDef.h"
#import "HTMLPurifier_AttrDef.h"

@interface HTMLPurifier_HTMLModuleTest : HTMLPurifier_Harness

@end

@implementation HTMLPurifier_HTMLModuleTest

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

    - (void) test_addElementToContentSet
    {
        HTMLPurifier_HTMLModule* module = [HTMLPurifier_HTMLModule new];

        [module addElementToContentSet:@"b" type:@"Inline"];

        NSDictionary* expect = @{@"Inline" : @"b"};

        XCTAssertEqualObjects(module.content_sets, expect);

        [module addElementToContentSet:@"i" type:@"Inline"];

        expect = @{ @"Inline":@"b | i" };

        XCTAssertEqualObjects(module.content_sets, expect);

    }

    - (void) test_addElement
    {
        HTMLPurifier_HTMLModule* module = [HTMLPurifier_HTMLModule new];
        HTMLPurifier_ElementDef* def = [module addElement:@"a" type:@"Inline" contents:@"Optional: #PCDATA" attrIncludes:@[@"Common"] attr:@{@"href":@"URI"}];

        HTMLPurifier_HTMLModule* module2 = [HTMLPurifier_HTMLModule new];
        HTMLPurifier_ElementDef* def2 = [HTMLPurifier_ElementDef new];
        def2.content_model = @"#PCDATA";
        def2.content_model_type = @"optional";
        def2.attr = [@{
                            @"href" : @"URI",
                            @0 : @[@"Common"]
                            } mutableCopy];
        module2.info[@"a"] = def2;
        module2.elements = [@[@"a"] mutableCopy];
        module2.content_sets[@"Inline"] = @"a";

        XCTAssertEqualObjects(module, module2);
        XCTAssertEqualObjects(def, def2);
        XCTAssertEqualObjects(def, module.info[@"a"]);
    }

    - (void) test_parseContents
    {
        HTMLPurifier_HTMLModule* module = [HTMLPurifier_HTMLModule new];

        // pre-defined templates
        NSArray* array1 = [module parseContents:@"Inline"];
        NSArray* array2 = @[@"optional", @"Inline | #PCDATA"];

        XCTAssertEqualObjects(array1, array2);

        array1 = [module parseContents:@"Flow"];
        array2 = @[@"optional", @"Flow | #PCDATA"];
        XCTAssertEqualObjects(array1, array2);

        array1 = [module parseContents:@"Empty"];
        array2 = @[@"empty", @""];
        XCTAssertEqualObjects(array1, array2);

        // normalization procedures
        array1 = [module parseContents:@"optional: a"];
        array2 = @[@"optional", @"a"];
        XCTAssertEqualObjects(array1, array2);

        array1 = [module parseContents:@"OPTIONAL: a"];
        array2 = @[@"optional", @"a"];
        XCTAssertEqualObjects(array1, array2);


        array1 = [module parseContents:@"Optional: a"];
        array2 = @[@"optional", @"a"];
        XCTAssertEqualObjects(array1, array2);


        // others
        array1 = [module parseContents:@"Optional: a | b | c"];
        array2 = @[@"optional", @"a | b | c"];
        XCTAssertEqualObjects(array1, array2);

        // object pass-through

        HTMLPurifier_AttrDef* attrDefObject = [HTMLPurifier_AttrDef new];
        id attrDefMock = [OCMockObject partialMockForObject:attrDefObject];
        array1 = [module parseContents:attrDefMock];
        array2 = nil;
        XCTAssertEqualObjects(array1, array2);
    }

    - (void) test_mergeInAttrIncludes
    {
        HTMLPurifier_HTMLModule* module = [HTMLPurifier_HTMLModule new];

        NSMutableDictionary* attr = [NSMutableDictionary new];
        [module mergeInAttrIncludes:attr attrIncludes:@"Common"];
     
        NSDictionary* expect = @{ @0 : @[ @"Common" ] };
        XCTAssertEqualObjects(attr, expect);


        attr = [@{@"a" : @"b"} mutableCopy];
        [module mergeInAttrIncludes:attr attrIncludes:@[@"Common", @"Good"]];
        expect = @{ @"a" : @"b", @0 : @[@"Common", @"Good"]};
        XCTAssertEqualObjects(attr, expect);
    }

    - (void) test_addBlankElement
    {
        HTMLPurifier_HTMLModule* module = [HTMLPurifier_HTMLModule new];
        HTMLPurifier_ElementDef* def = [module addBlankElement:@"a"];

        HTMLPurifier_ElementDef* def2 = [HTMLPurifier_ElementDef new];
        def2.standalone = NO;

        XCTAssertEqual(module.info[@"a"], def);
        XCTAssertEqualObjects(def, def2);
    }
    
    - (void) test_makeLookup
    {
        HTMLPurifier_HTMLModule* module = [HTMLPurifier_HTMLModule new];

        NSDictionary* expect = @{@"foo" : @YES };
        
        XCTAssertEqualObjects([module makeLookup:@"foo"], expect);

        XCTAssertEqualObjects([module makeLookup:@[@"foo"]], expect);
        
        expect = @{@"foo" : @YES, @"two" : @YES};

        NSDictionary* result = [module makeLookup:@[@"foo", @"two"]];

        XCTAssertEqualObjects(result, expect);

    }



@end
