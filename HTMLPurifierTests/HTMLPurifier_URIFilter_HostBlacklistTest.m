//
//  HTMLPurifier_URIFilter_HostBlacklistTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 20.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_URIFilter_HostBlacklist.h"
#import "HTMLPurifier_URIFilterHarness.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_URI.h"

@interface HTMLPurifier_URIFilter_HostBlacklistTest : HTMLPurifier_URIFilterHarness

@end

@implementation HTMLPurifier_URIFilter_HostBlacklistTest

- (void)setUp
{
    [super setUp];
    self.filter = [HTMLPurifier_URIFilter_HostBlacklist new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
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


-(void) testRejectBlacklistedHost
{
    [self.config setString:@"URI.HostBlacklist" object:@"example.com"];
    [self assertFiltering:@"http://example.com" expect:@NO];
}

-(void) testRejectBlacklistedHostThoughNotTrue
{
    // maybe this behavior should change
    [self.config setString:@"URI.HostBlacklist" object:@"example.com"];
    [self assertFiltering:@"http://example.comcast.com" expect:@NO];
}

-(void) testPreserveNonBlacklistedHost
{
    [self.config setString:@"URI.HostBlacklist" object:@"example.com"];
    [self assertFiltering:@"http://google.com" expect:@YES];
}
@end
