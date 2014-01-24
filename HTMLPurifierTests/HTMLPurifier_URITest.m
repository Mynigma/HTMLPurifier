//
//  HTMLPurifier_URITest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 21.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "HTMLPurifier_URIDefinition.h"
#import "HTMLPurifier_URIHarness.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_URI.h"
#import "HTMLPurifier_URISchemeRegistry.h"
#import "HTMLPurifier_URIScheme.h"
#import "HTMLPurifier_URIScheme_http.h"
#import "HTMLPurifier_URIParser.h"
#import "HTMLPurifier_URIScheme_mailto.h"

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
    XCTAssertEqualObjects(uri1, uri2);
}


-(HTMLPurifier_URISchemeRegistry*) setUpSchemeRegistryMock
{
    oldRegistry = [HTMLPurifier_URISchemeRegistry instance:nil];
    
    //generate_mock_once('HTMLPurifier_URIScheme');
    //generate_mock_once('HTMLPurifier_URISchemeRegistry');
    id registrySchemeMock = [OCMockObject mockForClass:[HTMLPurifier_URISchemeRegistry class]];

    HTMLPurifier_URISchemeRegistry * registry = [HTMLPurifier_URISchemeRegistry instance:registrySchemeMock];
    return registry;
}


-(void) getSchemeObj
{
    HTMLPurifier_URIScheme* scheme_mock = [HTMLPurifier_URIScheme_http new];

    HTMLPurifier_URI* uri = [self createURI:@"http:"];
    HTMLPurifier_URIScheme* scheme_obj = [uri getSchemeObj:self.config context:self.context];
    XCTAssertEqualObjects(scheme_obj, scheme_mock);
}

- (HTMLPurifier_URIScheme*)setUpSchemeMock:(NSString*)name
{
    id registryMock = [self setUpSchemeRegistryMock];
    id schemeMock = [OCMockObject partialMockForObject:[[HTMLPurifier_URIScheme alloc] init]];
    [[[registryMock stub] andReturn:schemeMock] getScheme:name config:[OCMArg any] context:[OCMArg any]];
    return schemeMock;
}

- (void)setUpNoValidSchemes
{
    id registryMock = [self setUpSchemeRegistryMock];
    [[[registryMock stub] andReturn:nil] getScheme:[OCMArg any] config:[OCMArg any] context:[OCMArg any]];
}

- (void)tearDownSchemeRegistryMock
{
    [HTMLPurifier_URISchemeRegistry instance:oldRegistry];
}


- (void)test_getSchemeObj
{
    id scheme_mock = [self setUpSchemeMock:@"http"];

    HTMLPurifier_URI* uri = [self createURI:@"http:"];
    HTMLPurifier_URIScheme* scheme_obj = [uri getSchemeObj:self.config context:self.context];
    [self assertIdentical:scheme_obj to:scheme_mock];

    [self tearDownSchemeRegistryMock];
}

-(void) test_getSchemeObj_invalidScheme
{
    HTMLPurifier_URI* uri = [self createURI:@"hffp:"];
    HTMLPurifier_URIScheme* result = [uri getSchemeObj:self.config context:self.context];
    XCTAssertNil(result);
}


-(void) disabled_test_getSchemaObj_defaultScheme
{
    NSString* scheme = @"foobar";
    
    // randomly chosen
    HTMLPurifier_URIScheme* scheme_mock = [HTMLPurifier_URIScheme_mailto new];
    
    [self.config setString:@"URI.DefaultScheme" object:scheme];
    
    HTMLPurifier_URI* uri = [self createURI:@"hmm"];
    
    HTMLPurifier_URIScheme* scheme_obj = [uri getSchemeObj:self.config context:self.context];
    
    XCTAssertEqualObjects(scheme_obj, scheme_mock);
}


-(void) disabled_test_getSchemaObj_invalidDefaultScheme
{
    [self.config setString:@"URI.DefaultScheme" object:@"foobar"];
    
    HTMLPurifier_URI* uri = [self createURI:@"hmm"];
    
    // error? //
    
    HTMLPurifier_URIScheme* result = [uri getSchemeObj:self.config context:self.context];
    
    XCTAssertNil(result);
}


