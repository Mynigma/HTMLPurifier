//
//  URIParserTest.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.m"

@interface URIParserTest : HTMLPurifier_Harness

@end

@implementation URIParserTest

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

- (void)testExample
{

}

- (void) assertParsing($uri, $scheme, $userinfo, $host, $port, $path, $query, $fragment, $config = null, $context = null)
{
        [self prepareCommon:config context:context];
        $parser = new HTMLPurifier_URIParser();
        $result = $parser->parse($uri, $config, $context);
        $expect = new HTMLPurifier_URI($scheme, $userinfo, $host, $port, $path, $query, $fragment);
        $this->assertEqual($result, $expect);
    }

- (void)testPercentNormalization
{
    [self assertParsing:@"%G", nil, nil, nil, nil, @"%25G", nil, nil];
}

    function testRegular() {
        $this->assertParsing(
                             'http://www.example.com/webhp?q=foo#result2',
                             'http', null, 'www.example.com', null, '/webhp', 'q=foo', 'result2'
                             );
    }

    function testPortAndUsername() {
        $this->assertParsing(
                             'http://user@authority.part:80/now/the/path?query#fragment',
                             'http', 'user', 'authority.part', 80, '/now/the/path', 'query', 'fragment'
                             );
    }

    function testPercentEncoding() {
        $this->assertParsing(
                             'http://en.wikipedia.org/wiki/Clich%C3%A9',
                             'http', null, 'en.wikipedia.org', null, '/wiki/Clich%C3%A9', null, null
                             );
    }

    function testEmptyQuery() {
        $this->assertParsing(
                             'http://www.example.com/?#',
                             'http', null, 'www.example.com', null, '/', '', null
                             );
    }

    function testEmptyPath() {
        $this->assertParsing(
                             'http://www.example.com',
                             'http', null, 'www.example.com', null, '', null, null
                             );
    }

    function testOpaqueURI() {
        $this->assertParsing(
                             'mailto:bob@example.com',
                             'mailto', null, null, null, 'bob@example.com', null, null
                             );
    }

    function testIPv4Address() {
        $this->assertParsing(
                             'http://192.0.34.166/',
                             'http', null, '192.0.34.166', null, '/', null, null
                             );
    }

    function testFakeIPv4Address() {
        $this->assertParsing(
                             'http://333.123.32.123/',
                             'http', null, '333.123.32.123', null, '/', null, null
                             );
    }

    function testIPv6Address() {
        $this->assertParsing(
                             'http://[2001:db8::7]/c=GB?objectClass?one',
                             'http', null, '[2001:db8::7]', null, '/c=GB', 'objectClass?one', null
                             );
    }

    function testInternationalizedDomainName() {
        $this->assertParsing(
                             "http://t\xC5\xABdali\xC5\x86.lv",
                             'http', null, "t\xC5\xABdali\xC5\x86.lv", null, '', null, null
                             );
    }

    function testInvalidPort() {
        $this->assertParsing(
                             'http://example.com:foobar',
                             'http', null, 'example.com', null, '', null, null
                             );
    }

    function testPathAbsolute() {
        $this->assertParsing(
                             'http:/this/is/path',
                             'http', null, null, null, '/this/is/path', null, null
                             );
    }

    function testPathRootless() {
        // this should not be used but is allowed
        $this->assertParsing(
                             'http:this/is/path',
                             'http', null, null, null, 'this/is/path', null, null
                             );
    }
    
    function testPathEmpty() {
        $this->assertParsing(
                             'http:',
                             'http', null, null, null, '', null, null
                             );
    }
    
    function testRelativeURI() {
        $this->assertParsing(
                             '/a/b',
                             null, null, null, null, '/a/b', null, null
                             );
    }
    
    function testMalformedTag() {
        $this->assertParsing(
                             'http://www.example.com/>',
                             'http', null, 'www.example.com', null, '/', null, null
                             );
    }
    
    function testEmpty() {
        $this->assertParsing(
                             '',
                             null, null, null, null, '', null, null
                             );
    }

@end
