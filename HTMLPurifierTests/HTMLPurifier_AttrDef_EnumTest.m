//
//  HTMLPurifier_AttrDef_EnumTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 22.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_Enum.h"

@interface HTMLPurifier_AttrDef_EnumTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_AttrDef_Enum* def;
}
@end

@implementation HTMLPurifier_AttrDef_EnumTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) assertDef:(NSString*) string expect:(NSObject*)expect
{
    // expect can be a string or bool
    if ([expect isEqual:@YES])
        expect = string;
        
    NSString* result = [def validateWithString:string config:[super config] context:[super context]];
    XCTAssertEqualObjects(expect, result, @"");
}

-(void) testCaseInsensitive
{
    def = [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"one",@"two"]];
    [self assertDef:@"one" expect:@YES];
    [self assertDef:@"ONE" expect:@"one"];
}

-(void) testCaseSensitive
{
    def = [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"one",@"two"] caseSensitive:YES];
    [self assertDef:@"one" expect:@YES];
    [self assertDef:@"ONE" expect:nil];
}

-(void) testFixing
{
    def = [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"one"]];
    [self assertDef:@" one " expect:@"one"];
}

-(void) test_make
{
    HTMLPurifier_AttrDef_Enum* factory = [HTMLPurifier_AttrDef_Enum new];
    
    def = [factory make:@"foo,bar"];
    HTMLPurifier_AttrDef_Enum* def2 = [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"foo",@"bar"]];
    XCTAssertEqualObjects(def, def2);
    
    def = [factory make:@"s:foo,BAR"];
    def2 = [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"foo",@"BAR"] caseSensitive:YES];
    XCTAssertEqualObjects(def, def2);
}


@end
