//
//  HTMLPurifier_Strategy_MakeWellFormedTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 22.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_Strategy_MakeWellFormed.h"
#import "HTMLPurifier_Lexer_libxmlLex.h"
#import "HTMLPurifier_Token.h"
#import "HTMLPurifier_Generator.h"
#import "HTMLPurifier_Config.h"

@interface HTMLPurifier_Strategy_MakeWellFormedTest : HTMLPurifier_Harness
{
    HTMLPurifier_Strategy_MakeWellFormed* obj;
    HTMLPurifier_Lexer_libxmlLex* lexer;
}
@end

@implementation HTMLPurifier_Strategy_MakeWellFormedTest

- (void)setUp
{
    [super setUp];
    obj = [HTMLPurifier_Strategy_MakeWellFormed new];
    lexer = [HTMLPurifier_Lexer_libxmlLex new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) assertResult:(NSString*)input expect:(NSString*)expect
{
    
    //tokenize
    NSMutableArray* input_arr = [[self tokenize:input] mutableCopy];

    // call the function
    NSMutableArray* result = [obj execute:input_arr config:[super config] context:[super context]];
    
    NSString* result_string = [self generate:result];

    XCTAssertEqualObjects(expect, result_string);
    
    /* ??
    if ($expect !== $result) {
        echo '<pre>' . var_dump($result) . '</pre>';
    }*/

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
    [self assertResult:@"<b><i>Bold and italic?</b>" expect:@"<b><i>Bold and italic?</i></b><i></i>"];
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
