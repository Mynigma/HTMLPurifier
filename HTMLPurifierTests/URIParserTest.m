//
//  URIParserTest.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_URIParser.h"
#import "HTMLPurifier_URI.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"


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

- (void) assertParsing:(NSString*)uri scheme:(NSString*)scheme userinfo:(NSString*)userinfo host:(NSString*)host port:(NSNumber*)port path:(NSString*)path query:(NSString*)query fragment:(NSString*)fragment config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
        [self prepareCommon:&config context:context];
        HTMLPurifier_URIParser* parser = [HTMLPurifier_URIParser new];
        NSObject* result = [parser parse:uri];
        NSObject* expect = [[HTMLPurifier_URI alloc] initWithScheme:scheme userinfo:userinfo host:host port:port path:path query:query fragment:fragment];

    [self assertEqual:result to:expect];
}

- (void) assertParsing:(NSString*)uri scheme:(NSString*)scheme userinfo:(NSString*)userinfo host:(NSString*)host port:(NSNumber*)port path:(NSString*)path query:(NSString*)query fragment:(NSString*)fragment
{
    [self assertParsing:uri scheme:scheme userinfo:userinfo host:host port:port path:path query:query fragment:fragment config:nil context:nil];
}


- (void)testPercentNormalization
{
    [self assertParsing:@"%G" scheme:nil userinfo:nil host:nil port:nil path:@"%25G" query:nil fragment:nil];
}

- (void)testRegular
{
    [self assertParsing:@"http://www.example.com/webhp?q=foo#result2" scheme:@"http" userinfo:nil host:@"www.example.com" port:nil path:@"/webhp" query:@"q=foo" fragment:@"result2"];
    }

- (void)testPortAndUsername
{
    [self assertParsing:@"http://user@authority.part:80/now/the/path?query#fragment" scheme:@"http" userinfo:@"user" host:@"authority.part" port:@80 path:@"/now/the/path" query:@"query" fragment:@"fragment"];
    }

- (void)testPercentEncoding
{
    [self assertParsing:@"http://en.wikipedia.org/wiki/Clich%C3%A9" scheme:@"http" userinfo:nil host:@"en.wikipedia.org" port:nil path:@"/wiki/Clich%C3%A9" query:nil fragment:nil];
    }


- (void)testEmptyQuery
{
    [self assertParsing:@"http://www.example.com/?#" scheme:@"http" userinfo:nil host:@"www.example.com" port:nil path:@"/" query:@"" fragment:@""];
}

- (void)testEmptyPath
{
    [self assertParsing:@"http://www.example.com" scheme:@"http" userinfo:nil host:@"www.example.com" port:nil path:@"" query:nil fragment:nil];
}

- (void)testOpaqueURI
{
    [self assertParsing:@"mailto:bob@example.com" scheme:@"mailto" userinfo:nil host:nil port:nil path:@"bob@example.com" query:nil fragment:nil];
}

- (void)testIPv4Address
{
    [self assertParsing:@"http://192.0.34.166/" scheme:@"http" userinfo:nil host:@"192.0.34.166" port:nil path:@"/" query:nil fragment:nil];
}

- (void)testFakeIPv4Address
{
    [self assertParsing:@"http://333.123.32.123/" scheme:@"http" userinfo:nil host:@"333.123.32.123" port:nil path:@"/" query:nil fragment:nil];
}

- (void)testIPv6Address
{
        [self assertParsing:@"http://[2001:db8::7]/c=GB?objectClass?one" scheme:@"http" userinfo:nil host:@"[2001:db8::7]" port:nil path:@"/c=GB" query:@"objectClass?one" fragment:nil];
}

- (void)testInternationalizedDomainName
{
    [self assertParsing:@"http://t\\xC5\\xABdali\\xC5\\x86.lv" scheme:@"http" userinfo:nil host:@"t\\xC5\\xABdali\\xC5\\x86.lv" port:nil path:@"" query:nil fragment:nil];
    }

- (void)testInvalidPort
{
    [self assertParsing:@"http://example.com:foobar" scheme:@"http" userinfo:nil host:@"example.com" port:nil path:@"" query:nil fragment:nil];
}

- (void)testPathAbsolute
{
    [self assertParsing:@"http:/this/is/path" scheme:@"http" userinfo:nil host:nil port:nil path:@"/this/is/path" query:nil fragment:nil];
}

- (void)testPathRootless
{
        // this should not be used but is allowed
        [self assertParsing:@"http:this/is/path" scheme:@"http" userinfo:nil host:nil port:nil path:@"this/is/path" query:nil fragment:nil];
    }
    
- (void)testPathEmpty
{
        [self assertParsing:@"http://t\\xC5\\xABdali\\xC5\\x86.lv" scheme:@"http" userinfo:nil host:@"t\\xC5\\xABdali\\xC5\\x86.lv" port:nil path:@"" query:nil fragment:nil];
     }
    
    - (void) testRelativeURI {
        [self assertParsing:@"/a/b" scheme:nil userinfo:nil host:nil port:nil path:@"/a/b" query:nil fragment:nil];
     }
    
    - (void) testMalformedTag {
        [self assertParsing:@"http://www.example.com/>" scheme:@"http" userinfo:nil host:@"www.example.com" port:nil path:@"/" query:nil fragment:nil];
    }
    
    - (void) testEmpty {
        [self assertParsing:@"" scheme:nil userinfo:nil host:nil port:nil path:@"" query:nil fragment:nil];
    }

@end
