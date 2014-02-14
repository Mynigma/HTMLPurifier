//
//   HTMLPurifier_URISchemeTest.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 20.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_URIScheme.h"
#import "HTMLPurifier_URIHarness.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_URI.h"
#import "BasicPHP.h"

@interface HTMLPurifier_URISchemeTest : HTMLPurifier_URIHarness
{
    NSString* pngBase64;
}
@end

@implementation HTMLPurifier_URISchemeTest

- (void)setUp
{
    [super setUp];
    
    pngBase64 = @"iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9YGARc5KB0XV+IAAAAddEVYdENvbW1lbnQAQ3JlYXRlZCB3aXRoIFRoZSBHSU1Q72QlbgAAAF1JREFUGNO9zL0NglAAxPEfdLTs4BZM4DIO4C7OwQg2JoQ9LE1exdlYvBBeZ7jqch9//q1uH4TLzw4d6+ErXMMcXuHWxId3KOETnnXXV6MJpcq2MLaI97CER3N0vr4MkhoXe0rZigAAAABJRU5ErkJggg==";
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) assertValidation:(NSString*)uri expect:(NSObject*)expect_uri
{
    [self prepareURI:&uri expect:&expect_uri];
    [self.config setString:@"URI.AllowedSchemes" object:@{[(HTMLPurifier_URI*)uri scheme]:@YES}];
    
    // convenience hack: the scheme should be explicitly specified
    HTMLPurifier_URIScheme* scheme = [(HTMLPurifier_URI*)uri getSchemeObj:self.config context:self.context];
    BOOL status = [scheme validate:(HTMLPurifier_URI*)uri config:self.config context:self.context];
    [self assertEitherFailOrIdentical:status result:uri expect:expect_uri];
}

- (void)assertEitherFailOrIdentical:(BOOL)status result:(NSObject*)result expect:(NSObject*)expect
{
    if ([expect isKindOfClass:[NSNumber class]] && [(NSNumber*)expect boolValue] == NO)
    {
        XCTAssertFalse(status, @"Expected false result, got true");
    }
    else
    {
        XCTAssertTrue(status, @"Expected true result, got false");
        XCTAssertEqualObjects(result,expect, @"Expected status %@ to be equal to %@", result, expect);
    }
}

-(void) test_http_regular
{
    [self assertValidation:@"http://example.com/?s=q#fragment" expect:@YES];
}

-(void) test_http_uppercase
{
    [self assertValidation:@"http://example.com/FOO" expect:@YES];
}

-(void) test_http_removeDefaultPort
{
    [self assertValidation:@"http://example.com:80" expect:@"http://example.com"];
}

-(void) test_http_removeUserInfo
{
    [self assertValidation:@"http://bob@example.com" expect:@"http://example.com"];
}

-(void) test_http_preserveNonDefaultPort
{
    [self assertValidation:@"http://example.com:8080" expect:@YES];
}

-(void) test_https_regular
{
    [self assertValidation:@"https://user@example.com:443/?s=q#frag" expect:@"https://example.com/?s=q#frag"];
}

-(void) test_ftp_regular
{
    [self assertValidation:@"ftp://user@example.com/path" expect:@YES];
}

-(void) test_ftp_removeDefaultPort
{
    [self assertValidation:@"ftp://example.com:21" expect:@"ftp://example.com"];
}

-(void) test_ftp_removeQueryString
{
    [self assertValidation:@"ftp://example.com?s=q" expect:@"ftp://example.com"];
}

-(void) test_ftp_preserveValidTypecode
{
    [self assertValidation:@"ftp://example.com/file.txt;type=a" expect:@YES];
}

-(void) test_ftp_removeInvalidTypecode
{
    [self assertValidation:@"ftp://example.com/file.txt;type=z" expect:@"ftp://example.com/file.txt"];
}

-(void) test_ftp_encodeExtraSemicolons
{
    [self assertValidation:@"ftp://example.com/too;many;semicolons=1" expect:@"ftp://example.com/too%3Bmany%3Bsemicolons=1"];
}

-(void) test_news_regular
{
    [self assertValidation:@"news:gmane.science.linguistics" expect:@YES];
}

-(void) test_news_explicit
{
    [self assertValidation:@"news:642@eagle.ATT.COM" expect:@YES];
}

-(void) test_news_removeNonPathComponents
{
    [self assertValidation:@"news://user@example.com:80/rec.music?path=foo#frag" expect:@"news:/rec.music#frag"];
}

-(void) test_nntp_regular
{
    [self assertValidation:@"nntp://news.example.com/alt.misc/42#frag" expect:@YES];
}

-(void) test_nntp_removalOfRedundantOrUselessComponents
{
    [self assertValidation:@"nntp://user@news.example.com:119/alt.misc/42?s=q#frag" expect:@"nntp://news.example.com/alt.misc/42#frag"];
}

-(void) test_mailto_regular
{
    [self assertValidation:@"mailto:bob@example.com" expect:@YES];
}

-(void) test_mailto_removalOfRedundantOrUselessComponents
{
    [self assertValidation:@"mailto://user@example.com:80/bob@example.com?subject=Foo#frag" expect:@"mailto:bob@example.com?subject=Foo#frag"];
}

-(void) test_data_png
{
    [self assertValidation:[@"data:image/png;base64," stringByAppendingString:pngBase64] expect:@YES];
}

-(void) test_data_malformed
{
    [self assertValidation:@"data:image/png;base64,vr4MkhoXJRU5ErkJggg==" expect:@NO];
}

-(void) test_data_implicit
{
    [self assertValidation:[@"data:base64," stringByAppendingString:pngBase64] expect:[@"data:image/png;base64," stringByAppendingString:pngBase64]];
}

-(void) test_file_basic
{
    [self assertValidation:@"file://user@MYCOMPUTER:12/foo/bar?baz#frag" expect:@"file://MYCOMPUTER/foo/bar#frag"];
}

-(void) test_file_local
{
    [self assertValidation:@"file:///foo/bar?baz#frag" expect:@"file:///foo/bar#frag"];
}

-(void) test_ftp_empty_host
{
    [self assertValidation:@"ftp:///example.com" expect:@NO];
}

-(void) test_cid_valid
{
    [self assertValidation:@"cid:foo.foo1@bar.net" expect:@YES];
}

-(void) test_cid_invalid
{
    [self assertValidation:@"cid:http://test.html" expect:@NO];
}

@end
