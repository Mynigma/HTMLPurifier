//
//  HTMLPurifier_AttrDef_URITest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_URI.h"
#import "HTMLPurifier_URIParser.h"

@interface HTMLPurifier_AttrDef_URITest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_Config* config;
    HTMLPurifier_Context* context;
    HTMLPurifier_AttrDef_URI* def;
}

@end

@implementation HTMLPurifier_AttrDef_URITest

- (void)setUp
{
    [super setUp];
    config = [HTMLPurifier_Config createDefault];
    context = [HTMLPurifier_Context new];
    def = [HTMLPurifier_AttrDef_URI new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) assertDef:(NSString*) string expect:(NSString*)expect
{
    // $expect can be a string or bool
    NSString* result = [def validateWithString:string config:config context:context];
    
    XCTAssertEqualObjects(expect, result, @"");
}

- (void) testIntegration
{
    [self assertDef:@"http://www.google.com/" expect:@"http://www.google.com/"];
    [self assertDef:@"http:" expect:@""];
    [self assertDef:@"http:/foo" expect:@"/foo"];
    [self assertDef:@"javascript:bad_stuff();" expect:nil];
    [self assertDef:@"ftp://www.example.com/" expect:@"ftp://www.example.com/"];
    [self assertDef:@"news:rec.alt" expect:@"news:rec.alt"];
    [self assertDef:@"nntp://news.example.com/324234" expect:@"nntp://news.example.com/324234"];
    [self assertDef:@"mailto:bob@example.com" expect:@"mailto:bob@example.com"];
}

- (void) testIntegrationWithPercentEncoder
{
    [self assertDef:@"http://www.example.com/%56%fc%GJ%5%FC" expect:@"http://www.example.com/V%FC%25GJ%255%FC"];
}

- (void) testPercentEncoding
{
    [self assertDef:@"http:colon:mercenary" expect:@"colon%3Amercenary"];
}

- (void) testPercentEncodingPreserve
{
    [self assertDef:@"http://www.example.com/abcABC123-_.!~*()'" expect:@"http://www.example.com/abcABC123-_.!~*()'"];
}

- (void) testEmbeds
{
    def = [[HTMLPurifier_AttrDef_URI alloc] initWithNumber:@YES];
    [self assertDef:@"http://sub.example.com/alas?foo=asd" expect:@"http://sub.example.com/alas?foo=asd"];
    [self assertDef:@"mailto:foo@example.com" expect:nil];
}

/*
- (void) testConfigMunge
{
    [config setString:@"URI.Munge" object:@"http://www.google.com/url?q=%s"];
    [self assertDef:@"http://www.example.com/" expect:@"http://www.google.com/url?q=http%3A%2F%2Fwww.example.com%2F"];
    
    [self assertDef:@"index.html" expect:@"index.html"];
    [self assertDef:@"javascript:foobar();" expect:nil];
}*/

- (void) testDefaultSchemeRemovedInBlank
{
    [self assertDef:@"http:" expect:@""];
}

- (void) testDefaultSchemeRemovedInRelativeURI
{
    [self assertDef:@"http:/foo/bar" expect:@"/foo/bar"];
}

- (void) testDefaultSchemeNotRemovedInAbsoluteURI
{
    [self assertDef:@"http://example.com/foo/bar" expect:@"http://example.com/foo/bar"];
}

- (void) testAltSchemeNotRemoved
{
    [self assertDef:@"mailto:this-looks-like-a-path@example.com" expect:@"mailto:this-looks-like-a-path@example.com"];
}

- (void) testResolveNullSchemeAmbiguity
{
    [self assertDef:@"///foo" expect:@"/foo"];
}

- (void) testResolveNullSchemeDoubleAmbiguity
{
    [config setString:@"URI.Host" object:@"example.com"];
    [self assertDef:@"////foo" expect:@"//example.com//foo"];
}

/*** WTF
- (void) testURIDefinitionValidation
{
    HTMLPurifier_URIParser* parser = [HTMLPurifier_URIParser new];
    HTMLPurifier_URI* uri = [parser parse:@"http://example.com"];
    [config setString:@"URI.DefinitionID" object: @"HTMLPurifier_AttrDef_URITest->testURIDefinitionValidation"];
    
    generate_mock_once :@"HTMLPurifier_URIDefinition";
    HTMLPurifier_URIDefinitionMock* uri_def = [HTMLPurifier_URIDefinitionMock new];
    uri_def expectOnce:@"filter', array($uri, '*" expect:@"*'));
    uri_def->setReturnValue:@"filter', true, array($uri, '*" expect:@"*'));
    $uri_def->expectOnce:@"postFilter', array($uri, '*" expect:@"*'));
    $uri_def->setReturnValue:@"postFilter', true, array($uri, '*" expect:@"*'));
    $uri_def->setup = true;
    
    // Since definitions are no longer passed by reference, we need
    // to muck around with the cache to insert our mock. This is
    // technically a little bad, since the cache shouldn't change
    // behavior, but I don't feel too good about letting users
    // overload entire definitions.
    generate_mock_once:@"HTMLPurifier_DefinitionCache"];
    $cache_mock = new HTMLPurifier_DefinitionCacheMock;
    $cache_mock->setReturnValue:@"get', $uri_def);
    
    generate_mock_once:@"HTMLPurifier_DefinitionCacheFactory"];
    $factory_mock = new HTMLPurifier_DefinitionCacheFactoryMock;
    $old = HTMLPurifier_DefinitionCacheFactory::instance;
    HTMLPurifier_DefinitionCacheFactory::instance($factory_mock);
    $factory_mock->setReturnValue:@"create', $cache_mock);
    
    [self assertDef:@"http://example.com"];
    
    HTMLPurifier_DefinitionCacheFactory::instance($old);
}  **/

- (void) test_make
{
    //pretty lame tests
    
    HTMLPurifier_AttrDef_URI* factory = [HTMLPurifier_AttrDef_URI new];
    def = [factory make:@""];
    HTMLPurifier_AttrDef_URI* def2 = [HTMLPurifier_AttrDef_URI new];
    XCTAssertEqualObjects(def.embedsResource, def2.embedsResource, @"");
    
    def = [factory make:@"embedded"];
    def2 = [[HTMLPurifier_AttrDef_URI alloc] initWithNumber:@(YES)];
    XCTAssertEqualObjects(def.embedsResource, def2.embedsResource, @"");
}

/* Was alrdy inactive!!
 
 - (void) test_validate_configWhitelist
 {
 $this ->config->set:@"URI.HostPolicy" expect:@"DenyAll"];
 $this ->config->set:@"URI.HostWhitelist', array(null, 'google.com"]);
 
 [self assertDef:@"http://example.com/fo/google.com" expect:nil];
 [self assertDef:@"server.txt"];
 [self assertDef:@"ftp://www.google.com/?t=a"];
 [self assertDef:@"http://google.com.tricky.spamsite.net" expect:nil];
 
 }
 */

@end
