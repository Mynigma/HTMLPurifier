//
//  HTMLPurifier_URIDefinitionTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 20.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_URIDefinition.h"
#import "HTMLPurifier_URIHarness.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_URI.h"
#import "BasicPHP.h"

#import "HTMLPurifier_URIFilter_HostBlacklist.h"
#import "HTMLPurifier_URIFilter_DisableResources.h"


@interface HTMLPurifier_URIDefinitionTest : HTMLPurifier_URIHarness
{
    HTMLPurifier_URIDefinition* def;
}
@end

@implementation HTMLPurifier_URIDefinitionTest

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

-(void) test_filter
{
    def = [HTMLPurifier_URIDefinition new];
    // Hardwired a filter =/
    [def addFilter:[HTMLPurifier_URIFilter_HostBlacklist new] config:self.config];
    [def addFilter:[HTMLPurifier_URIFilter_DisableResources new] config:self.config];
    HTMLPurifier_URI* uri = [self createURI:@"test"];
    XCTAssertTrue([def filter:&uri config:self.config context:self.context]);
}

/*
-(void) test_filter_earlyAbortIfFail
{
    
    def = [HTMLPurifier_URIDefinition new];
    $def->addFilter($this->createFilterMock(true, false), $this->config);
    $def->addFilter($this->createFilterMock(false), $this->config); // never called
    HTMLPurifier_URI* uri = [self createURI:@"test"];
    XCTAssertFalse([def filter:uri config:self.config context:self.context]);
}
 */

-(void) test_setupMemberVariables_collisionPrecedenceIsHostBaseScheme
{
    [self.config setString:@"URI.Host" object:@"example.com"];
    [self.config setString:@"URI.Base" object:@"http://sub.example.com/foo/bar.html"];
    [self.config setString:@"URI.DefaultScheme" object:@"ftp"];
    def = [HTMLPurifier_URIDefinition new];
    [def setup:self.config];
    XCTAssertEqualObjects([def host], @"example.com",@"");
    XCTAssertEqualObjects([[def base] toString], @"http://sub.example.com/foo/bar.html");
    XCTAssertEqualObjects([def defaultScheme], @"http"); // not ftp!
}

-(void) test_setupMemberVariables_onlyScheme
{
    [self.config setString:@"URI.DefaultScheme" object:@"ftp"];
    def = [HTMLPurifier_URIDefinition new];
    [def setup:self.config];
    XCTAssertEqualObjects([def defaultScheme], @"ftp",@"");
}

-(void) test_setupMemberVariables_onlyBase
{
    [self.config setString:@"URI.Base" object:@"http://sub.example.com/foo/bar.html"];
    def = [HTMLPurifier_URIDefinition new];
    [def setup:self.config];
    XCTAssertEqualObjects([def host], @"sub.example.com", @"");
}

@end
