//
//  HTMLPurifier_ChildDef_ChameleonTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 24.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_ChildDef_Chameleon.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Arborize.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Lexer_libxmlLex.h"
#import "HTMLPurifier_Generator.h"
#import "HTMLPurifier_Node_Element.h"

@interface HTMLPurifier_ChildDef_ChameleonTest : HTMLPurifier_Harness
{
    HTMLPurifier_ChildDef_Chameleon* obj;
    NSNumber* isInline;
}
@end

@implementation HTMLPurifier_ChildDef_ChameleonTest

- (void)setUp
{
    [super setUp];
    obj = [[HTMLPurifier_ChildDef_Chameleon alloc] initWithInline:@[@"b",@"i"] block:@[@"b",@"i",@"div"]];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) assertResult:(NSString*)input expect:(NSObject*)expect
{
    [[super context] registerWithName:@"IsInline" ref:isInline];
  
    NSArray* input_children = [[HTMLPurifier_Arborize arborizeTokens:[self tokenize:input] config:[super config] context:[super context]] children];

    // call the function
    NSObject* result = [obj validateChildren:input_children config:[super config] context:[super context]];
    
    // test a bool result
    if ([result isKindOfClass:[NSNumber class]])
    {
        XCTAssertEqualObjects(expect, result);
        return;
    }

    //Result should be an Array...
    result = [self generateTokens:(NSArray*)result];
    
    result = [self generate:(NSArray*)result];

    XCTAssertEqualObjects(expect, result);
    
}

-(NSArray*) tokenize:(NSString*)html
{
    HTMLPurifier_Lexer_libxmlLex* lexer;
    lexer = [HTMLPurifier_Lexer_libxmlLex new];
    return [lexer tokenizeHTMLWithString:html config:[super config] context:[super context]];
}

-(NSString*) generate:(NSArray*)tokens
{
    HTMLPurifier_Generator* generator = [[HTMLPurifier_Generator alloc] initWithConfig:[super config] context:[super context]];
    return [generator generateFromTokens:tokens];
}

- (NSArray*)generateTokens:(NSArray*)children
{
    HTMLPurifier_Node_Element* dummy = [[HTMLPurifier_Node_Element alloc] initWithName:@"dummy"];
    dummy.children = [children mutableCopy];
    return [HTMLPurifier_Arborize flattenNode:dummy config:self.config context:self.context];
}




/** The tests...**/

-(void) testInlineAlwaysAllowed
{
    isInline = @YES;
    [self assertResult:@"<b>Allowed.</b>" expect:@"<b>Allowed.</b>"];
}

-(void) testBlockNotAllowedInInline
{
    isInline = @YES;
    [self assertResult:@"<div>Not allowed.</div>" expect:@""];
}

-(void) testBlockAllowedInNonInline
{
    isInline = @NO;
    [self assertResult:@"<div>Allowed.</div>" expect:@"<div>Allowed.</div>"];
}

@end
