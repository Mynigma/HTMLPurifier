//
//  HTMLPurifier_URIFilter_DisableExternalResourcesTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 20.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_URIFilter_DisableExternalResources.h"
#import "HTMLPurifier_URIFilterHarness.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_URI.h"

@interface HTMLPurifier_URIFilter_DisableExternalResourcesTest : HTMLPurifier_URIFilterHarness

@end

@implementation HTMLPurifier_URIFilter_DisableExternalResourcesTest

- (void)setUp
{
    [super setUp];
    self.filter = [HTMLPurifier_URIFilter_DisableExternalResources new];
    [self.context registerWithName:@"EmbeddedURI" ref:@YES];
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
    
    [self assertEitherFailOrIdentical:result result:uri expect:expect_uri];
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

-(void) testPreserveWhenNotEmbedded
{
    [self.context destroy:@"EmbeddedURI"]; // undo setUp
    [self assertFiltering:@"http://example.com" expect:@YES];
}

@end
