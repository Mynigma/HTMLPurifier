//
//  HTMLPurifier_AttrDef_HTML_IDTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 16.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_HTML_ID.h"
#import "HTMLPurifier_IDAccumulator.h"

@interface HTMLPurifier_AttrDef_HTML_IDTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_Config* config;
    HTMLPurifier_Context* context;
    HTMLPurifier_AttrDef_HTML_ID* def;
}
@end

@implementation HTMLPurifier_AttrDef_HTML_IDTest

- (void)setUp
{
    [super setUp];

    config = [HTMLPurifier_Config createDefault];
    context = [HTMLPurifier_Context new];
    
    HTMLPurifier_IDAccumulator* id_accumulator = [HTMLPurifier_IDAccumulator new];
    [context registerWithName:@"IDAccumulator" ref:id_accumulator];
    [config setString:@"Attr.EnableID" object:@YES];
    def = [HTMLPurifier_AttrDef_HTML_ID new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) assertDef:(NSString*) string expect:(NSString*)expect
{
    // $expect can be a string or bool
    NSString* result = [def validateWithString:string config:config context:context];
    
    XCTAssertEqualObjects(expect, result, @"");
    
}


- (void)test
{
    // valid ID names
    [self assertDef:@"alpha" expect: @"alpha"];
    [self assertDef:@"al_ha" expect: @"al_ha"];
    [self assertDef:@"a0-:." expect: @"a0-:."];
    [self assertDef:@"a" expect: @"a"];
    
    // invalid ID names
    [self assertDef:@"<asa" expect: nil];
    [self assertDef:@"0123" expect: nil];
    [self assertDef:@".asa" expect: nil];
    
    // test duplicate detection
    [self assertDef:@"once" expect: @"once"];
    [self assertDef:@"once" expect: nil];
    // valid once whitespace stripped, but needs to be amended
    [self assertDef:@" whee " expect: @"whee"];
    
}

-(void) disabled_testPrefix
{
    [config setString:@"Attr.IDPrefix" object:@"user_"];
    
    [self assertDef:@"alpha" expect: @"user_alpha"];
    [self assertDef:@"<asa" expect: nil];
    [self assertDef:@"once" expect:  @"user_once"];
    [self assertDef:@"once" expect: nil];
    
    // if already prefixed, leave alone
    [self assertDef:@"user_alas" expect:@"user_alas"];
    [self assertDef:@"user_user_alas" expect: @"user_user_alas"]; // how to bypass
}

-(void) disabled_testTwoPrefixes
{
    [config setString:@"Attr.IDPrefix" object: @"user_"];
    [config setString:@"Attr.IDPrefixLocal" object: @"story95_"];
    
    [self assertDef:@"alpha" expect: @"user_story95_alpha"];
    [self assertDef:@"<asa" expect: nil];
    [self assertDef:@"once" expect: @"user_story95_once"];
    [self assertDef:@"once" expect: nil];
    
    [self assertDef:@"user_story95_alas" expect:@"user_story95_alas"];
    [self assertDef:@"user_alas" expect:  @"user_story95_user_alas"]; // !
    
}

-(void) disabled_testLocalPrefixWithoutMainPrefix
{
    // no effect when IDPrefix isn"t set
    [config setString:@"Attr.IDPrefix" object: @""];
    [config setString:@"Attr.IDPrefixLocal" object: @"story95_"];
 // [expectError(@"%Attr.IDPrefixLocal cannot be used unless %Attr.IDPrefix is set"];
    [self assertDef:@"amherst" expect:@"amherst"];
}

-(void) disabled_testRegexp
{
    [config setString:@"Attr.IDBlacklistRegexp" object:@"^g_"];
    
    [self assertDef:@"good_id" expect:@"good_id"];
    [self assertDef:@"g_bad_id" expect: nil];
}

 
@end
