//
//   HTMLPurifier_URIFilter_DisableResourcesTest.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 20.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_URIFilter_DisableResources.h"
#import "HTMLPurifier_URIFilterHarness.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_URI.h"

@interface HTMLPurifier_URIFilter_DisableResourcesTest : HTMLPurifier_URIFilterHarness

@end

@implementation HTMLPurifier_URIFilter_DisableResourcesTest

- (void)setUp
{
    [super setUp];
    self.filter = [HTMLPurifier_URIFilter_DisableResources new];
    NSNumber* var = @YES;
    [self.context registerWithName:@"EmbeddedURI" ref:var];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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

/********* Test ************/

-(void) testRemoveResource
{
    [self assertFiltering:@"/foo/bar" expect:@NO];
}

-(void) testPreserveRegular
{
    [self.context destroy:@"EmbeddedURI"]; // undo setUp
    [self assertFiltering:@"/foo/bar" expect:@YES];
}

@end
