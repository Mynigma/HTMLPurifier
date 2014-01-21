//
//  HTMLPurifier_URIFilter_MakeAbsoluteTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 20.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_URIFilter_MakeAbsolute.h"
#import "HTMLPurifier_URIFilterHarness.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_URI.h"

@interface HTMLPurifier_URIFilter_MakeAbsoluteTest : HTMLPurifier_URIFilterHarness

@end

@implementation HTMLPurifier_URIFilter_MakeAbsoluteTest

- (void)setUp
{
    [super setUp];
    self.filter = [HTMLPurifier_URIFilter_MakeAbsolute new];
    [self setBase:@"http://example.com/foo/bar.html?q=s#frag"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) setBase:(NSString*)base
{
    [self.config setString:@"URI.Base" object:base];
}

-(void) assertFiltering:(NSObject*)uri expect:(NSObject*)expect_uri // = true)
{
    [super prepareURI:&uri expect:&expect_uri];
    
    [self.filter prepare:self.config];
    
    BOOL result = [self.filter filter:(HTMLPurifier_URI**)&uri config:self.config context:self.context];
    
    [self assertEitherFailOrIdentical:result result:uri
                               expect:expect_uri];
}

- (void)assertEitherFailOrIdentical:(BOOL)status result:(NSObject*)result expect:(NSObject*)expect
{
    if ([(NSNumber*)expect isEqual:@NO])
    {
        XCTAssertFalse(status, @"Expected false result, got true");
    }
    else
    {
        XCTAssertTrue(status, @"Expected true result, got false");
        XCTAssertEqualObjects(result,expect, @"Expected status %@ to be equal to %@", result, expect);
    }
}

// corresponding to RFC 2396

-(void)  testPreserveAbsolute
{
    [self assertFiltering:@"http://example.com/foo.html" expect:@YES];
}

-(void)  testFilterBlank
{
    [self assertFiltering:@"" expect:@"http://example.com/foo/bar.html?q=s"];
}

-(void) testFilterEmptyPath
{
    [self assertFiltering:@"?q=s#frag" expect:@"http://example.com/foo/bar.html?q=s#frag"];
}

-(void) testPreserveAltScheme
{
    [self assertFiltering:@"mailto:bob@example.com" expect:@YES];
}

-(void) testFilterIgnoreHTTPSpecialCase
{
    [self assertFiltering:@"http:/" expect:@"http://example.com/"];
}

-(void) testFilterAbsolutePath
{
    [self assertFiltering:@"/foo.txt" expect:@"http://example.com/foo.txt"];
}

-(void) testFilterRelativePath
{
    [self assertFiltering:@"baz.txt" expect:@"http://example.com/foo/baz.txt"];
}

-(void) testFilterRelativePathWithInternalDot
{
    [self assertFiltering:@"./baz.txt" expect:@"http://example.com/foo/baz.txt"];
}

-(void) testFilterRelativePathWithEndingDot
{
    [self assertFiltering:@"baz/." expect:@"http://example.com/foo/baz/"];
}

-(void) testFilterRelativePathDot
{
    [self assertFiltering:@"." expect:@"http://example.com/foo/"];
}

-(void) testFilterRelativePathMultiDot
{
    [self assertFiltering:@"././foo/./bar/.././baz" expect:@"http://example.com/foo/foo/baz"];
}

-(void) testFilterAbsolutePathWithDot
{
    [self assertFiltering:@"/./foo" expect:@"http://example.com/foo"];
}

-(void) testFilterAbsolutePathWithMultiDot
{
    [self assertFiltering:@"/./foo/../bar/." expect:@"http://example.com/bar/"];
}

-(void) testFilterRelativePathWithInternalDotDot
{
    [self assertFiltering:@"../baz.txt" expect:@"http://example.com/baz.txt"];
}

-(void) testFilterRelativePathWithEndingDotDot
{
    [self assertFiltering:@".." expect:@"http://example.com/"];
}

-(void) testFilterRelativePathTooManyDotDots
{
    [self assertFiltering:@"../../" expect:@"http://example.com/"];
}

-(void) testFilterAppendingQueryAndFragment
{
    [self assertFiltering:@"/foo.php?q=s#frag" expect:@"http://example.com/foo.php?q=s#frag"];
}

// edge cases below

-(void) testFilterAbsolutePathBase
{
    [self setBase:@"/foo/baz.txt"];
    [self assertFiltering:@"test.php" expect:@"/foo/test.php"];
}

-(void) testFilterAbsolutePathBaseDirectory
{
    [self setBase:@"/foo/"];
    [self assertFiltering:@"test.php" expect:@"/foo/test.php"];
}

-(void) testFilterAbsolutePathBaseBelow
{
    [self setBase:@"/foo/baz.txt"];
    [self assertFiltering:@"../../test.php" expect:@"/test.php"];
}

-(void) testFilterRelativePathBase
{
    [self setBase:@"foo/baz.html"];
    [self assertFiltering:@"foo.php" expect:@"foo/foo.php"];
}

-(void) testFilterRelativePathBaseBelow
{
    [self setBase:@"../baz.html"];
    [self assertFiltering:@"test/strike.html" expect:@"../test/strike.html"];
}

-(void) testFilterRelativePathBaseWithAbsoluteURI
{
    [self setBase:@"../baz.html"];
    [self assertFiltering:@"/test/strike.html" expect:@YES];
}

-(void) testFilterRelativePathBaseWithDot
{
    [self setBase:@"../baz.html"];
    [self assertFiltering:@"." expect:@"../"];
}

-(void) testRemoveJavaScriptWithEmbeddedLink
{
    // credits: NykO18
    [self setBase:@"http://www.example.com/"];
    [self assertFiltering:@"javascript: window.location = 'http://www.example.com';" expect:@NO];
}

// miscellaneous

-(void) testFilterDomainWithNoSlash
{
    [self setBase:@"http://example.com"];
    [self assertFiltering:@"foo" expect:@"http://example.com/foo"];
}

// error case

-(void) testErrorNoBase
{
    [self setBase:@""];
    //$this->expectError('URI.MakeAbsolute is being ignored due to lack of value for URI.Base configuration"];
    [self assertFiltering:@"foo/bar.txt" expect:@YES];
}

@end
