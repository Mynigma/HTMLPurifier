//
//  HTMLPurifier_ChildDef_RequiredTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 24.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_ChildDef_Required.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Arborize.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Lexer_libxmlLex.h"
#import "HTMLPurifier_Generator.h"
#import "HTMLPurifier_Node_Element.h"

@interface HTMLPurifier_ChildDef_RequiredTest : HTMLPurifier_Harness
{
    HTMLPurifier_ChildDef_Required* obj;
}
@end

@implementation HTMLPurifier_ChildDef_RequiredTest

- (void)setUp
{
    [super setUp];
    obj = [[HTMLPurifier_ChildDef_Required alloc] initWithElements:@"dt | dd"];
}

- (void)tearDown
{
    [super tearDown];
}

-(void) assertResult:(NSString*)input expect:(NSObject*)expect
{
    
    NSArray* input_children = [[HTMLPurifier_Arborize arborizeTokens:[self tokenize:input] config:[super config] context:[super context]] children];
    
    // call the function
    NSObject* result = [obj validateChildren:input_children config:[super config] context:[super context]];
    
    // test a bool result
    if ([result isKindOfClass:[NSNumber class]])
    {
        XCTAssertEqualObjects(expect, result);
        return;
    }
    
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


/*** Tests ***/

-(void) testPrepareString
{
    HTMLPurifier_ChildDef_Required* def = [[HTMLPurifier_ChildDef_Required alloc] initWithElements:@"foobar | bang |gizmo"];
    NSDictionary* x = @{@"foobar":@YES,@"bang":@YES,@"gizmo":@YES};
    XCTAssertEqualObjects([def elements],x);
}

-(void) testPrepareArray
{
    HTMLPurifier_ChildDef_Required* def = [[HTMLPurifier_ChildDef_Required alloc] initWithElements:@[@"href",@"src"]];
    NSDictionary* x =@{@"href":@YES,@"src":@YES};
    XCTAssertEqualObjects([def elements],x);
}

-(void) testEmptyInput
{
    [self assertResult:@"" expect:false];
}

-(void) testRemoveIllegalTagsAndElements
{
    [self assertResult:@"<dt>Term</dt>Text in an illegal location<dd>Definition</dd><b>Illegal tag</b>"
                expect:@"<dt>Term</dt><dd>Definition</dd>"];
    [self assertResult:@"How do you do!" expect:false];
}

-(void) testIgnoreWhitespace
{
    // whitespace shouldn't trigger it
    [self assertResult:@"\n<dd>Definition</dd>       " expect:@"\n<dd>Definition</dd>       "];
}

-(void) testPreserveWhitespaceAfterRemoval
{
    [self assertResult:@"<dd>Definition</dd>       <b></b>       " expect:@"<dd>Definition</dd>              "];
}

-(void) testDeleteNodeIfOnlyWhitespace
{
    [self assertResult:@"\t      " expect:false];
}

-(void) testPCDATAAllowed
{
     obj = [[HTMLPurifier_ChildDef_Required alloc] initWithElements:@"#PCDATA | b"];
    [self assertResult:@"Out <b>Bold text</b><img />" expect:@"Out <b>Bold text</b>"];
}
-(void) testPCDATAAllowedJump
{
    obj = [[HTMLPurifier_ChildDef_Required alloc] initWithElements:@"#PCDATA | b"];
    [self assertResult:@"A <i>foo</i>" expect:@"A foo"];
}

@end
