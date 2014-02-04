//
//   HTMLPurifierTests.m
//   HTMLPurifierTests
//
//  Created by Lukas Neumann on 10.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"


@interface HTMLPurifierTests : HTMLPurifier_Harness
{
    /**
     * @type HTMLPurifier
     */
    HTMLPurifier* purifier;
}

@end

@implementation HTMLPurifierTests

- (void)setUp
{
    [super createCommon];
    [super.config setString:@"Output.Newline" object:@"\n"];
    purifier = [HTMLPurifier new];
    [super setUp];
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
    NSArray* result = [purifier purifyArray:@[@"Good", @"<b>Sketchy", @"<script>bad</script>"]];
    NSArray* expect = @[@"Good", @"<b>Sketchy</b>", @""];
    XCTAssertEqualObjects(result, expect);

    XCTAssertTrue([purifier.context isKindOfClass:[NSArray class]]);
}

- (void)testGetInstance
{
    HTMLPurifier* purifier1  = [HTMLPurifier instance];
    HTMLPurifier* purifier2 = [HTMLPurifier instance];
    XCTAssertEqual(purifier1, purifier2);
}

- (void)testLinkify
{
    NSString* result = [purifier purify:@"Hi Lukas, hier ist ein Link: http://www.mynigma.org/test.html"];
    NSString* expect = @"Hi Lukas, hier ist ein Link: <a href=\"http://www.mynigma.org/test.html\">http://www.mynigma.org/test.html</a>";
    XCTAssertEqualObjects(result, expect);

}

-(void)d_testDebug
{
    NSString* data = [[NSString alloc] initWithContentsOfFile:@"/Users/Lukas/Desktop/DriveNow Monatsübersicht Januar.txt" encoding:NSUTF8StringEncoding error:nil];
    NSString* result = [purifier purify:data];
    NSString* expect = @"";
    XCTAssertEqualObjects(result, expect);
    
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
