//
//  HTMLPurifier_URITest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 21.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_URIDefinition.h"
#import "HTMLPurifier_URIHarness.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_URI.h"
#import "HTMLPurifier_URISchemeRegistry.h"
#import "HTMLPurifier_URIScheme.h"
#import "HTMLPurifier_URIScheme_http.h"
#import "HTMLPurifier_URIParser.h"

@interface HTMLPurifier_URITest : HTMLPurifier_URIHarness
{
    HTMLPurifier_URISchemeRegistry* oldRegistry;
}
@end

@implementation HTMLPurifier_URITest

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

-(HTMLPurifier_URI*) createURI:(NSString*)uri
{
    HTMLPurifier_URIParser* parser = [HTMLPurifier_URIParser new];
    return [parser parse:uri];
}

-(void) test_construct
{
    HTMLPurifier_URI* uri1 = [[HTMLPurifier_URI alloc] initWithScheme:@"HTTP" userinfo:@"bob" host:@"example.com" port:@23 path:@"/foo" query:@"bar=2" fragment:@"slash"];
    
    HTMLPurifier_URI* uri2 = [[HTMLPurifier_URI alloc] initWithScheme:@"http" userinfo:@"bob" host:@"example.com" port:@23 path:@"/foo" query:@"bar=2" fragment:@"slash"];
    XCTAssertEqualObjects(uri1.toString, uri2.toString, @"");
}

-(HTMLPurifier_URISchemeRegistry*) setUpSchemeRegistryMock
{
    oldRegistry = [HTMLPurifier_URISchemeRegistry instance:nil];
    
    //generate_mock_once('HTMLPurifier_URIScheme');
    //generate_mock_once('HTMLPurifier_URISchemeRegistry');
    
    HTMLPurifier_URISchemeRegistry * registry = [HTMLPurifier_URISchemeRegistry instance:
                                                 [HTMLPurifier_URISchemeRegistry new]];
    return registry;
}


-(void) test_getSchemeObj
{
    HTMLPurifier_URIScheme* scheme_mock = [HTMLPurifier_URIScheme_http new];

    HTMLPurifier_URI* uri = [self createURI:@"http:"];
    HTMLPurifier_URIScheme* scheme_obj = [uri getSchemeObj:self.config context:self.context];
    XCTAssertEqualObjects(scheme_obj, scheme_mock);
}

/*
-(void) test_getSchemeObj_invalidScheme
{
    $this->setUpNoValidSchemes;
    
    $uri = $this->createURI('http:');
    $result = $uri->getSchemeObj($this->config, $this->context);
    $this->assertIdentical($result, false);
    
    $this->tearDownSchemeRegistryMock;
}

-(void) test_getSchemaObj_defaultScheme
{
    $scheme = 'foobar';
    
    $scheme_mock = $this->setUpSchemeMock($scheme);
    $this->config->set('URI.DefaultScheme', $scheme);
    
    $uri = $this->createURI('hmm');
    $scheme_obj = $uri->getSchemeObj($this->config, $this->context);
    $this->assertIdentical($scheme_obj, $scheme_mock);
    
    $this->tearDownSchemeRegistryMock;
}

-(void) test_getSchemaObj_invalidDefaultScheme
{
    $this->setUpNoValidSchemes;
    $this->config->set('URI.DefaultScheme', 'foobar');
    
    $uri = $this->createURI('hmm');
    
    $this->expectError('Default scheme object "foobar" was not readable');
    $result = $uri->getSchemeObj($this->config, $this->context);
    $this->assertIdentical($result, false);
    
    $this->tearDownSchemeRegistryMock;
}

protected function assertToString($expect_uri, $scheme, $userinfo, $host, $port, $path, $query, $fragment)
{
    $uri = new HTMLPurifier_URI($scheme, $userinfo, $host, $port, $path, $query, $fragment);
    $string = $uri->toString;
    $this->assertIdentical($string, $expect_uri);
}

-(void) test_toString_full
{
    $this->assertToString(
                          'http://bob@example.com:300/foo?bar=baz#fragment',
                          'http', 'bob', 'example.com', 300, '/foo', 'bar=baz', 'fragment'
                          );
}

-(void) test_toString_scheme
{
    $this->assertToString(
                          'http:',
                          'http', null, null, null, '', null, null
                          );
}

-(void) test_toString_authority
{
    $this->assertToString(
                          '//bob@example.com:8080',
                          null, 'bob', 'example.com', 8080, '', null, null
                          );
}

-(void) test_toString_path
{
    $this->assertToString(
                          '/path/to',
                          null, null, null, null, '/path/to', null, null
                          );
}

-(void) test_toString_query
{
    $this->assertToString(
                          '?q=string',
                          null, null, null, null, '', 'q=string', null
                          );
}

-(void) test_toString_fragment
{
    $this->assertToString(
                          '#fragment',
                          null, null, null, null, '', null, 'fragment'
                          );
}

protected function assertValidation($uri, $expect_uri = true)
{
    if ($expect_uri === true) $expect_uri = $uri;
    $uri = $this->createURI($uri);
    $result = $uri->validate($this->config, $this->context);
    if ($expect_uri === false) {
        $this->assertFalse($result);
    } else {
        $this->assertTrue($result);
        $this->assertIdentical($uri->toString, $expect_uri);
    }
}

-(void) test_validate_overlongPort
{
    $this->assertValidation('http://example.com:65536', 'http://example.com');
}

-(void) test_validate_zeroPort
{
    $this->assertValidation('http://example.com:00', 'http://example.com');
}

-(void) test_validate_invalidHostThatLooksLikeIPv6
{
    $this->assertValidation('http://[2001:0db8:85z3:08d3:1319:8a2e:0370:7334]', '');
}

-(void) test_validate_removeRedundantScheme
{
    $this->assertValidation('http:foo:/:', 'foo%3A/:');
}

-(void) test_validate_username
{
    $this->assertValidation("http://user\xE3\x91\x94:@foo.com", 'http://user%E3%91%94:@foo.com');
}

-(void) test_validate_path_abempty
{
    $this->assertValidation("http://host/\xE3\x91\x94:", 'http://host/%E3%91%94:');
}

-(void) test_validate_path_absolute
{
    $this->assertValidation("/\xE3\x91\x94:", '/%E3%91%94:');
}

-(void) test_validate_path_rootless
{
    $this->assertValidation("mailto:\xE3\x91\x94:", 'mailto:%E3%91%94:');
}

-(void) test_validate_path_noscheme
{
    $this->assertValidation("\xE3\x91\x94", '%E3%91%94');
}

-(void) test_validate_query
{
    $this->assertValidation("?/\xE3\x91\x94", '?/%E3%91%94');
}

-(void) test_validate_fragment
{
    $this->assertValidation("#/\xE3\x91\x94", '#/%E3%91%94');
}

-(void) test_validate_path_empty
{
    $this->assertValidation('http://google.com');
}
*/
@end
