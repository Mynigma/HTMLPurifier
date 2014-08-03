//
//  HTMLPurifier_Strategy_FixNesting.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 03.08.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_Strategy_FixNesting.h"
#import "HTMLPurifier_Lexer_libxmlLex.h"
#import "HTMLPurifier_Token.h"
#import "HTMLPurifier_Generator.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Arborize.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Node_Element.h"
#import "HTMLPurifier.h"

@interface HTMLPurifier_Strategy_FixNestingTest : HTMLPurifier_Harness
{
    
HTMLPurifier_Strategy_FixNesting* obj;
HTMLPurifier_Lexer_libxmlLex* lexer;

SEL func;

/**
 * Whether or not the method deals in tokens.
 * If set to true, assertResult
 * will transparently convert HTML to and back from tokens.
 * @type bool
 */
BOOL to_tokens;

/**
 * Whether or not the method deals in a node list.
 * If set to true, assertResult will transparently convert HTML
 * to and back from node.
 * @type bool
 */
BOOL to_node_list;

/**
 * Whether or not to convert tokens back into HTML before performing
 * equality check, has no effect on bools.
 * @type bool
 */
BOOL to_html;
    
}
@end

@implementation HTMLPurifier_Strategy_FixNestingTest

- (void)setUp
{
    [super setUp];
    obj = [HTMLPurifier_Strategy_FixNesting new];
    func = @selector(execute:config:context:);
    lexer = [HTMLPurifier_Lexer_libxmlLex new];
    to_tokens = YES;
    to_node_list = NO;
    to_html = YES;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) assertResult:(NSObject*)input expect:(NSObject*)expectedResult
{
    NSObject* sameAgain;
    NSString* temp = (NSString*)input;
    if (to_node_list && [input isKindOfClass:[NSString class]])
    {
        input = [[HTMLPurifier_Arborize arborizeTokens:[self tokenize:temp] config:self.config context:self.context] children];
        sameAgain = [[HTMLPurifier_Arborize arborizeTokens:[self tokenize:temp] config:self.config context:self.context] children];
    } else if (to_tokens && [input isKindOfClass:[NSString class]])
    {
        input = [self tokenize:temp];
        sameAgain = [self tokenize:temp];
    } else {
        sameAgain = input;
    }
    
    // call the function
    
    //func = @selector(execute:config:context:);
    IMP imp = [obj methodForSelector:func];
    NSArray* (*function)(id, SEL, NSArray*, HTMLPurifier_Config*, HTMLPurifier_Context*) = (void *)imp;
    NSObject* result = function(obj, func, [(NSArray*)sameAgain mutableCopy], [super config], [super context]);
    
    // test a bool result
    if ([result isKindOfClass:[NSNumber class]])
    {
        XCTAssertEqualObjects(expectedResult, result);
        return;
    } else if ([expectedResult isKindOfClass:[NSNumber class]])
    {
        expectedResult = input;
    }
    
    if (to_html)
    {
        if (to_node_list)
    {
            result = [self generateTokens:(NSArray*)result];
            if ([expectedResult isKindOfClass:[NSArray class]] && [(NSArray*)expectedResult count]>0 && [[(NSArray*)expectedResult objectAtIndex:0] isKindOfClass:[HTMLPurifier_Node class]])
        {
                expectedResult = [self generateTokens:(NSArray*)expectedResult];
            }
        }
        NSArray* resultArray = (NSArray*)result;
        result = [self generate:resultArray];
        if ([expectedResult isKindOfClass:[NSArray class]])
    {
            expectedResult = [self generate:(NSArray*)expectedResult];
        }
    }
    
    XCTAssertEqualObjects(expectedResult, result);
    
    /*if ([expect isEqual:]result) {
     echo '<pre>' . var_dump($result) . '</pre>';
     }//tokenize*/
}

- (NSArray*)generateTokens:(NSArray*)children
{
    HTMLPurifier_Node_Element* dummy = [[HTMLPurifier_Node_Element alloc] initWithName:@"dummy"];
    dummy.children = [children mutableCopy];
    return [HTMLPurifier_Arborize flattenNode:dummy config:self.config context:self.context];
}

/**
 * Tokenize HTML into tokens, uses member variables for common variables
 */
-(NSArray*) tokenize:(NSString*)html
{
    return [lexer tokenizeHTMLWithString:html config:[super config] context:[super context]];
}

/**
 * Generate textual HTML from tokens
 */
-(NSString*) generate:(NSArray*)tokens
{
    HTMLPurifier_Generator* generator = [[HTMLPurifier_Generator alloc] initWithConfig:[super config] context:[super context]];
    return [generator generateFromTokens:tokens];
}