-(void) assertToString:(NSString*)expect_uri scheme:(NSString*)scheme userinfo:(NSString*)userinfo host:(NSString*)host port:(NSNumber*)port path:(NSString*)path query:(NSString*)query fragment:(NSString*)fragment
{
    HTMLPurifier_URI* uri = [[HTMLPurifier_URI alloc] initWithScheme:scheme userinfo:userinfo host:host port:port path:path query:query fragment:fragment];
    NSString* string = uri.toString;
    XCTAssertEqualObjects(string, expect_uri, @"");
}


-(void) test_toString_full
{
    [self assertToString:@"http://bob@example.com:300/foo?bar=baz#fragment" scheme:@"http" userinfo:@"bob" host:@"example.com" port:@300 path:@"/foo" query:@"bar=baz" fragment:@"fragment"];
}

-(void) test_toString_scheme
{
    [self assertToString:@"http:" scheme:@"http" userinfo:nil host:nil port:nil path:@"" query:nil fragment:nil];
}

-(void) test_toString_authority
{
    [self assertToString:@"//bob@example.com:8080" scheme:nil userinfo:@"bob" host:@"example.com" port:@8080 path:@"" query:nil fragment:nil];

}

-(void) test_toString_path
{
    [self assertToString:@"/path/to" scheme:nil userinfo:nil host:nil port:nil path:@"/path/to" query:nil fragment:nil];
}

-(void) test_toString_query
{
    [self assertToString:@"?q=string" scheme:nil userinfo:nil host:nil port:nil path:@"" query:@"q=string" fragment:nil];
}

-(void) test_toString_fragment
{
    [self assertToString:@"#fragment" scheme:nil userinfo:nil host:nil port:nil path:@"" query:nil fragment:@"fragment"];
}

- (void)assertValidation:(NSString*)uri
{
    [self assertValidation:uri expectUri:@YES];
}

- (void)assertValidation:(NSString*)uri expectUri:(NSObject*)expect_uri
{
    if ([expect_uri isEqual:@YES])
        expect_uri = uri;
    HTMLPurifier_URI* newURI = [self createURI:uri];
    BOOL result = [newURI validateWithConfig:[self config] context:[self context]];
    if ([expect_uri isEqual:@NO])
    {
        XCTAssertFalse(result);
    } else {
        XCTAssertTrue(result);
        XCTAssertEqualObjects([newURI toString], expect_uri);
    }
}

-(void) test_validate_overlongPort
{
    [self assertValidation:@"http://example.com:65536" expectUri:@"http://example.com"];
}

-(void) test_validate_zeroPort
{
    [self assertValidation:@"http://example.com:00" expectUri:@"http://example.com"];
}

-(void) test_validate_invalidHostThatLooksLikeIPv6
{
    [self assertValidation:@"http://[2001:0db8:85z3:08d3:1319:8a2e:0370:7334]" expectUri:@""];
}

-(void) test_validate_removeRedundantScheme
{
    [self assertValidation:@"http:foo:/:" expectUri:@"foo%3A/:"];
}

-(void) test_validate_username
{
    [self assertValidation:@"http://user\xE3\x91\x94:@foo.com" expectUri:@"http://user%E3%91%94:@foo.com"];
}

-(void) test_validate_path_abempty
{
    [self assertValidation:@"http://host/\xE3\x91\x94:" expectUri:@"http://host/%E3%91%94:"];
}

-(void) test_validate_path_absolute
{
    [self assertValidation:@"/\xE3\x91\x94:" expectUri:@"/%E3%91%94:"];
}

-(void) test_validate_path_rootless
{
    [self assertValidation:@"mailto:\xE3\x91\x94:" expectUri:@"mailto:%E3%91%94:"];
}

-(void) test_validate_path_noscheme
{
    [self assertValidation:@"\xE3\x91\x94" expectUri:@"%E3%91%94"];
}

-(void) test_validate_query
{
    [self assertValidation:@"?/\xE3\x91\x94" expectUri:@"?/%E3%91%94"];
}

-(void) test_validate_fragment
{
    [self assertValidation:@"#/\xE3\x91\x94" expectUri:@"#/%E3%91%94"];
}

-(void) test_validate_path_empty
{
    [self assertValidation:@"http://google.com"];
}


@end
