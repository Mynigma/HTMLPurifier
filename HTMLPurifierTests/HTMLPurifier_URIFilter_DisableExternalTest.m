//
//  HTMLPurifier_URIFilter_DisableExternalTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 20.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_URIFilterHarness.h"
#import "HTMLPurifier_URIFilter_DisableExternal.h"
#import "HTMLPurifier_URIFilter.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_URI.h"

@interface HTMLPurifier_URIFilter_DisableExternalTest : HTMLPurifier_URIFilterHarness

@end

@implementation HTMLPurifier_URIFilter_DisableExternalTest

- (void)setUp
{
    [super setUp];
    self.filter = [HTMLPurifier_URIFilter_DisableExternal new];
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
-(void) testRemoveExternal
{
    [self assertFiltering:@"http://example.com" expect:@NO];
}

-(void) testPreserveInternal
{
    [self assertFiltering:@"/foo/bar" expect:@YES];
}


-(void) disabled_testPreserveOurHost
{
    [self.config setString:@"URI.Host" object:@"example.com"];
    [self assertFiltering:@"http://example.com" expect:@YES];
}

-(void) disabled_testPreserveOurSubdomain
{
    [self.config setString:@"URI.Host" object:@"example.com"];
    [self assertFiltering:@"http://www.example.com" expect:@YES];
}

-(void) testRemoveSuperdomain
{
    [self.config setString:@"URI.Host" object:@"www.example.com"];
    [self assertFiltering:@"http://example.com" expect:@NO];

}

-(void) disabled_BaseAsHost
{
    [self.config setString:@"URI.Base" object:@"http://www.example.com/foo/bar"];
    [self assertFiltering:@"http://www.example.com/baz" expect:@YES];
}



@end
