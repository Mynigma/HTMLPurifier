 //
//   HTMLPurifier_Strategy_MakeWellFormedTest.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 22.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_Strategy_MakeWellFormed.h"
#import "HTMLPurifier_Lexer_libxmlLex.h"
#import "HTMLPurifier_Token.h"
#import "HTMLPurifier_Generator.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Arborize.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Node_Element.h"

@interface HTMLPurifier_Strategy_MakeWellFormedTest : HTMLPurifier_Harness
{
    HTMLPurifier_Strategy_MakeWellFormed* obj;
    HTMLPurifier_Lexer_libxmlLex* lexer;

    SEL func;

    /**
     * Whether or not the method deals in tokens.
     * If set to true, assertResult()
     * will transparently convert HTML to and back from tokens.
     * @type bool
     */
    BOOL to_tokens;

    /**
     * Whether or not the method deals in a node list.
     * If set to true, assertResult() will transparently convert HTML
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

@implementation HTMLPurifier_Strategy_MakeWellFormedTest

- (void)setUp
{
    [super setUp];
    obj = [HTMLPurifier_Strategy_MakeWellFormed new];
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

-(void) testWellFormedInput
{
    [self assertResult:@"This is <b>bold text</b>." expect:@"This is <b>bold text</b>."];
}

-(void) testUnclosedTagTerminatedByDocumentEnd
{
    [self assertResult:@"<b>Unclosed tag, gasp!" expect:@"<b>Unclosed tag, gasp!</b>"];
}

-(void) testUnclosedTagTerminatedByParentNodeEnd
{
    [self assertResult:@"<b><i>Bold and italic?</b>" expect:@"<b><i>Bold and italic?</i></b>"];
}

-(void) testRemoveStrayClosingTag
{
    [self assertResult:@"Unused end tags... recycle!</b>" expect:@"Unused end tags... recycle!"];
}

-(void) testConvertStartToEmpty
{
    [self assertResult:@"<br style=\"clear:both;\">" expect:@"<br style=\"clear:both;\" />"];
}

-(void) testConvertEmptyToStart
{
    [self assertResult:@"<div style=\"clear:both;\" />" expect:@"<div style=\"clear:both;\"></div>"];
}

-(void) testAutoCloseParagraph
{
    [self assertResult:@"<p>Paragraph 1<p>Paragraph 2" expect:@"<p>Paragraph 1</p><p>Paragraph 2</p>"];
}

-(void) testAutoCloseParagraphInsideDiv
{
    [self assertResult:@"<div><p>Paragraphs<p>In<p>A<p>Div</div>" expect:@"<div><p>Paragraphs</p><p>In</p><p>A</p><p>Div</p></div>"];
}

-(void) testAutoCloseListItem
{
    [self assertResult:@"<ol><li>Item 1<li>Item 2</ol>" expect:@"<ol><li>Item 1</li><li>Item 2</li></ol>"];
}

-(void) testAutoCloseColgroup
{
    [self assertResult:@"<table><colgroup><col /><tr></tr></table>" expect:@"<table><colgroup><col /></colgroup><tr></tr></table>"];
}

-(void) testAutoCloseMultiple
{
    [self assertResult:@"<b><span><div></div>asdf" expect:@"<b><span></span></b><div><b></b></div><b>asdf</b>"];
}

-(void) testUnrecognized
{
    [self assertResult:@"<asdf><foobar /><biddles>foo</asdf>" expect:@"<asdf><foobar /><biddles>foo</biddles></asdf>"];
}

     
-(void) disabled_testBlockquoteWithInline
{
    [[super config] setString:@"HTML.Doctype" object:@"XHTML 1.0 Strict"];
    [self assertResult:@"<blockquote>foo<b>bar</b></blockquote>" expect:@"<blockquote>foo<b>bar</b></blockquote>"];
}

-(void) testLongCarryOver
{
    [self assertResult:@"<b>asdf<div>asdf<i>df</i></div>asdf</b>" expect:@"<b>asdf</b><div><b>asdf<i>df</i></b></div><b>asdf</b>"];
}

-(void) testInterleaved
{
    [self assertResult:@"<u>foo<i>bar</u>baz</i>" expect:@"<u>foo<i>bar</i></u><i>baz</i>"];
}

-(void) testNestedOl
{
    [self assertResult:@"<ol><ol><li>foo</li></ol></ol>" expect:@"<ol><ol><li>foo</li></ol></ol>"];
}

-(void) testNestedUl
{
    [self assertResult:@"<ul><ul><li>foo</li></ul></ul>" expect:@"<ul><ul><li>foo</li></ul></ul>"];
}

-(void) testNestedOlWithStrangeEnding
{
    [self assertResult:@"<ol><li><ol><ol><li>foo</li></ol></li><li>foo</li></ol>" expect:@"<ol><li><ol><ol><li>foo</li></ol></ol></li><li>foo</li></ol>"];
}

-(void) testNoAutocloseIfNoParentsCanAccomodateTag
{
    [self assertResult:@"<table><tr><td><li>foo</li></td></tr></table>" expect:@"<table><tr><td>foo</td></tr></table>"];
}

@end
