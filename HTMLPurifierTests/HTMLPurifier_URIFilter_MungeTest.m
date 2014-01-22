//
//  HTMLPurifier_URIFilter_MungeTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 20.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_URIFilter_Munge.h"
#import "HTMLPurifier_URIFilterHarness.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_URI.h"
#import "HTMLPurifier_Token_Start.h"

@interface HTMLPurifier_URIFilter_MungeTest : HTMLPurifier_URIFilterHarness

@end

@implementation HTMLPurifier_URIFilter_MungeTest

- (void)setUp
{
    [super setUp];
    self.filter = [HTMLPurifier_URIFilter_Munge new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) setMunge:(NSString*)munge
{
    if (!munge){
        [self.config setString:@"URI.Munge" object:@"http://www.google.com/url?q=%s"];
        return;
    }
        
    [self.config setString:@"URI.Munge" object:munge];
}

-(BOOL) setSecureMunge:(NSString*)key // 'secret')
{
    [self setMunge:@"/redirect.php?url=%s&checksum=%t"];
    if (!key) {
        [self.config setString:@"URI.MungeSecretKey" object:@"secret"];
        return YES;
    }
    [self.config setString:@"URI.MungeSecretKey" object:key];
    return YES;
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

-(void) testMunge
{
    [self setMunge:nil];
    [self assertFiltering:@"http://www.example.com/" expect:@"http://www.google.com/url?q=http%3A%2F%2Fwww.example.com%2F"];
}

-(void) testMungeReplaceTagName
{
    [self setMunge:@"/r?tagname=%n&url=%s"];
    HTMLPurifier_Token_Start* token = [[HTMLPurifier_Token_Start alloc] initWithName:@"a"];
    [self.context registerWithName:@"CurrentToken" ref:token];
    [self assertFiltering:@"http://google.com" expect:@"/r?tagname=a&url=http%3A%2F%2Fgoogle.com"];
}

-(void) testMungeReplaceAttribute
{
    [self setMunge:@"/r?attr=%m&url=%s"];
    NSString* attr = @"href";
    [self.context registerWithName:@"CurrentAttr" ref:attr];
    [self assertFiltering:@"http://google.com" expect:@"/r?attr=href&url=http%3A%2F%2Fgoogle.com"];
}

-(void) testMungeReplaceResource
{
    [self setMunge:@"/r?embeds=%r&url=%s"];
    NSNumber* embeds = @NO;
    [self.context registerWithName:@"EmbeddedURI" ref:embeds];
    [self assertFiltering:@"http://google.com" expect:@"/r?embeds=&url=http%3A%2F%2Fgoogle.com"];
}

-(void) testMungeReplaceCSSProperty
{
    [self setMunge:@"/r?property=%p&url=%s"];
    NSString* property = @"background";
    [self.context registerWithName:@"CurrentCSSProperty" ref:property];
    [self assertFiltering:@"http://google.com" expect:@"/r?property=background&url=http%3A%2F%2Fgoogle.com"];
}

-(void) testIgnoreEmbedded
{
    [self setMunge:nil];
    NSNumber* embeds = @YES;
    [self.context registerWithName:@"EmbeddedURI" ref:embeds];
    [self assertFiltering:@"http://example.com" expect:@YES];
}

-(void) disabled_testProcessEmbedded
{
    [self setMunge:nil];
    [self.config setString:@"URI.MungeResources" object:@YES];
    NSNumber* embeds = @YES;
    [self.context registerWithName:@"EmbeddedURI" ref:embeds];
    [self assertFiltering:@"http://www.example.com/"
                   expect:@"http://www.google.com/url?q=http%3A%2F%2Fwww.example.com%2F"];
}

-(void) testPreserveRelative
{
    [self setMunge:nil];
    [self assertFiltering:@"index.html" expect:@YES];
}

-(void) testMungeIgnoreUnknownSchemes
{
    [self setMunge:nil];
    [self assertFiltering:@"javascript:foobar;" expect:@YES];
}

-(void) testSecureMungePreserve
{
    if (![self setSecureMunge:nil]) return;
    [self assertFiltering:@"/local" expect:@YES];
}

-(void) testSecureMungePreserveEmbedded
{
    if (![self setSecureMunge:nil]) return;
    NSNumber* embedded = @YES;
    [self.context registerWithName:@"EmbeddedURI" ref:embedded];
    [self assertFiltering:@"http://google.com" expect:@YES];
}

-(void) testSecureMungeStandard
{
    if (![self setSecureMunge:nil])
        return;
    [self assertFiltering:@"http://google.com" expect:@"/redirect.php?url=http%3A%2F%2Fgoogle.com&checksum=46267a796aca0ea5839f24c4c97ad2648373a4eca31b1c0d1fa7c7ff26798f79"];
}

-(void) testSecureMungeIgnoreUnknownSchemes
{
    // This should be integration tested as well to be false
    if (![self setSecureMunge:nil]) return;
    [self assertFiltering:@"javascript:" expect:@YES];
}

-(void) testSecureMungeIgnoreUnbrowsableSchemes
{
    if (![self setSecureMunge:nil]) return;
    [self assertFiltering:@"news:" expect:@YES];
}

-(void) testSecureMungeToDirectory
{
    if (![self setSecureMunge:nil]) return;
    [self setMunge:@"/links/%s/%t"];
    [self assertFiltering:@"http://google.com" expect:@"/links/http%3A%2F%2Fgoogle.com/46267a796aca0ea5839f24c4c97ad2648373a4eca31b1c0d1fa7c7ff26798f79"];
}

-(void) testMungeIgnoreSameDomain
{
    [self setMunge:@"http://example.com/%s"];
    [self assertFiltering:@"http://example.com/foobar" expect:@YES];
}

-(void) testMungeIgnoreSameDomainInsecureToSecure
{
    [self setMunge:@"http://example.com/%s"];
    [self assertFiltering:@"https://example.com/foobar" expect:@YES];
}

-(void) disabled_testMungeIgnoreSameDomainSecureToSecure
{
    [self.config setString:@"URI.Base" object:@"https://example.com"];
    [self setMunge:@"http://example.com/%s"];
    [self assertFiltering:@"https://example.com/foobar" expect: @YES];
}

-(void) disabled_testMungeSameDomainSecureToInsecure
{
    [self.config setString:@"URI.Base" object:@"https://example.com"];
    [self setMunge:@"/%s"];
    [self assertFiltering:@"http://example.com/foobar" expect:@"/http%3A%2F%2Fexample.com%2Ffoobar"];
}

-(void) disabled_testMungeIgnoresSourceHost
{
    [self.config setString:@"URI.Host" object:@"foo.example.com"];
    [self setMunge:@"http://example.com/%s"];
    [self assertFiltering:@"http://foo.example.com/bar" expect:@YES];
}

@end
