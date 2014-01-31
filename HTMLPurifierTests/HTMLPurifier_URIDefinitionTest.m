//
//  HTMLPurifier_URIDefinitionTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 20.01.14.


#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

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


- (HTMLPurifier_URIFilter*)createFilterMockWithURI:(HTMLPurifier_URI*)uri
{
    return [self createFilterMockWithExpect:YES result:YES port:NO setup:YES uri:uri];
}

static NSInteger i = 0;

- (HTMLPurifier_URIFilter*)createFilterMockWithExpect:(BOOL)expect result:(BOOL)result port:(BOOL)post setup:(BOOL)setup uri:(HTMLPurifier_URI*)uri
{
    id filterMock = [OCMockObject mockForClass:[HTMLPurifier_URIFilter class]];

    if(expect)
        [[[filterMock expect] andReturnValue:@(result)] filter:(HTMLPurifier_URI __autoreleasing **)[OCMArg anyPointer] config:self.config context:self.context];
    else
        [[filterMock reject] filter:&uri config:self.config context:self.context];

    [[[filterMock stub] andReturnValue:@(setup)] prepare:self.config];

    NSString* uniqueName = [NSString stringWithFormat:@"%ld", (long)i++];
    [[[filterMock stub] andReturn:uniqueName] name];
    [[[filterMock stub] andReturnValue:@(post)] post];
    return filterMock;
}

-(void) test_filter
{
    def = [HTMLPurifier_URIDefinition new];

    HTMLPurifier_URI* uri = [self createURI:@"test"];

    id filter1 = [self createFilterMockWithURI:uri];
    id filter2 = [self createFilterMockWithURI:uri];

    [def addFilter:filter1 config:self.config];
    [def addFilter:filter2 config:self.config];

    BOOL result = [def filter:&uri config:self.config context:self.context];

    [filter1 verify];
    [filter2 verify];

    XCTAssertTrue(result);
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