-(void) testEmptyInput
{
    [self assertResult:@"" expect:@""];
}

-(void) assertResult:(NSString*)result
{
    [self assertResult:result expect:result];
}

    
-(void) testPreserveInlineInRoot
{
    [self assertResult:@"<b>Bold text</b>"];
}
    
-(void) testPreserveInlineAndBlockInRoot
{
    [self assertResult:@"<a href=\"about:blank\">Blank</a><div>Block</div>"];
}
    
-(void) testRemoveBlockInInline
{
    [self assertResult:@"<b><div>Illegal div.</div></b>" expect:@"<b>Illegal div.</b>"];
}
    
-(void) testRemoveNodeWithMissingRequiredElements
{
    [self assertResult:@"<ul></ul>" expect:@""];
}
    
-(void) testListHandleIllegalPCDATA
{
    [self assertResult:@"<ul>Illegal text<li>Legal item</li></ul>" expect:@"<ul><li>Illegal text</li><li>Legal item</li></ul>"];
}

// Changed from <table><tr><td></td></tr></table> to <table><tr><td /></tr></table> b.c. different Lexer Output. Is kinda valid.
-(void) testRemoveIllegalPCDATA
{
    [self assertResult:@"<table><tr>Illegal text<td></td></tr></table>" expect:@"<table><tr><td /></tr></table>"];
}
    
-(void) testCustomTableDefinition
{
    [self assertResult:@"<table><tr><td>Cell 1</td></tr></table>"];
}
    
-(void) testRemoveEmptyTable
{
    [self assertResult:@"<table></table>" expect:@""];
}
    
-(void) testChameleonRemoveBlockInNodeInInline
{
    [self assertResult:@"<span><ins><div>Not allowed!</div></ins></span>" expect:@"<span><ins>Not allowed!</ins></span>"];
}
    
-(void) testChameleonRemoveBlockInBlockNodeWithInlineContent
{
    [self assertResult:@"<h1><ins><div>Not allowed!</div></ins></h1>" expect:@"<h1><ins>Not allowed!</ins></h1>"];
}
    
-(void) testNestedChameleonRemoveBlockInNodeWithInlineContent
{
    [self assertResult:@"<h1><ins><del><div>Not allowed!</div></del></ins></h1>" expect:@"<h1><ins><del>Not allowed!</del></ins></h1>"];
}
    
-(void) testNestedChameleonPreserveBlockInBlock
{
    [self assertResult:@"<div><ins><del><div>Allowed!</div></del></ins></div>"];
}
    
-(void) testExclusionsIntegration
{
        // test exclusions
    [self assertResult:@"<a><span><a>Not allowed</a></span></a>" expect:@"<a><span></span></a>"];
}

/* CONFIG
-(void) testPreserveInlineNodeInInlineRootNode
{
        $this->config->set('HTML.Parent', 'span');
    [self assertResult:@"<b>Bold</b>');
}
    
-(void) testRemoveBlockNodeInInlineRootNode
{
        $this->config->set('HTML.Parent', 'span');
    [self assertResult:@"<div>Reject</div>', 'Reject');
}
    
-(void) testInvalidParentError
{
        // test fallback to div
        $this->config->set('HTML.Parent', 'obviously-impossible');
        $this->config->set('Cache.DefinitionImpl', null);
        $this->expectError('Cannot use unrecognized element as parent');
    [self assertResult:@"<div>Accept</div>');
}

*/

-(void) testCascadingRemovalOfNodesMissingRequiredChildren
{
    [self assertResult:@"<table><tr></tr></table>" expect:@""];
}
    
-(void) testCascadingRemovalSpecialCaseCannotScrollOneBack
{
    [self assertResult:@"<table><tr></tr><tr></tr></table>" expect:@""];
}
    
-(void) testLotsOfCascadingRemovalOfNodes
{
    [self assertResult:@"<table><tbody><tr></tr><tr></tr></tbody><tr></tr><tr></tr></table>" expect:@""];
}
    
-(void) testAdjacentRemovalOfNodeMissingRequiredChildren
{
    [self assertResult:@"<table></table><table></table>" expect:@""];
}

/** Config
-(void) testStrictBlockquoteInHTML401
{
        $this->config->set('HTML.Doctype', 'HTML 4.01 Strict');
    [self assertResult:@"<blockquote>text</blockquote>', '<blockquote><p>text</p></blockquote>');
}
    
-(void) testDisabledExcludes
{
        $this->config->set('Core.DisableExcludes', true);
    [self assertResult:@"<pre><font><font></font></font></pre>');
}
**/


@end
