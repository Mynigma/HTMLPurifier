//
//  HTMLPurifier_RemoveForeignElementsTest.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 15.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Strategy_RemoveForeignElements.h"
#import "HTMLPurifier_Lexer_libxmlLex.h"
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_Generator.h"


@interface HTMLPurifier_RemoveForeignElementsTest : HTMLPurifier_Harness
{
    HTMLPurifier_Strategy_RemoveForeignElements* obj;

    /**
     * Name of the function to be executed
     */
    SEL func;

    /**
     * Whether or not the method deals in tokens. If set to true, assertResult()
     * will transparently convert HTML to and back from tokens.
     */
    BOOL to_tokens;

    /**
     * Whether or not to convert tokens back into HTML before performing
     * equality check, has no effect on bools.
     */
    BOOL to_html;

    /**
     * Instance of an HTMLPurifier_Lexer implementation.
     */
    HTMLPurifier_Lexer_libxmlLex* lexer;

}

@end

static HTMLPurifier_Lexer* commonLexer;

@implementation HTMLPurifier_RemoveForeignElementsTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    to_html = YES;
    to_tokens = YES;
    func = @selector(execute:config:context:);
    obj = [HTMLPurifier_Strategy_RemoveForeignElements new];
    if(!commonLexer)
        commonLexer = [HTMLPurifier_Lexer createWithConfig:[super config]];
    lexer = commonLexer;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSString*)runOnString:(NSString*)string withExpectedResult:(NSObject*)expected
{
    //NSString* stringCopy = [string copy];
    NSArray* tokenizedString = [lexer tokenizeHTMLWithString:string config:[super config] context:[super context]];
    
    IMP imp = [obj methodForSelector:func];
    NSArray* (*function)(id, SEL, NSArray*, HTMLPurifier_Config*, HTMLPurifier_Context*) = (void *)imp;
    NSArray* result = function(obj, func, tokenizedString, [super config], [super context]);

    if([result isKindOfClass:[NSNumber class]])
    {
        XCTAssertEqualObjects(result, expected);
    }

    HTMLPurifier_Generator* generator = [[HTMLPurifier_Generator alloc] initWithConfig:[super config] context:[super context]];
    NSString* htmlString = [generator generateFromTokens:tokenizedString];

    if([expected isKindOfClass:[NSArray class]])
        expected = [generator generateFromTokens:(NSArray*)expected];

    XCTAssertEqualObjects(htmlString, expected);
}

- (void)testBlankInput
{
    [self runOnString:@"" withExpectedResult:@""];
}

- (void)testPreserveRecognizedElements
{
    NSString* testString = @"This is <b>bold text</b>.";
        [self runOnString:testString withExpectedResult:testString];
}


/*
    function testRemoveForeignElements() {
        $this->assertResult(
                            '<asdf>Bling</asdf><d href="bang">Bong</d><foobar />',
                            'BlingBong'
                            );
    }

    function testRemoveScriptAndContents() {
        $this->assertResult(
                            '<script>alert();</script>',
                            ''
                            );
    }

    function testRemoveStyleAndContents() {
        $this->assertResult(
                            '<style>.foo {blink;}</style>',
                            ''
                            );
    }

    function testRemoveOnlyScriptTagsLegacy() {
        $this->config->set('Core.RemoveScriptContents', false);
        $this->assertResult(
                            '<script>alert();</script>',
                            'alert();'
                            );
    }

    function testRemoveOnlyScriptTags() {
        $this->config->set('Core.HiddenElements', array());
        $this->assertResult(
                            '<script>alert();</script>',
                            'alert();'
                            );
    }

    function testRemoveInvalidImg() {
        $this->assertResult('<img />', '');
    }

    function testPreserveValidImg() {
        $this->assertResult('<img src="foobar.gif" alt="foobar.gif" />');
    }

    function testPreserveInvalidImgWhenRemovalIsDisabled() {
        $this->config->set('Core.RemoveInvalidImg', false);
        $this->assertResult('<img />');
    }

    function testTextifyCommentedScriptContents() {
        $this->config->set('HTML.Trusted', true);
        $this->config->set('Output.CommentScriptContents', false); // simplify output
        $this->assertResult(
                            '<script type="text/javascript"><!--
                            alert(<b>bold</b>);
                            // --></script>',
                            '<script type="text/javascript">
                            alert(&lt;b&gt;bold&lt;/b&gt;);
                            // </script>'
                            );
    }

    function testRequiredAttributesTestNotPerformedOnEndTag() {
        $this->config->set('HTML.DefinitionID',
                           'HTMLPurifier_Strategy_RemoveForeignElementsTest'.
                           '->testRequiredAttributesTestNotPerformedOnEndTag');
        $def = $this->config->getHTMLDefinition(true);
        $def->addElement('f', 'Block', 'Optional: #PCDATA', false, array('req*' => 'Text'));
        $this->assertResult('<f req="text">Foo</f> Bar');
    }
    
    function testPreserveCommentsWithHTMLTrusted() {
        $this->config->set('HTML.Trusted', true);
        $this->assertResult('<!-- foo -->');
    }
    
    function testRemoveTrailingHyphensInComment() {
        $this->config->set('HTML.Trusted', true);
        $this->assertResult('<!-- foo ----->', '<!-- foo -->');
    }
    
    function testCollapseDoubleHyphensInComment() {
        $this->config->set('HTML.Trusted', true);
        $this->assertResult('<!-- bo --- asdf--as -->', '<!-- bo - asdf-as -->');
    }
    
}*/


@end
