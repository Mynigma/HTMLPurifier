//
//  HTMLPurifierTests.m
//  HTMLPurifierTests
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"


@interface HTMLPurifierTests : HTMLPurifier_Harness
{
    HTMLPurifier_Config* config;

    /**
     * @type HTMLPurifier_Context
     */
    HTMLPurifier_Context* context;

    /**
     * @type HTMLPurifier
     */
    HTMLPurifier* purifier;
}

@end

@implementation HTMLPurifierTests

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

- (void)testNull
{
    [self assertPurification:@"Null byte\0" expect:@"Null byte"];
}

- (void)test_purifyArray
{
    NSArray* result = [purifier purifyArray:@[@"Good", @"<b>Sketchy", @{@"foo" : @"<script>bad</script>"}]];
    NSArray* expect = @[@"Good", @"<b>Sketchy</b>", @{@"foo" : @""}];
    XCTAssertEqualObjects(result, expect);

    XCTAssertTrue([purifier.context isKindOfClass:[NSArray class]]);
}

- (void)testGetInstance
{
    HTMLPurifier* purifier1  = [HTMLPurifier instance];
    HTMLPurifier* purifier2 = [HTMLPurifier instance];
    XCTAssertEqual(purifier1, purifier2);
}

/*
- (void)testMakeAbsolute
{
    config set('URI.Base', 'http://example.com/bar/baz.php');
    $this->config->set('URI.MakeAbsolute', true);
    $this->assertPurification(
                              '<a href="foo.txt">Foobar</a>',
                              '<a href="http://example.com/bar/foo.txt">Foobar</a>'
                              );
}

- (void)testDisableResources()
{
    $this->config->set('URI.DisableResources', true);
    $this->assertPurification('<img src="foo.jpg" />', '');
}

- (void)test_addFilter_deprecated()
{
    $this->expectError('HTMLPurifier->addFilter() is deprecated, use configuration directives in the Filter namespace or Filter.Custom');
    generate_mock_once('HTMLPurifier_Filter');
    $this->purifier->addFilter($mock = new HTMLPurifier_FilterMock());
    $mock->expectOnce('preFilter');
    $mock->expectOnce('postFilter');
    $this->purifier->purify('foo');
}*/


@end
